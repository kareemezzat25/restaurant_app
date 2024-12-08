/*import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:resturant_app/admin/admin_login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminProfile extends StatefulWidget {
  const AdminProfile({super.key});

  @override
  State<AdminProfile> createState() => _AdminProfileState();
}

class _AdminProfileState extends State<AdminProfile> {
  final SupabaseClient supabase = Supabase.instance.client;
  Map<String, dynamic>? userData;
  final ImagePicker _picker = ImagePicker();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
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

  Future<void> pickImage() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Select from Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile =
                    await _picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  await handlePickedImage(pickedFile);
                } else {
                  print('No image selected from gallery.');
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Open Camera'),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile =
                    await _picker.pickImage(source: ImageSource.camera);
                if (pickedFile != null) {
                  await handlePickedImage(pickedFile);
                } else {
                  print('No image captured from camera.');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> handlePickedImage(XFile pickedFile) async {
    if (userData?['imageurl'] != null && userData!['imageurl'].isNotEmpty) {
      await deleteImageFromSupabase(userData!['imageurl']);
    }

    final newImageUrl = await uploadImageToSupabase(pickedFile.path);
    if (newImageUrl != null) {
      await updateImageUrl(newImageUrl);
      setState(() {
        userData?['imageurl'] = newImageUrl;
      });
    }
  }

  Future<void> deleteImageFromSupabase(String imageUrl) async {
    try {
      final fileName = imageUrl.split('/').last;
      final response =
          await supabase.storage.from('users_images').remove([fileName]);
      if (response.isEmpty) {
        print('Image deleted successfully.');
      } else {
        print('Error deleting image: $response');
      }
    } catch (error) {
      print('Error deleting image: $error');
    }
  }

  Future<String?> uploadImageToSupabase(String imagePath) async {
    try {
      final bytes = await XFile(imagePath).readAsBytes();
      final fileName =
          'users/images/${DateTime.now().millisecondsSinceEpoch}.png';
      final response = await supabase.storage.from('users_images').uploadBinary(
          fileName, bytes,
          fileOptions: FileOptions(upsert: true));
      if (response != null) {
        final publicUrl =
            supabase.storage.from('users_images').getPublicUrl(fileName);
        print('Image uploaded successfully: $publicUrl');
        return publicUrl;
      } else {
        print('Error uploading image: $response');
      }
    } catch (error) {
      print('Error uploading image: $error');
    }
    return null;
  }

  Future<void> updateImageUrl(String newImageUrl) async {
    try {
      if (userData != null) {
        final response = await supabase
            .from('users')
            .update({'imageurl': newImageUrl}).eq('email', userData?['email']);
        if (response != null && response.isNotEmpty) {
          setState(() {
            userData?['imageurl'] = newImageUrl;
          });
        } else {
          print('Failed to update image URL in database.');
        }
      }
    } catch (error) {
      print('Error updating image URL: $error');
    }
  }

  void logout() async {
    await supabase.auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AdminLogin()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        centerTitle: true,
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => pickImage(),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: userData?['imageurl'] != null
                          ? NetworkImage(userData!['imageurl'])
                          : const AssetImage('assets/images/anonymous.png')
                              as ImageProvider,
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.blue,
                          child: const Icon(Icons.camera_alt,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userData?['username'] ?? 'No Username',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    userData?['email'] ?? 'No Email',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
*/
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:resturant_app/admin/admin_login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminProfile extends StatefulWidget {
  const AdminProfile({super.key});

  @override
  State<AdminProfile> createState() => _AdminProfileState();
}

class _AdminProfileState extends State<AdminProfile> {
  final SupabaseClient supabase = Supabase.instance.client;
  Map<String, dynamic>? userData;
  final ImagePicker _picker = ImagePicker();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
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

  Widget showZoomedAvatar(String imageUrl) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black, // الخلفية شفافة
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // العودة إلى الصفحة السابقة
          },
        ),
      ),
      body: Container(
        color: Colors.black,
        width: MediaQuery.of(context).size.width,
        child: Center(
          child: SizedBox(
            height: 400,
            child: PhotoView(
              imageProvider: NetworkImage(
                imageUrl,
              ),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,
            ),
          ),
        ),
      ),
    );
  }

  void showSettingsMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const EditProfilePage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock_reset),
            title: const Text('Reset Password'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to Reset Password page or handle functionality
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pop(context);
              logout();
            },
          ),
        ],
      ),
    );
  }

  void logout() async {
    await supabase.auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AdminLogin()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        if (userData?['imageurl'] != null) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      showZoomedAvatar(userData?['imageurl'])));
                        }
                      },
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: userData?['imageurl'] != null
                            ? NetworkImage(userData!['imageurl'])
                            : const AssetImage('assets/images/anonymous.png')
                                as ImageProvider,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      userData?['username'] ?? 'No Username',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      userData?['email'] ?? 'No Email',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Username:'),
                      Text(userData?['username'] ?? 'No Username'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Email:'),
                      Text(userData?['email'] ?? 'No Email'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: showSettingsMenu,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: const Text('Edit Profile Page (To Be Implemented)'),
      ),
    );
  }
}
