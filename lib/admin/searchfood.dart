import 'package:flutter/material.dart';
import 'package:resturant_app/admin/itemdetailsAdmin.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FoodItems extends StatefulWidget {
  const FoodItems({super.key});

  @override
  State<FoodItems> createState() => _FoodItemsState();
}

class _FoodItemsState extends State<FoodItems> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> allItems = []; // Store all items
  List<Map<String, dynamic>> searchResults = []; // Store filtered items
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchAllItems(); // Fetch all items when the page loads
  }

  // Function to fetch all items from the database
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
          searchResults = [];
        });
      } else {
        print("Fetched all items: $response");
        setState(() {
          allItems = List<Map<String, dynamic>>.from(response);
          searchResults = List<Map<String, dynamic>>.from(
              response); // Display all initially
        });
      }
    } catch (e) {
      print("Error fetching items: $e");
      setState(() {
        allItems = [];
        searchResults = [];
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  // Function to filter the items based on the search query
  void searchItems(String query) {
    if (query.isEmpty) {
      setState(() {
        searchResults =
            List<Map<String, dynamic>>.from(allItems); // Reset to all items
      });
      return;
    }

    setState(() {
      searchResults = allItems.where((item) {
        final itemName = item['itemname']?.toLowerCase() ?? '';
        final category = item['category']?.toLowerCase() ?? '';
        final searchQuery = query.toLowerCase();

        return itemName.contains(searchQuery) || category.contains(searchQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.black,
          centerTitle: true,
          title: const Text(
            "Food Items",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Search bar with your preferred styling
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: "Search by Item Name or Category",
                  prefixIcon: Icon(Icons.search), // Search icon
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(16.0), // Rounded corners
                  ),
                ),
                onChanged: searchItems, // Trigger search on text change
              ),
              SizedBox(height: 10),
              // Show loading indicator or results based on the state
              isLoading
                  ? CircularProgressIndicator() // Show loading indicator while searching
                  : searchResults.isEmpty
                      ? Column(
                          children: [
                            Image.asset(
                              "images/noitem.png",
                              width: MediaQuery.of(context).size.width / 2,
                              height: MediaQuery.of(context).size.height / 3,
                            ),
                            Text(
                              "No items found.",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        )
                      : Expanded(
                          child: ListView.builder(
                            itemCount: searchResults.length,
                            itemBuilder: (context, index) {
                              final item = searchResults[index];
                              return GestureDetector(
                                onTap: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ItemDetails(itemId: item['id']),
                                    ),
                                  );
                                  if (result != null) {
                                    fetchAllItems();
                                  }
                                },
                                child: Container(
                                  margin: EdgeInsets.symmetric(vertical: 8),
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
                                          fit: BoxFit.fill,
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
                                              item['itemname'] ??
                                                  'Unknown Name',
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
                        ),
            ],
          ),
        ),
      ),
    );
  }
}
