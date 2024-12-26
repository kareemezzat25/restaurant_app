import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class History extends StatefulWidget {
  String? userid;
  History({super.key, this.userid});

  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  List<Map<String, dynamic>> historyItems = [];
  double totalAmount = 0.0;
  bool isLoading = true;
  String? userRole;

  @override
  void initState() {
    super.initState();
    fetchHistoryItems();
  }

  Future<void> fetchHistoryItems() async {
    setState(() {
      isLoading = true;
    });

    final currentUser = Supabase.instance.client.auth.currentUser;

    if (currentUser != null) {
      try {
        String? userIdToFetch = widget.userid ?? currentUser.id;
        print("userid first:$userIdToFetch");

        final userResponse = await Supabase.instance.client
            .from('users')
            .select('role')
            .eq('email', currentUser.email!)
            .single();

        final userRoleFetched = userResponse["role"];
        if (!mounted)
          return; // Check if the widget is still mounted before calling setState

        setState(() {
          userRole = userRoleFetched;
        });

        print("user role:$userRoleFetched");
        print("userid:$userIdToFetch  || userid:${widget.userid}");

        late final historyResponse;
        if (userRoleFetched == 'admin' && widget.userid != null) {
          userIdToFetch = widget.userid;
          final useridauthResponse = await Supabase.instance.client
              .from('users')
              .select('idAuth')
              .eq('user_id', userIdToFetch!)
              .single();
          final userIdAuth = useridauthResponse['idAuth'] as String?;

          historyResponse = await Supabase.instance.client
              .from('history')
              .select('itemname,quantity,totalprice,created_at')
              .eq('user_id', userIdAuth!);
        } else {
          historyResponse = await Supabase.instance.client
              .from('history')
              .select('itemname,quantity,totalprice,created_at')
              .eq('user_id', currentUser.id);
        }

        if (historyResponse != null && historyResponse.isNotEmpty) {
          List<Map<String, dynamic>> items =
              List<Map<String, dynamic>>.from(historyResponse);

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

              item['formatted_created_at'] = DateFormat('yyyy-MM-dd–h:mm a')
                  .format(createdAt); // format h m am/pm
            }
          }

          if (!mounted)
            return; // Check if the widget is still mounted before calling setState

          setState(() {
            historyItems = items;
            totalAmount = historyItems.fold(
              0.0,
              (sum, item) => sum + (item['totalprice'] ?? 0.0),
            );
            isLoading = false;
          });
        } else {
          if (!mounted)
            return; // Check if the widget is still mounted before calling setState

          setState(() {
            historyItems = [];
            isLoading = false;
          });
        }
      } catch (error) {
        if (!mounted)
          return; // Check if the widget is still mounted before calling setState

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching history: $error")),
        );
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void showEnterAmountDialog(Map<String, dynamic> user) {
    final TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Enter Amount for ${user['username'] ?? 'User'}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  labelStyle: TextStyle(color: Colors.grey[600]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(amountController.text.trim());
                if (amount != null && amount > 0) {
                  try {
                    final currentWallet = user['wallet'] ?? 0.0;
                    final updatedWallet = currentWallet + amount;

                    await Supabase.instance.client.from('users').update(
                        {'wallet': updatedWallet}).eq('email', user['email']);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Successfully added \$${amount.toStringAsFixed(2)} to ${user['username']}\'s wallet.',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );

                    setState(() {
                      user['wallet'] = updatedWallet;
                    });

                    Navigator.pop(context);
                  } catch (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Failed to update wallet. Please try again.',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid amount.'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Add',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
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
                                    "Order Date: ${item['formatted_created_at'] ?? 'N/A'}",
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    if (userRole == 'admin')
                      Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: ElevatedButton(
                          onPressed: () async {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 24),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(
                            "Add Money",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
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
