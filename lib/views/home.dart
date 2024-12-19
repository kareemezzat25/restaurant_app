import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:resturant_app/widgets/showitemButton.dart';
import 'package:resturant_app/widgets/textwidget.dart';
import 'package:resturant_app/views/fooddetails.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeState();
}

class _HomeState extends State<HomeView> {
  List<Map<String, dynamic>> allItems = [];
  List<Map<String, dynamic>> filteredItems = [];
  bool isLoading = true;
  String selectedCategory = "";

  @override
  void initState() {
    super.initState();
    fetchAllItems();
  }

  Future<void> fetchAllItems() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await Supabase.instance.client.from('item').select('*');

      if (response == null || response.isEmpty) {
        print("No items found.");
        setState(() {
          allItems = [];
        });
      } else {
        setState(() {
          allItems = List<Map<String, dynamic>>.from(response);
          filteredItems = allItems;
        });
      }
    } catch (e) {
      print("Error fetching items: $e");
      setState(() {
        allItems = [];
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  void filterItemsByCategory(String category) {
    setState(() {
      selectedCategory = category;
      filteredItems = category.isEmpty
          ? allItems
          : allItems.where((item) => item['category'] == category).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
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
              margin: EdgeInsets.only(left: 10, bottom: 10),
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
                    child: showItem(),
                  ),
                ],
              ),
            ),
            isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : filteredItems.isEmpty
                    ? Text("No items found for this category.")
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FoodDetails(
                                    item: item, // Pass item details
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 8),
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      item['itemimage'] ?? '',
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
                                          item['itemname'] ?? 'Unknown Name',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          item['category'] ??
                                              'Unknown Category',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          "\$${item['itemprice']?.toStringAsFixed(2) ?? 'N/A'}",
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          item['itemdetails'] ?? '',
                                          maxLines: 2, // Limit to 2 lines
                                          overflow: TextOverflow
                                              .ellipsis, // Ellipsis for overflow
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ],
        ),
      ),
    );
  }

  Widget showItem() {
    return CarouselSlider(
      options: CarouselOptions(
        height: 100,
        // Adjust height as needed
        viewportFraction: 0.38,
        autoPlay: false,
      ),
      items: [
        ShowItemButton(
          imagePath: "images/ice-cream.png",
          itemName: "Ice-cream",
          isSelected: selectedCategory == "Ice-cream",
          onTap: () {
            filterItemsByCategory("Ice-cream");
          },
        ),
        ShowItemButton(
          imagePath: "images/burger.png",
          itemName: "Burger",
          isSelected: selectedCategory == "Burger",
          onTap: () {
            filterItemsByCategory("Burger");
          },
        ),
        ShowItemButton(
          imagePath: "images/pizza.png",
          itemName: "Pizza",
          isSelected: selectedCategory == "Pizza",
          onTap: () {
            filterItemsByCategory("Pizza");
          },
        ),
        ShowItemButton(
          imagePath: "images/salad.png",
          itemName: "Salad",
          isSelected: selectedCategory == "Salad",
          onTap: () {
            filterItemsByCategory("Salad");
          },
        ),
        ShowItemButton(
          imagePath: "images/apple-juice.png",
          itemName: "juices",
          isSelected: selectedCategory == "juices",
          onTap: () {
            filterItemsByCategory("juices");
          },
        ),
        ShowItemButton(
          imagePath: "images/sandwich.png",
          itemName: "Sandwiches",
          isSelected: selectedCategory == "Sandwiches",
          onTap: () {
            filterItemsByCategory("Sandwiches");
          },
        ),
        ShowItemButton(
          imagePath: "images/breakfast.png",
          itemName: "Breakfast",
          isSelected: selectedCategory == "Breakfast",
          onTap: () {
            filterItemsByCategory("Breakfast");
          },
        ),
        ShowItemButton(
          imagePath: "images/shawarma.png",
          itemName: "Shawarma",
          isSelected: selectedCategory == "Shawarma",
          onTap: () {
            filterItemsByCategory("Shawarma");
          },
        ),
        ShowItemButton(
          imagePath: "images/steak.png",
          itemName: "Steak",
          isSelected: selectedCategory == "Steak",
          onTap: () {
            filterItemsByCategory("Steak");
          },
        ),
        ShowItemButton(
          imagePath: "images/fried-chicken.png",
          itemName: "FriedChicken",
          isSelected: selectedCategory == "FriedChicken",
          onTap: () {
            filterItemsByCategory("FriedChicken");
          },
        ),
        ShowItemButton(
          imagePath: "images/seafood (1).png",
          itemName: "Seafood",
          isSelected: selectedCategory == "Seafood",
          onTap: () {
            filterItemsByCategory("Seafood");
          },
        ),
        ShowItemButton(
          imagePath: "images/spaghetti.png",
          itemName: "Pastas",
          isSelected: selectedCategory == "Pastas",
          onTap: () {
            filterItemsByCategory("Pastas");
          },
        ),
        ShowItemButton(
          imagePath: "images/donut.png",
          itemName: "Desserts",
          isSelected: selectedCategory == "Desserts",
          onTap: () {
            filterItemsByCategory("Desserts");
          },
        ),
        ShowItemButton(
          imagePath: "images/hot-drink.png",
          itemName: "hot-drink",
          isSelected: selectedCategory == "hot-drink",
          onTap: () {
            filterItemsByCategory("hot-drink");
          },
        ),
      ],
    );
  }
}
