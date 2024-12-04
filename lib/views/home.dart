import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:resturant_app/widgets/showitemButton.dart'; // Assuming it's a custom widget
import 'package:resturant_app/widgets/textwidget.dart'; // Assuming it's a custom widget

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeState();
}

class _HomeState extends State<HomeView> {
  List<Map<String, dynamic>> first6Items = [];
  List<Map<String, dynamic>> next12Items = [];
  bool isLoading = true; // New loading state

  bool icecream = false;
  bool salad = false;
  bool burger = false;
  bool pizza = false;

  @override
  void initState() {
    super.initState();
    // Fetch data and update loading state
    fetchFirst6Items().then((items) {
      setState(() {
        first6Items = items;
        isLoading = false; // Data fetching completed
      });
    });
    fetchNext12Items().then((items) {
      setState(() {
        next12Items = items;
      });
    });
  }

  Future<List<Map<String, dynamic>>> fetchFirst6Items() async {
    try {
      final response = await Supabase.instance.client
          .from('item')
          .select('*')
          .range(0, 5); // Fetch first 6 items (index 0 to 5)

      if (response == null || response.isEmpty) {
        print("No items found in the database.");
        return [];
      }

      print("Fetched first 6 items: $response");
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      print("Error fetching data for first 6 items: $error");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchNext12Items() async {
    try {
      final response = await Supabase.instance.client
          .from('item')
          .select('*')
          .range(6, 17); // Fetch next 12 items (index 6 to 17)

      if (response == null || response.isEmpty) {
        print("No next 12 items found.");
        return [];
      }

      print("Fetched next 12 items: $response");
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      print("Error fetching data for next 12 items: $error");
      return [];
    }
  }

  String buildImageUrl(String fileName) {
    // Generate the public URL using Supabase's storage method
    final url = Supabase.instance.client.storage
        .from('food_images') // Bucket name
        .getPublicUrl(fileName);
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          "Fcsu_resturant",
          style: TextStyle(
            fontFamily: "Hurricane",
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [Icon(Icons.search)],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(left: 10, bottom: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Text("Delicious Food",
                      style: TextWidget.HeadLineTextFieldStyle()),
                  Text("Discover and get Great Food",
                      style: TextWidget.LightTextFieldStyle()),
                  SizedBox(height: 20),
                  Container(
                    margin: EdgeInsets.only(right: 10),
                    child: showItem(),
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),

            // First 6 items display
            isLoading
                ? Center(
                    child:
                        CircularProgressIndicator()) // Show loading indicator
                : first6Items.isEmpty
                    ? Text(
                        "Less than 6 items available.") // Show this if no items
                    : Container(
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: first6Items.length,
                          itemBuilder: (context, index) {
                            final item = first6Items[index];
                            final imageUrl = buildImageUrl(item['itemimage']);

                            return Container(
                              margin: EdgeInsets.symmetric(vertical: 8),
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      imageUrl,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Icon(Icons.error,
                                            color: Colors.red);
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['itemname'],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          item['itemdetails'] ?? '',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          "\$${item['itemprice']}",
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
          ],
        ),
      ),
    );
  }

  Widget showItem() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ShowItemButton(
          imagePath: "images/ice-cream.png",
          itemName: "Ice Cream",
          isSelected: icecream,
          onTap: () {
            setState(() {
              icecream = true;
              salad = false;
              pizza = false;
              burger = false;
            });
          },
        ),
        ShowItemButton(
          imagePath: "images/burger.png",
          itemName: "Burger",
          isSelected: burger,
          onTap: () {
            setState(() {
              burger = true;
              salad = false;
              pizza = false;
              icecream = false;
            });
          },
        ),
        ShowItemButton(
          imagePath: "images/pizza.png",
          itemName: "Pizza",
          isSelected: pizza,
          onTap: () {
            setState(() {
              pizza = true;
              salad = false;
              burger = false;
              icecream = false;
            });
          },
        ),
        ShowItemButton(
          imagePath: "images/salad.png",
          itemName: "Salad",
          isSelected: salad,
          onTap: () {
            setState(() {
              salad = true;
              pizza = false;
              burger = false;
              icecream = false;
            });
          },
        ),
      ],
    );
  }
}
