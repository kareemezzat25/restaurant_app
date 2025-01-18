import 'dart:math';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class History extends StatefulWidget {
  String? userEmail;
  History({super.key, this.userEmail});

  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  List<Map<String, dynamic>> historyItems = [];
  double totalAmount = 0.0;
  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasMore = true;
  int limit = 5;
  int offset = 0;
  String? userRole;

  @override
  void initState() {
    super.initState();
    fetchHistoryItems();
  }

  Future<void> fetchHistoryItems({bool loadMore = false}) async {
    if (loadMore) {
      if (!hasMore) return;
      Future.delayed(Duration.zero, () {
        if (mounted) {
          setState(() {
            isLoadingMore = true;
          });
        }
      });
    } else {
      setState(() {
        isLoading = true;
        offset = 0;
        historyItems.clear();
      });
    }
    try {
      final currentUser = Supabase.instance.client.auth.currentUser;

      if (currentUser != null) {
        String? userEmailToFetch = widget.userEmail ?? currentUser.email;

        final userResponse = await Supabase.instance.client
            .from('users')
            .select('role,total_amount')
            .eq('email', currentUser.email!)
            .single();

        final userRoleFetched = userResponse["role"];
        print("User role:$userRoleFetched");
        userRole = userRoleFetched;
        double totalAmountFetched =
            double.parse(userResponse['total_amount'].toString());

        late final historyResponse;
        if (userRoleFetched == 'admin' && widget.userEmail != null) {
          userEmailToFetch = widget.userEmail;
          final useridauthResponse = await Supabase.instance.client
              .from('users')
              .select('idAuth,total_amount')
              .eq('email', widget.userEmail!)
              .single();

          totalAmountFetched =
              double.parse(useridauthResponse['total_amount'].toString());
          final userIdAuth = useridauthResponse['idAuth'] as String?;

          historyResponse = await Supabase.instance.client
              .from('history')
              .select('itemname,quantity,totalprice,created_at')
              .eq('user_id', userIdAuth!)
              .range(offset, offset + limit - 1);
        } else {
          historyResponse = await Supabase.instance.client
              .from('history')
              .select('itemname,quantity,totalprice,created_at')
              .eq('user_id', currentUser.id)
              .range(offset, offset + limit - 1);
        }

        List<Map<String, dynamic>> items = [];
        if (historyResponse != null && historyResponse.isNotEmpty) {
          items = List<Map<String, dynamic>>.from(historyResponse);

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
              createdAt = createdAt.toLocal();

              item['formatted_created_at'] =
                  DateFormat('yyyy-MM-dd – h:mm a').format(createdAt);
            }
          }
        }
        // Delay the setState call to the next frame
        Future.delayed(Duration.zero, () {
          if (mounted) {
            setState(() {
              historyItems.addAll(items);
              totalAmount = totalAmountFetched;
              hasMore = items.length == limit;
            });
          }
        });
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching history: $error")),
      );
    } finally {
      // Delay this as well
      Future.delayed(Duration.zero, () {
        if (mounted) {
          setState(() {
            isLoading = false;
            isLoadingMore = false;
            offset += limit;
          });
        }
      });
    }
  }

  void showAddDiscountCodeDialog(Map<String, dynamic> user) {
    final TextEditingController percentageController = TextEditingController();
    String? errorText;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: Colors.white,
              title: Text(
                'Add Discount Code for ${user['username']}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: percentageController,
                    keyboardType: TextInputType.number,
                    onChanged: (text) {
                      setState(() {
                        // Clear error text when user starts typing
                        if (text.isEmpty) {
                          errorText = 'Please enter percentage';
                        } else {
                          errorText = null;
                        }
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Discount Percentage',
                      hintText: 'Enter discount percentage',
                      labelStyle: TextStyle(color: Colors.blueGrey),
                      hintStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                      ),
                    ),
                  ),
                  if (errorText != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        errorText!,
                        style: TextStyle(color: Colors.red, fontSize: 12),
                        overflow: TextOverflow
                            .visible, // Ensure full message is visible
                      ),
                    ),
                ],
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final percentage = percentageController.text.trim();

                        // Check if the text is empty or invalid
                        if (percentage.isEmpty) {
                          setState(() {
                            errorText = 'Please enter percentage';
                          });
                        } else {
                          final parsedPercentage = double.tryParse(percentage);

                          if (parsedPercentage == null ||
                              parsedPercentage <= 0 ||
                              parsedPercentage >= 100) {
                            setState(() {
                              errorText =
                                  'Please enter a valid percentage between 1 and 100';
                            });
                          } else {
                            setState(() {
                              errorText = null; // Clear error text
                            });

                            final promoCode = generatePromoCode();
                            final userId = user['idAuth'];

                            try {
                              await Supabase.instance.client
                                  .from('discount_codes')
                                  .insert({
                                'user_id': userId,
                                'code': promoCode,
                                'discount_percentage': parsedPercentage,
                                'is_used': false,
                                'created_at': DateTime.now().toIso8601String(),
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Discount Code "$promoCode" added for ${user['username']}!'),
                                  backgroundColor: Colors.green,
                                ),
                              );

                              Navigator.pop(context);
                            } catch (error) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Error adding discount code: $error'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
                      },
                      child: Text(
                        'Add',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  String generatePromoCode() {
    final random = Random();
    return List.generate(6, (index) => random.nextInt(10)).join();
  }

  void showEnterAmountDialog(Map<String, dynamic> user) {
    final TextEditingController amountController = TextEditingController();
    String? errorText; // Track error for the amount field

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Enter Amount for ${user['username'] ?? 'User'}',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    onChanged: (text) {
                      setState(() {
                        // Clear error text when user starts typing
                        if (text.isEmpty) {
                          errorText = 'Please enter amount';
                        } else {
                          errorText = null;
                        }
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      labelStyle: TextStyle(color: Colors.blueGrey),
                      hintStyle: TextStyle(color: Colors.grey),
                      hintText: 'Enter Amount',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.blueGrey, width: 1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  if (errorText != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        errorText!,
                        style: TextStyle(color: Colors.red, fontSize: 12),
                        overflow: TextOverflow
                            .visible, // Ensure full message is visible
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
                    final amount =
                        double.tryParse(amountController.text.trim());
                    if (amount != null && amount > 0) {
                      try {
                        final currentWallet = user['wallet'] ?? 0.0;
                        final updatedWallet = currentWallet + amount;

                        await Supabase.instance.client
                            .from('users')
                            .update({'wallet': updatedWallet}).eq(
                                'email', user['email']);

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
                      setState(() {
                        errorText = 'Please enter a valid amount';
                      });
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF8966), Color(0xFFFF5F6D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          "Order History",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false, // Removes the back arrow
      ),
      backgroundColor: Colors.white, // Set background color to white
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF4A90E2)),
            )
          : historyItems.isEmpty
              ? const Center(
                  child: Text(
                    "No history found.",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(10),
                        itemCount: historyItems.length + 1,
                        itemBuilder: (context, index) {
                          if (index < historyItems.length) {
                            final item = historyItems[index];
                            return Card(
                              elevation: 6,
                              // Card elevation
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                    color: Color(0xFFFF8966).withOpacity(0.3),
                                    width: 1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              color: Colors.white, // Card color
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        item['itemimage'] ?? '',
                                        width: 70,
                                        height: 70,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error,
                                                stackTrace) =>
                                            const Icon(Icons.image, size: 70),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['itemname'] ?? 'Unknown Item',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            "Quantity: ${item['quantity']}",
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          Text(
                                            "Total: \$${item['totalprice']?.toStringAsFixed(2) ?? '0.00'}",
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          Text(
                                            "Date: ${item['formatted_created_at'] ?? 'N/A'}",
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          } else if (hasMore && !isLoadingMore) {
                            fetchHistoryItems(loadMore: true);
                            return const Center(
                                child: CircularProgressIndicator());
                          } else {
                            return const SizedBox();
                          }
                        },
                      ),
                    ),
                    if (userRole == 'admin')
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFFF6E73),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16, horizontal: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () async {
                                  final userResponse = await Supabase
                                      .instance.client
                                      .from('users')
                                      .select()
                                      .eq('email', widget.userEmail!)
                                      .single();

                                  if (userResponse != null) {
                                    showAddDiscountCodeDialog(userResponse);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("User not found."),
                                      ),
                                    );
                                  }
                                },
                                child: const Text("DiscountCode",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500)),
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  final userResponse = await Supabase
                                      .instance.client
                                      .from('users')
                                      .select()
                                      .eq('email', widget.userEmail!)
                                      .single();

                                  if (userResponse != null) {
                                    showEnterAmountDialog(userResponse);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("User not found."),
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFFF6E73),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16, horizontal: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  "Add Money",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total Amount:",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "\$${totalAmount.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
