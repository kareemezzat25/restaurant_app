import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:resturant_app/admin/itemdetailsAdmin.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditItem extends StatefulWidget {
  final Map<String, dynamic> item; // Pass the existing item data to this page

  const EditItem({super.key, required this.item});

  @override
  State<EditItem> createState() => _EditItemState();
}

class _EditItemState extends State<EditItem> {
  final List<String> foodItems = ['Ice-cream', 'Burger', 'Salad', 'Pizza'];
  String? selectedCategory;
  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController detailController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? selectedImage;
  String? currentImageUrl;

  @override
  void initState() {
    super.initState();
    // Initialize the form with existing data
    nameController.text = widget.item['itemname'] ?? '';
    priceController.text = widget.item['itemprice']?.toString() ?? '';
    detailController.text = widget.item['itemdetails'] ?? '';
    selectedCategory = widget.item['category'];
    currentImageUrl = widget.item['itemimage'];
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

  Future<void> updateItem() async {
    try {
      String? newImageUrl = currentImageUrl;

      // Upload a new image if selected
      if (selectedImage != null) {
        final fileName = DateTime.now().millisecondsSinceEpoch.toString() +
            '_' +
            selectedImage!.path.split('/').last;
        final fileBytes = await selectedImage!.readAsBytes();

        // Delete the old image from Supabase storage
        if (currentImageUrl != null) {
          final oldImagePath = Uri.parse(currentImageUrl!).pathSegments.last;
          await Supabase.instance.client.storage
              .from('food_images') // Bucket name
              .remove([oldImagePath]);
        }

        // Upload the new image
        final uploadPath = 'public/$fileName';
        await Supabase.instance.client.storage
            .from('food_images')
            .uploadBinary(uploadPath, fileBytes);

        // Update the image URL
        newImageUrl = Supabase.instance.client.storage
            .from('food_images')
            .getPublicUrl(uploadPath);
      }

      // Update the item in the Supabase database
      await Supabase.instance.client.from('item').update({
        'itemname': nameController.text,
        'itemprice': double.parse(priceController.text),
        'itemdetails': detailController.text,
        'category': selectedCategory,
        'itemimage': newImageUrl,
      }).eq('id', widget.item['id']); // Use the item's ID for updating

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            "Item updated successfully!",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );

      Navigator.pop(context, {
        'itemname': nameController.text,
        'itemprice': double.parse(priceController.text),
        'itemdetails': detailController.text,
        'category': selectedCategory,
        'itemimage': newImageUrl,
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              "Error: $e",
              style: const TextStyle(color: Colors.white),
            )),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              )),
          centerTitle: true,
          title: const Text(
            "Edit Item",
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
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
                        ? (currentImageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(
                                  width: 150,
                                  height: 150,
                                  currentImageUrl!,
                                  fit: BoxFit.fill,
                                  errorBuilder: (context, error, stackTrace) {
                                    // Use fallback asset image if network image fails
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.asset(
                                        'images/salad2.png',
                                        fit: BoxFit.fill,
                                      ),
                                    );
                                  },
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.asset(
                                  'images/salad2.png',
                                  fit: BoxFit.fill,
                                ),
                              ))
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.file(
                              width: 150,
                              height: 150,
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
                controller: nameController,
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
                controller: priceController,
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
                controller: detailController,
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
                    items: foodItems
                        .map((String value) =>
                            DropdownMenuItem(value: value, child: Text(value)))
                        .toList(),
                    onChanged: (newValue) {
                      setState(() {
                        selectedCategory = newValue;
                      });
                    },
                    hint: const Text("Select Category"),
                    value: selectedCategory,
                  ),
                ),
              ),
              const SizedBox(height: 40.0),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize:
                        Size(MediaQuery.of(context).size.width * 0.8, 50),
                    backgroundColor: Colors.black,
                  ),
                  onPressed: updateItem,
                  child: const Text(
                    "Update Item",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    Color? fillColor,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
