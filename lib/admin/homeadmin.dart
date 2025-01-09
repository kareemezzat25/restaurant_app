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
    return Scaffold(
      backgroundColor: Color(0xFFF9F9F9),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              //[Color(0xFFFF8966), Color(0xFFFF5F6D)]
              colors: [Color(0xFFFF8966), Color(0xFFFF5F6D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        centerTitle: true,
        title: const Text(
          "Fcsu Restaurant",
          style: TextStyle(
            fontFamily: "Hurricane",
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Search by Item Name or Category",
                prefixIcon: Icon(Icons.search), // Search icon
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0), // Rounded corners
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
                                margin: const EdgeInsets.all(8.0),
                                padding: const EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      blurRadius: 6,
                                      offset: const Offset(0, 4),
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
                      ),
          ],
        ),
      ),
    );
  }
}
