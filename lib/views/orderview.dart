import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Order extends StatefulWidget {
  const Order({super.key});

  @override
  State<Order> createState() => _OrderState();
}

class _OrderState extends State<Order> {
  List<Map<String, dynamic>> cartItems = [];
  double total = 0.0;
  bool isLoading = true;
  TextEditingController discountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  Future<void> fetchCartItems() async {
    setState(() {
      isLoading = true;
    });

    final user = Supabase.instance.client.auth.currentUser;

    if (user != null) {
      final response = await Supabase.instance.client
          .from('cart')
          .select()
          .eq('user_id', user.id);

      if (response != null) {
        setState(() {
          cartItems = List<Map<String, dynamic>>.from(response);

          for (var item in cartItems) {
            item['quantity'] ??= 1;
            item['total_price'] ??= item['itemprice'] * item['quantity'];
          }
          calculateTotal();
          isLoading = false;
        });
      }
    }
  }

  void calculateTotal() {
    total = cartItems.fold(0.0, (sum, item) {
      final itemTotalPrice = item['total_price'] ?? 0.0;
      return sum + itemTotalPrice;
    });
    setState(() {});
  }

  Future<void> handleCheckout() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    try {
      // Fetch the user's wallet balance
      final userResponse = await Supabase.instance.client
          .from('users')
          .select('wallet')
          .eq('email', user.email!)
          .single();

      if (userResponse == null || userResponse['wallet'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to fetch wallet balance")),
        );
        return;
      }

      final walletBalance = userResponse['wallet'];

      if (walletBalance < total) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Insufficient wallet balance")),
        );
        return;
      }

      final remainingBalance = walletBalance - total;

      // Show confirmation dialog with discount code input
      showDialog(
        context: context,
        barrierDismissible: false, // Prevent dismissing by tapping outside
        builder: (BuildContext context) {
          TextEditingController discountController = TextEditingController();
          double discount = 0.0;
          return Stack(
            children: [
              Opacity(
                opacity: 0.9,
                child: Container(
                  color: Colors.black.withOpacity(0.5), // Dim the background
                ),
              ),
              Center(
                child: AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: const Text(
                    "Confirm Checkout",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "The total price is \$${total.toStringAsFixed(2)}.\n"
                        "Wallet after deduction: \$${remainingBalance.toStringAsFixed(2)}.\n"
                        "Do you want to proceed?",
                        style:
                            const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: discountController,
                        decoration: InputDecoration(
                          hintText: "Enter Discount Code",
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(false); // Close dialog
                      },
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final enteredCode = discountController.text.trim();
                        if (enteredCode.isNotEmpty) {
                          // Apply the discount code
                          await applyPromoCode(enteredCode, discountController);
                        }
                        Navigator.of(context).pop(true); // Proceed
                        await processCheckout(user, remainingBalance);
                      },
                      child: const Text(
                        "OK",
                        style: TextStyle(color: Colors.green, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> applyPromoCode(
      String enteredCode, TextEditingController discountController) async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) return;

    final response = await Supabase.instance.client
        .from('discount_codes')
        .select()
        .eq('user_id', user.id)
        .eq('code', enteredCode)
        .eq('is_used', false)
        .maybeSingle();

    if (response != null) {
      final discountPercentage = response['discount_percentage'];

      // Apply discount on cart items
      setState(() {
        for (var item in cartItems) {
          item['total_price'] = item['itemprice'] *
              item['quantity'] *
              (1 - (discountPercentage / 100));
        }
        calculateTotal();
      });

      await Supabase.instance.client
          .from('discount_codes')
          .update({'is_used': true}).eq('id', response['id']);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text("Promo code applied! You saved $discountPercentage%")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid or used promo code")),
      );
    }
  }

  Future<void> updateQuantity(int index, int newQuantity) async {
    final item = cartItems[index];

    if (newQuantity > 0) {
      final newTotalPrice = item['itemprice'] * newQuantity;

      await Supabase.instance.client.from('cart').update({
        'quantity': newQuantity,
        'total_price': newTotalPrice,
      }).eq('id', item['id']);

      setState(() {
        cartItems[index]['quantity'] = newQuantity;
        cartItems[index]['total_price'] = newTotalPrice;
      });
    } else {
      if (newQuantity == 1) {
        return;
      }
    }

    calculateTotal();
  }

  Future<void> processCheckout(User user, double remainingBalance) async {
    try {
      // Deduct the total price from wallet
      await Supabase.instance.client.from('users').update({
        'wallet': remainingBalance,
      }).eq('email', user.email!);

      for (var item in cartItems) {
        await Supabase.instance.client.from('history').insert({
          'user_id': user.id,
          'itemname': item['item_name'],
          'quantity': item['quantity'],
          'totalprice': item['total_price'],
        });
      }

      // Clear the cart
      await Supabase.instance.client
          .from('cart')
          .delete()
          .eq('user_id', user.id);

      setState(() {
        cartItems.clear();
        total = 0.0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Checkout successful")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> deleteItem(int index) async {
    final item = cartItems[index];

    await Supabase.instance.client.from('cart').delete().eq('id', item['id']);

    cartItems.removeAt(index);
    calculateTotal();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text("Cart",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22)),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('images/empty-cart.png', height: 100),
                      const SizedBox(height: 10),
                      const Text("Your cart is empty!",
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          return Dismissible(
                            key: Key(item['id'].toString()),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.red,
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child:
                                  const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (direction) {
                              deleteItem(index);
                            },
                            child: Card(
                              elevation: 4,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              child: ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    item['item_image'] ?? '',
                                    width: 70,
                                    height: 80,
                                    fit: BoxFit.fill,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(Icons.error,
                                                color: Colors.red),
                                  ),
                                ),
                                title: Text(
                                  item['item_name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Text(
                                  "\$${item['total_price']?.toStringAsFixed(2) ?? '0.00'}",
                                  style: const TextStyle(
                                    color: Color(0xFFCC4C5A),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      color: Color(0xFFCC4C5A),
                                      icon: const Icon(Icons.remove),
                                      onPressed: () {
                                        updateQuantity(
                                            index, (item['quantity'] ?? 1) - 1);
                                      },
                                    ),
                                    Text("${item['quantity'] ?? 0}"),
                                    IconButton(
                                      color: Color(0xFFCC4C5A),
                                      icon: const Icon(Icons.add),
                                      onPressed: () {
                                        updateQuantity(
                                            index, (item['quantity'] ?? 0) + 1);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          /*Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: discountController,
                                  decoration: InputDecoration(
                                    hintText: "Enter Discount Code",
                                    filled: true,
                                    fillColor: Colors.grey[200],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {
                                  final enteredCode =
                                      discountController.text.trim();
                                  print("entered code : $enteredCode");
                                  if (enteredCode.isNotEmpty) {
                                    applyPromoCode(enteredCode);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFFFF6E73),
                                    foregroundColor: Colors.white),
                                child: const Text("Apply",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),*/
                          const SizedBox(height: 10),
                          Text(
                            textAlign: TextAlign.center,
                            "Total: \$${total.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor: Color(0xFFFF6E73),
                            ),
                            onPressed: handleCheckout,
                            child: const Text(
                              "CHECKOUT",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
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
