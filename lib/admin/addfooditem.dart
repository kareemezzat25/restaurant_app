import 'dart:io';
import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddItem extends StatefulWidget {
  const AddItem({super.key});

  @override
  State<AddItem> createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  final List<String> fooditems = [
    'Ice-cream',
    'Burger',
    'Salad',
    'Pizza',
    'Juices',
    'Sandwiches',
    'Breakfast',
    'Shawarma',
    'Steak',
    'FriedChicken',
    'Pastas',
    'Desserts',
    'hot-drink'
  ];

  String? value;
  TextEditingController namecontroller = TextEditingController();
  TextEditingController pricecontroller = TextEditingController();
  TextEditingController detailcontroller = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? selectedImage;
  Duration? selectedDuration;

  Future<void> pickDuration() async {
    final duration = await showDurationPicker(
      context: context,
      initialTime: const Duration(minutes: 0),
    );

    if (duration != null) {
      setState(() {
        selectedDuration = duration;
      });
    }
  }

  Future<void> getImage() async {
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

      if (image != null) {
        setState(() {
          selectedImage = File(image!.path);
        });
      }
    }
  }

  Future<void> uploadItem() async {
    if (selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an image.")),
      );
      return;
    }

    // Check if all fields are filled
    if (namecontroller.text.isEmpty ||
        pricecontroller.text.isEmpty ||
        detailcontroller.text.isEmpty ||
        value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all the fields.")),
      );
      return;
    }

    try {
      // Generate a unique file name using timestamp
      final fileName = DateTime.now().millisecondsSinceEpoch.toString() +
          '_' +
          selectedImage!.path.split('/').last;
      final fileBytes = await selectedImage!.readAsBytes();

      // Upload the image to the Supabase storage bucket
      final uploadPath = 'public/$fileName';
      await Supabase.instance.client.storage
          .from('food_images') // Bucket name
          .uploadBinary(uploadPath, fileBytes);

      final imageUrl = Supabase.instance.client.storage
          .from('food_images')
          .getPublicUrl(uploadPath);

      await Supabase.instance.client.from('item').insert({
        'itemname': namecontroller.text,
        'itemprice': double.parse(pricecontroller.text),
        'itemdetails': detailcontroller.text,
        'category': value,
        'itemimage': imageUrl,
        'delivery_time': selectedDuration!.inMinutes,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            "Item has been added successfully!",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );

      // Clear the form
      setState(() {
        namecontroller.clear();
        pricecontroller.clear();
        detailcontroller.clear();
        value = null;
        selectedImage = null;
        selectedDuration = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              "Error: $e",
              style: TextStyle(color: Colors.white),
            )),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF8966), Color(0xFFFF5F6D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          "Add Item",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF9F9F9), Color(0xFFF1F1F1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20.0),
              GestureDetector(
                onTap: getImage,
                child: Center(
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: Colors.grey.shade400, width: 1.5),
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: selectedImage == null
                        ? const Icon(
                            Icons.camera_alt_outlined,
                            color: Colors.grey,
                            size: 40,
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.file(
                              selectedImage!,
                              fit: BoxFit.fill,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 30.0),
              _buildStyledTextFormField(
                controller: namecontroller,
                labelText: "Item Name",
                hintText: "Enter Item Name",
              ),
              const SizedBox(height: 30.0),
              _buildStyledTextFormField(
                controller: pricecontroller,
                labelText: "Item Price",
                hintText: "Enter Item Price",
              ),
              const SizedBox(height: 30.0),
              /* const Text(
                "Delivery Time",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10.0),
              */
              GestureDetector(
                onTap: pickDuration,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      selectedDuration != null
                          ? "${selectedDuration!.inMinutes} Minutes"
                          : "Select Delivery Time",
                      style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30.0),
              _buildStyledTextFormField(
                controller: detailcontroller,
                labelText: "Item Details",
                hintText: "Enter Item Detail",
                maxLines: 6,
              ),
              const SizedBox(height: 20.0),
              /*
              const Text(
                "Select Category",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20.0),*/
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    items: fooditems
                        .map((String value) =>
                            DropdownMenuItem(value: value, child: Text(value)))
                        .toList(),
                    onChanged: (newValue) {
                      setState(() {
                        value = newValue;
                      });
                    },
                    hint: const Text("Select Category"),
                    value: value,
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              GestureDetector(
                onTap: uploadItem,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    width: 160,
                    decoration: BoxDecoration(
                      color: Color(0xFFFF6E73),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        "Add Item",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStyledTextFormField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        filled: true,
        fillColor: Colors.white,
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              BorderSide(color: Color(0xFFFF8966).withOpacity(0.7), width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
      ),
    );
  }
}
