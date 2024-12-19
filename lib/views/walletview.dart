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
  double walletBalance = 0.0; // لتخزين الرصيد الحالي
  bool isLoading = true;
  Map<String, dynamic>? paymentIntent;

  @override
  void initState() {
    super.initState();
    _fetchWalletBalance(); // جلب الرصيد من Supabase
  }

  // جلب الرصيد من Supabase
  Future<void> _fetchWalletBalance() async {
    final response = await Supabase.instance.client
        .from('users') // اسم الجدول
        .select('wallet')
        .eq('email', Supabase.instance.client.auth.currentUser!.email as String)
        .single();

    if (response != null) {
      setState(() {
        walletBalance = (response['wallet'] ?? '0' as num).toDouble();
        isLoading = false;
      });
    }
  }

  // إضافة المال إلى Supabase
  Future<void> _addMoney(double amount) async {
    await makePayment(amount.toString());
  }

  Future<void> makePayment(String amount) async {
    try {
      paymentIntent = await createPaymentIntent(amount, 'USD');
      await Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
                  paymentIntentClientSecret: paymentIntent!['client_secret'],
                  style: ThemeMode.dark,
                  merchantDisplayName: 'FSCU'))
          .then((value) {});

      // عرض Payment Sheet للمستخدم
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

        // تحديث واجهة المستخدم
        setState(() {
          isLoading = true;
        });
        await _fetchWalletBalance(); // إعادة جلب الرصيد
      }).onError((error, stackTrace) {
        print('Error is: $error $stackTrace');
      });
    } on StripeException catch (e) {
      print('Error is: $e');
    }
  }

  // إنشاء PaymentIntent باستخدام Stripe
  Future<Map<String, dynamic>> createPaymentIntent(
      String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card',
      };

      print("Sending request to Stripe..."); // طباعة للتأكد
      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $secretKey', // تأكد من صحة المفتاح
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );

      print("Response: ${response.body}"); // طباعة الرد
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

  // إضافة هذا الجزء داخل كلاس WalletState
  Future<void> _showAddMoneyDialog() async {
    final TextEditingController _dialogAmountController =
        TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
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
                Navigator.of(context).pop(); // إغلاق النافذة
              },
              child:
                  const Text("Cancel", style: TextStyle(color: Colors.black)),
            ),
            ElevatedButton(
              onPressed: () {
                if (_dialogAmountController.text.isNotEmpty) {
                  double enteredAmount =
                      double.parse(_dialogAmountController.text);
                  Navigator.of(context).pop(); // إغلاق النافذة
                  _addMoney(enteredAmount); // بدء عملية الدفع
                }
              },
              child: const Text("Pay", style: TextStyle(color: Colors.blue)),
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
        title: const Text("Wallet",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(color: Colors.black),
                  child: Row(
                    children: [
                      Image.asset("images/Wallet_icon.png",
                          height: 60, width: 60, fit: BoxFit.cover),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Your Wallet",
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          Text("\$${walletBalance.toString()}",
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 18)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.only(left: 12.0),
                  child: Text("Add money",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                                border: Border.all(color: Color(0xFFE9E2E2)),
                                borderRadius: BorderRadius.circular(5)),
                            child: Text("\$$amount",
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _showAddMoneyDialog, // استدعاء الدالة عند الضغط

                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: Colors.blue),
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
                )
              ],
            ),
    );
  }
}
