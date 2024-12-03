import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data'; // For base64 encoding if needed
import 'package:supabase_flutter/supabase_flutter.dart';

class AddItem extends StatefulWidget {
  const AddItem({super.key});

  @override
  State<AddItem> createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  final List<String> fooditems = ['Ice-cream', 'Burger', 'Salad', 'Pizza'];
  String? value;
  TextEditingController namecontroller = TextEditingController();
  TextEditingController pricecontroller = TextEditingController();
  TextEditingController detailcontroller = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? selectedImage;

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

      // Get the public URL of the uploaded image
      final imageUrl = Supabase.instance.client.storage
          .from('food_images')
          .getPublicUrl(uploadPath);

      // Insert item data into the `item` table
      await Supabase.instance.client.from('item').insert({
        'itemname': namecontroller.text,
        'itemprice': double.parse(pricecontroller.text),
        'itemdetails': detailcontroller.text,
        'category': value,
        'itemimage': imageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            "Item added successfully!",
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
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(
                Icons.arrow_back_ios_new_outlined,
                color: Color(0xFF373866),
              )),
          centerTitle: true,
          title: const Text(
            "Add Item",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
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
                      border: Border.all(color: Colors.black, width: 1.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: selectedImage == null
                        ? const Icon(
                            Icons.camera_alt_outlined,
                            color: Colors.black,
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
              const Text(
                "Item Name",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10.0),
              _buildTextFormField(
                controller: namecontroller,
                hintText: "Enter Item Name",
                fillColor: const Color.fromARGB(255, 239, 239, 242),
              ),
              const SizedBox(height: 30.0),
              const Text(
                "Item Price",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10.0),
              _buildTextFormField(
                controller: pricecontroller,
                hintText: "Enter Item Price",
                fillColor: const Color.fromARGB(255, 239, 239, 242),
              ),
              const SizedBox(height: 30.0),
              const Text(
                "Item Detail",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10.0),
              _buildTextFormField(
                controller: detailcontroller,
                hintText: "Enter Item Detail",
                fillColor: const Color.fromARGB(255, 239, 239, 242),
                maxLines: 6,
              ),
              const SizedBox(height: 20.0),
              const Text(
                "Select Category",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 239, 239, 242),
                    borderRadius: BorderRadius.circular(10)),
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
                onTap: () {
                  uploadItem(); // Call the upload function
                },
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text(
                        "Add",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22.0,
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

  Widget _buildTextFormField(
      {required TextEditingController controller,
      required String hintText,
      int? maxLines = 1,
      required Color fillColor}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        filled: true,
        fillColor: fillColor,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
