import 'package:flutter/material.dart';
import 'package:resturant_app/admin/edititemadmin.dart';
import 'package:resturant_app/widgets/textwidget.dart'; // Ensure you have this imported
import 'package:supabase_flutter/supabase_flutter.dart';

class ItemDetails extends StatefulWidget {
  final int itemId; // Use the item ID to fetch the item from the database

  const ItemDetails({super.key, required this.itemId});

  @override
  State<ItemDetails> createState() => _DetailsState();
}

class _DetailsState extends State<ItemDetails> {
  Map<String, dynamic> item = {}; // Store the item details
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchItemDetails(); // Fetch item details when the page is opened
  }

  // Function to fetch item details from the database using the itemId
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
        // Handle case when item is not found
        print("Item not found.");
      }
    } catch (e) {
      print("Error fetching item: $e");
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator()) // Show loading while fetching
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 18, left: 8.0, right: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display the image or fallback image if not found
                    Image.network(
                      item['itemimage'] ?? '',
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height / 3,
                      fit: BoxFit.fill,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'images/salad2.png', // Fallback asset image
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height / 3,
                          fit: BoxFit.fill,
                        );
                      },
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
                    Row(
                      children: [
                        Text(
                          "Price: \$${item['itemprice'] ?? '0.0'}",
                          style: TextWidget.semiBoldTextFieldStyle(),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    // Edit and Delete buttons
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                        onPressed: () {
                          // Implement edit functionality here
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditItem(item: item),
                            ),
                          );
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
                          // Implement delete functionality here
                          print('Delete item: ${item['itemname']}');
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
                    SizedBox(height: 10), // Additional space at the bottom
                  ],
                ),
              ),
            ),
    );
  }
}
