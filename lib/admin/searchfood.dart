import 'package:flutter/material.dart';
import 'package:resturant_app/admin/itemdetailsAdmin.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SearchFoodItem extends StatefulWidget {
  const SearchFoodItem({super.key});

  @override
  State<SearchFoodItem> createState() => _SearchFoodItemState();
}

class _SearchFoodItemState extends State<SearchFoodItem> {
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
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.black,
          title: const Text(
            "Search Food Items",
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
              SizedBox(height: 20),
              // Show loading indicator or results based on the state
              isLoading
                  ? CircularProgressIndicator() // Show loading indicator while searching
                  : searchResults.isEmpty
                      ? Text("No items found.")
                      : Expanded(
                          child: ListView.builder(
                            itemCount: searchResults.length,
                            itemBuilder: (context, index) {
                              final item = searchResults[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ItemDetails(itemId: item['id']),
                                    ),
                                  );
                                },
                                child: Card(
                                  margin: EdgeInsets.symmetric(vertical: 8),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.all(10),
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        item['itemimage'] ??
                                            '', // If the item image is null, the empty string will be used
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          // Fallback image in case of error or null image
                                          return Image.asset(
                                            'images/salad2.png', // Fallback asset image
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.fill,
                                          );
                                        },
                                      ),
                                    ),
                                    title: Text(item['itemname']),
                                    subtitle: Container(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['category'], // Item name
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Price: \$${item['itemprice']}', // Item price
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(height: 4),
                                          // Show first 2 lines of details
                                          Text(
                                            item['itemdetails'] ?? '',
                                            maxLines: 2, // Limit to 2 lines
                                            overflow: TextOverflow
                                                .ellipsis, // Add ellipsis for overflow
                                          ),
                                        ],
                                      ),
                                    ),
                                    trailing: SizedBox
                                        .shrink(), // No edit or delete icons shown
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
