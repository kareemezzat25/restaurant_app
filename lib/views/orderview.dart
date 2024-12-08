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
        title: const Text("Cart"),
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
                      const Text("No item in cart.",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
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
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child:
                                  const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (direction) {
                              deleteItem(index);
                            },
                            child: Card(
                              margin: const EdgeInsets.all(10),
                              child: ListTile(
                                leading: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.grey, width: 2),
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                          item['item_image'] ?? ''),
                                      fit: BoxFit.cover,
                                    ),
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
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove),
                                      onPressed: () {
                                        updateQuantity(
                                            index, (item['quantity'] ?? 1) - 1);
                                      },
                                    ),
                                    Text("${item['quantity'] ?? 0}"),
                                    IconButton(
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
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                    labelText: "Discount Code",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {
                                  // Logic to apply discount
                                },
                                child: const Text("Apply"),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Total: \$${total.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black),
                            onPressed: () {
                              // Handle checkout
                            },
                            child: const Text(
                              "CHECKOUT",
                              style: TextStyle(
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
