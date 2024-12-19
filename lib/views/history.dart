import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  List<Map<String, dynamic>> historyItems = [];
  double totalAmount = 0.0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchHistoryItems();
  }

  Future<void> fetchHistoryItems() async {
    setState(() {
      isLoading = true;
    });

    final user = Supabase.instance.client.auth.currentUser;
    print("user:${user!.id}");

    if (user != null) {
      try {
        // Fetch history items
        final historyResponse = await Supabase.instance.client
            .from('history')
            .select('itemname,quantity,totalprice,created_at')
            .eq('user_id', user.id);

        print("historyresponse:$historyResponse");

        if (historyResponse != null && historyResponse.isNotEmpty) {
          List<Map<String, dynamic>> items =
              List<Map<String, dynamic>>.from(historyResponse);

          print("Items before:$items");
          for (var item in items) {
            final itemDetailsResponse = await Supabase.instance.client
                .from('item')
                .select('itemimage')
                .eq('itemname', item['itemname'])
                .single();

            if (itemDetailsResponse != null) {
              item['itemimage'] = itemDetailsResponse['itemimage'];
            }
            if (item['created_at'] != null) {
              DateTime createdAt = DateTime.parse(item['created_at']);
              // change time to the local time
              createdAt = createdAt.toLocal();

              item['formatted_created_at'] =
                  DateFormat('yyyy-MM-dd – HH:mm').format(createdAt);
            }
          }
          print("Items After:$items");

          setState(() {
            historyItems = items;
            totalAmount = historyItems.fold(
              0.0,
              (sum, item) => sum + (item['totalprice'] ?? 0.0),
            );
            isLoading = false;
          });
        } else {
          setState(() {
            historyItems = [];
            isLoading = false;
          });
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching history: $error")),
        );
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Text(
          "Order History",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : historyItems.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 10),
                      Text(
                        "No history found.",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: historyItems.length,
                        itemBuilder: (context, index) {
                          final item = historyItems[index];
                          return Card(
                            color: const Color.fromARGB(255, 221, 227, 233),
                            margin: const EdgeInsets.all(10),
                            child: ListTile(
                              leading: Container(
                                width: 60,
                                height: 80,
                                decoration: BoxDecoration(
                                  border: Border.all(width: 1),
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image:
                                        NetworkImage(item['itemimage'] ?? ''),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                              title: Text(
                                item['itemname'] ?? 'Unknown Item',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Quantity: ${item['quantity']}"),
                                  Text(
                                      "Total Price: \$${item['totalprice']?.toStringAsFixed(2) ?? '0.00'}"),
                                  Text(
                                    "Purchased on: ${item['formatted_created_at'] ?? 'N/A'}",
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "Total Amount: \$${totalAmount.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
