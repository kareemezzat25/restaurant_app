import 'package:flutter/material.dart';
import 'package:resturant_app/widgets/textwidget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FoodDetails extends StatefulWidget {
  final Map<String, dynamic> item; // Accept item details

  const FoodDetails({super.key, required this.item});

  @override
  State<FoodDetails> createState() => _DetailsState();
}

class _DetailsState extends State<FoodDetails> {
  int counter = 1;

  Future<void> addToCart(
      Map<String, dynamic> item, int quantity, double price) async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      _showSnackBar("Please log in to add items to the cart.", Colors.red);
      return;
    }

    try {
      final addFoodToCart = {
        "user_id": user.id,
        "item_name": item['itemname'] ?? '',
        "item_category": item['category'] ?? '',
        "quantity": quantity,
        "total_price": quantity * price,
        "item_image": item['itemimage'] ?? '',
        "itemprice": item['itemprice'] ?? 0
      };

      final response =
          await Supabase.instance.client.from('cart').insert(addFoodToCart);

      if (response == null) {
        _showSnackBar("Food added to cart", Colors.green);
      } else {
        _showSnackBar(
            "Failed to add item: ${response.error!.message}", Colors.red);
      }
    } catch (error) {
      _showSnackBar("An error occurred: $error", Colors.red);
    }
  }

  String formatDeliveryTime(int minutes) {
    if (minutes < 60) {
      return '$minutes minutes';
    } else {
      final hours = minutes ~/ 60; // Calculate hours
      final remainingMinutes = minutes % 60; // Remaining minutes
      if (remainingMinutes == 0) {
        return '$hours hours';
      } else {
        return '$hours hours and $remainingMinutes minutes';
      }
    }
  }

  void _showSnackBar(String message, Color backgroundcolor) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: backgroundcolor,
      content: Text(
        message,
        style: const TextStyle(fontSize: 18.0),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final price = item['itemprice'] ?? 0.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back_ios_new_outlined,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rounded image inside a container
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    item['itemimage'] ?? '',
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 2.5,
                    fit: BoxFit.fill, // Show the full image
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.error, color: Colors.red),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['itemname'] ?? '',
                        style: TextWidget.boldTextFieldStyle(),
                      ),
                      Text(
                        item['category'] ?? '',
                        style: TextWidget.semiBoldTextFieldStyle(),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (counter > 1) --counter;
                          setState(() {});
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.remove, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Text("$counter",
                          style: TextWidget.semiBoldTextFieldStyle()),
                      const SizedBox(width: 20),
                      GestureDetector(
                        onTap: () {
                          counter++;
                          setState(() {});
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.add, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                item['itemdetails'] ?? 'No details available',
                style: TextWidget.LightTextFieldStyle(),
              ),
              const SizedBox(height: 10),
              Text(
                'Delivery Time: ${item['delivery_time'] != null ? formatDeliveryTime(item['delivery_time']) : "Not specified"}',
                style: TextWidget.semiBoldTextFieldStyle(),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Total price",
                            style: TextWidget.semiBoldTextFieldStyle()),
                        Text("\$${(counter * price).toStringAsFixed(2)}",
                            style: TextWidget.semiBoldTextFieldStyle()),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        addToCart(widget.item, counter, price.toDouble());
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width / 2,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.black,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              "Add to cart",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontFamily: 'Pappions',
                              ),
                            ),
                            SizedBox(width: 10),
                            Icon(Icons.shopping_cart_outlined,
                                color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
