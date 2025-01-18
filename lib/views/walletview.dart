import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:resturant_app/widgets/app_constant.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

class Wallet extends StatefulWidget {
  const Wallet({super.key});

  @override
  State<Wallet> createState() => WalletState();
}

class WalletState extends State<Wallet> {
  final TextEditingController _amountController = TextEditingController();
  double walletBalance = 0.0;
  bool isLoading = true;
  Map<String, dynamic>? paymentIntent;

  @override
  void initState() {
    super.initState();
    _fetchWalletBalance();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _fetchWalletBalance() async {
    final response = await Supabase.instance.client
        .from('users')
        .select('wallet')
        .eq('email', Supabase.instance.client.auth.currentUser!.email as String)
        .single();

    if (mounted) {
      // Check if the widget is still mounted
      setState(() {
        walletBalance = (response['wallet'] ?? '0' as num).toDouble();
        isLoading = false;
      });
    }
  }

  Future<void> _addMoney(double amount) async {
    await makePayment(amount.toString());
  }

  Future<void> makePayment(String amount) async {
    try {
      paymentIntent = await createPaymentIntent(amount, 'USD');
      if (!mounted) return; // Exit if the widget is no longer mounted

      await Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
                  paymentIntentClientSecret: paymentIntent!['client_secret'],
                  style: ThemeMode.dark,
                  merchantDisplayName: 'Fcms'))
          .then((value) {});

      displayPaymentSheet(amount);
    } catch (e) {
      print('Error during payment: $e');
    }
  }

  displayPaymentSheet(String amount) async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) async {
        walletBalance += double.parse(amount);
        await Supabase.instance.client
            .from('users')
            .update({'wallet': walletBalance}).eq('email',
                Supabase.instance.client.auth.currentUser!.email as String);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully added \$${amount.toString()}')),
        );
        if (mounted) {
          // Check before calling setState
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Successfully added \$${amount.toString()}')),
          );

          setState(() {
            isLoading = true;
          });
          await _fetchWalletBalance();
        }
      }).onError((error, stackTrace) {
        print('Error is: $error $stackTrace');
      });
    } on StripeException catch (e) {
      print('Error is: $e');
    }
  }

  Future<Map<String, dynamic>> createPaymentIntent(
      String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card',
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );

      return jsonDecode(response.body);
    } catch (err) {
      print('Error creating payment intent: ${err.toString()}');
      return {};
    }
  }

  String calculateAmount(String amount) {
    final calculatedAmount = ((double.parse(amount)) * 100).toInt();
    return calculatedAmount.toString();
  }

  Future<void> _showAddMoneyDialog() async {
    final TextEditingController _dialogAmountController =
        TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            "Add Money",
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Enter the amount you want to add"),
              const SizedBox(height: 10),
              TextField(
                controller: _dialogAmountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  hintText: 'Enter Amount',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child:
                  const Text("Cancel", style: TextStyle(color: Colors.black)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () {
                if (_dialogAmountController.text.isNotEmpty) {
                  double enteredAmount =
                      double.parse(_dialogAmountController.text);
                  Navigator.of(context).pop();
                  _addMoney(enteredAmount);
                }
              },
              child: const Text("Pay", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
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
        title: const Text(
          "Wallet",
          style: TextStyle(
              fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            colors: [Colors.blue, Colors.purple],
                          ),
                        ),
                        child: Row(
                          children: [
                            Image.asset("assets/images/Wallet_icon.png",
                                height: 60, width: 60, fit: BoxFit.cover),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Your Wallet",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "\$${walletBalance.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Quick Add",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [100, 500, 1000, 2000]
                            .map(
                              (amount) => GestureDetector(
                                onTap: () => _addMoney(amount.toDouble()),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.grey[200],
                                  ),
                                  child: Text(
                                    "\$$amount",
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: _showAddMoneyDialog,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text(
                              "Add Money",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
