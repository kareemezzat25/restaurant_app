import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:date_format/date_format.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final SupabaseClient supabase = Supabase.instance.client;
  Map<String, dynamic>? userData;
  final ImagePicker _picker = ImagePicker();
  bool isLoading = true;
  File? selectedImage;
  String? selectedGender;
  DateTime? selectedDate; //
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController usernameController =
      TextEditingController(); // مخصص لـ username

  String phoneNumber = ''; // لتخزين رقم الهاتف

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> getImage() async {
    try {
      final action = await showModalBottomSheet<String>(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text("Choose from Gallery"),
                  onTap: () => Navigator.pop(context, "gallery"),
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text("Take a Photo"),
                  onTap: () => Navigator.pop(context, "camera"),
                ),
              ],
            ),
          );
        },
      );

      if (action != null) {
        XFile? image;
        if (action == "gallery") {
          image = await _picker.pickImage(source: ImageSource.gallery);
        } else if (action == "camera") {
          image = await _picker.pickImage(source: ImageSource.camera);
        }

        if (image != null && image.path.isNotEmpty) {
          setState(() {
            selectedImage = File(image!.path);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No image selected.'),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "Error selecting image: $e",
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  Future<void> fetchUserData() async {
    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        final response = await supabase
            .from('users')
            .select()
            .eq('email', user.email!)
            .limit(1)
            .single();
        setState(() {
          userData = response;
          usernameController.text = response['username'] ?? '';
          selectedGender = response['gender'];
          selectedDate = DateTime.tryParse(response['datebirthday'] ?? '');
          phoneController.text = response['phonenumber'] ?? '';
          isLoading = false;
        });
      } else {
        print('No authenticated user found.');
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      print('Error fetching user data: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Future<void> saveProfile() async {
    try {
      final updateData = {
        'username': usernameController.text,
        'gender': selectedGender,
        'datebirthday': selectedDate?.toIso8601String(),
        'phonenumber': phoneController.text,
      };

      if (selectedImage != null) {
        final file = File(selectedImage!.path);
        final newImageUrl = await uploadImageToSupabase(file);
        if (newImageUrl != null) {
          updateData['imageurl'] = newImageUrl;
        }
      }

      await supabase
          .from('users')
          .update(updateData)
          .eq('email', userData?['email']);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } catch (error) {
      print('Error updating profile: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile.')),
      );
    }
  }

  Future<String?> uploadImageToSupabase(File image) async {
    try {
      final bytes = await image.readAsBytes();
      final fileName =
          'users/images/${DateTime.now().millisecondsSinceEpoch}.png';
      final response = await supabase.storage.from('users_images').uploadBinary(
            fileName,
            bytes,
            fileOptions: FileOptions(upsert: true),
          );
      if (response != null) {
        return supabase.storage.from('users_images').getPublicUrl(fileName);
      }
    } catch (error) {
      print('Error uploading image: $error');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: getImage,
                    child: Center(
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: selectedImage != null
                            ? FileImage(File(selectedImage!.path))
                            : (userData?['imageurl'] != null
                                    ? NetworkImage(userData!['imageurl'])
                                    : const AssetImage('images/anonymous.png'))
                                as ImageProvider,
                        child: const Align(
                          alignment: Alignment.bottomRight,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.blue,
                            child: Icon(Icons.camera_alt,
                                color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Username:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: TextField(
                        controller: usernameController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter your username',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (selectedGender == null) ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Gender:',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: RadioListTile<String>(
                                  title: const Text('Male'),
                                  value: 'Male',
                                  groupValue: selectedGender,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedGender = value;
                                    });
                                  },
                                ),
                              ),
                              Expanded(
                                child: RadioListTile<String>(
                                  title: const Text('Female'),
                                  value: 'Female',
                                  groupValue: selectedGender,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedGender = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16)
                  ],
                  const Text(
                    'Date of Birth:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(selectedDate != null
                          ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                          : 'Select your date of birth'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: pickDate,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Phone Number:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: InternationalPhoneNumberInput(
                        onInputChanged: (PhoneNumber number) {
                          setState(() {
                            phoneNumber = number.phoneNumber ?? '';
                          });
                        },
                        initialValue: PhoneNumber(isoCode: 'US'),
                        textFieldController: phoneController,
                        inputDecoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter your phone number',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width / 2,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xff2C9CEE)),
                        onPressed: saveProfile,
                        child: const Text(
                          'Save',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
