import 'package:flutter/material.dart';
import 'package:resturant_app/admin/edititemadmin.dart';
import 'package:resturant_app/widgets/textwidget.dart'; // Ensure you have this imported
import 'package:supabase_flutter/supabase_flutter.dart';

class ItemDetails extends StatefulWidget {
  final int itemId;

  const ItemDetails({super.key, required this.itemId});

  @override
  State<ItemDetails> createState() => _DetailsState();
}

class _DetailsState extends State<ItemDetails> {
  Map<String, dynamic> item = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchItemDetails();
  }

  String formatDeliveryTime(int minutes) {
    if (minutes < 60) {
      return '$minutes minutes';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '$hours hours';
      } else {
        return '$hours hours and $remainingMinutes minutes';
      }
    }
  }

  Future<void> fetchItemDetails() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await Supabase.instance.client
          .from('item')
          .select('*')
          .eq('id', widget.itemId)
          .single();

      if (response != null) {
        setState(() {
          item = response;
        });
      } else {
        print("Item not found.");
      }
    } catch (e) {
      print("Error fetching item: $e");
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> deleteItem() async {
    final imageUrl = item['itemimage'] ?? '';
    print("Imageurl : $imageUrl");
    try {
      final bucketName = 'food_images';

      final imageName = Uri.parse(imageUrl).pathSegments.last;
      print("Image Name: $imageName");
      final String imageaddpublic = "public/$imageName";

      // محاولة حذف الصورة من الباكت
      final storageResponse = await Supabase.instance.client.storage
          .from(bucketName)
          .remove([imageaddpublic]);

      print("Stot: $storageResponse");

      if (storageResponse == null || storageResponse.isEmpty) {
        print(
            "Error deleting image from storage: Image not found or deletion failed.");
      } else {
        print("Image deleted successfully from storage.");
      }

      final deleteResponse = await Supabase.instance.client
          .from('item')
          .delete()
          .eq('id', widget.itemId);

      if (deleteResponse != null) {
        print("Error deleting item from database: No response received.");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              "Item deleted successfully!",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      print("Error deleting item: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true); // Pass true when going back
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.black,
          centerTitle: true,
          title: Text(
            "Food Details",
            style: TextStyle(
                color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context, true);
            },
            child: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(top: 18, left: 8.0, right: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                            20), // Circular border for image
                        child: Image.network(
                          item['itemimage'] ?? '',
                          width: MediaQuery.of(context).size.width / 1.1,
                          height: MediaQuery.of(context).size.height / 2.8,
                          fit: BoxFit.fill,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'images/salad2.png',
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height / 3,
                              fit: BoxFit.fill,
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 30),
                      Text(
                        item['itemname'] ?? "Item Name",
                        style: TextWidget.boldTextFieldStyle(),
                      ),
                      SizedBox(height: 10),
                      Text(
                        item['category'] ?? "Category",
                        style: TextWidget.semiBoldTextFieldStyle(),
                      ),
                      SizedBox(height: 10),
                      Text(
                        item['itemdetails'] ?? '',
                        style: TextWidget.LightTextFieldStyle(),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Delivery Time: ${item['delivery_time'] != null ? formatDeliveryTime(item['delivery_time']) : "Not specified"}',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Text(
                            "Price: \$${item['itemprice'] ?? '0.0'}",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: ElevatedButton(
                          onPressed: () async {
                            final updatedItem = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditItem(item: item),
                              ),
                            );
                            if (updatedItem != null) {
                              setState(() {
                                item = updatedItem;
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                          ),
                          child: Text(
                            "Edit",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: ElevatedButton(
                          onPressed: () {
                            // Show confirmation dialog before deleting
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text("Are you sure?"),
                                content: Text(
                                    "Do you really want to delete this item?"),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context); // Close dialog
                                    },
                                    child: Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context); // Close dialog
                                      deleteItem(); // Proceed with deletion
                                    },
                                    child: Text("Delete"),
                                  ),
                                ],
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                          ),
                          child: Text(
                            "Delete",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
