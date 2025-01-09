import 'dart:math';

import 'package:flutter/material.dart';
import 'package:resturant_app/views/signup.dart';
import 'package:resturant_app/views/verifycodeview.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Ensure this is added to your pubspec.yaml

class ForgotPassword extends StatefulWidget {
  final bool message;
  const ForgotPassword({super.key, required this.message});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController mailcontroller = TextEditingController();
  final _formkey = GlobalKey<FormState>();
  String email = "";

  Future<void> resetPassword() async {
    try {
      String verificationCode = (1000 + Random().nextInt(9000)).toString();

      // Call Supabase auth API to send reset password email
      await Supabase.instance.client.from('verification_codes').insert([
        {
          'email': email,
          'code': verificationCode,
          'expires_at':
              DateTime.now().add(Duration(minutes: 5)).toIso8601String(),
        }
      ]);

      await Supabase.instance.client.auth.resetPasswordForEmail(
        email,
      );

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.black,
        content: Text(
          "Password Reset Email has been sent!",
          style: TextStyle(color: Colors.white, fontSize: 18.0),
        ),
      ));
      MaterialPageRoute(builder: (context) => VerifyCodeView(email: email));
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "Error: ${error.toString()}",
          style: const TextStyle(fontSize: 18.0),
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          children: [
            const SizedBox(height: 70.0),
            const Text(
              "Forgot Password?",
              style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10.0),
            const Text(
              "Enter your email and we will send a link to reset your password.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.0),
            ),
            Expanded(
              child: Form(
                key: _formkey,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  children: [
                    TextFormField(
                      controller: mailcontroller,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please Enter Email';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: "Email",
                        hintStyle: const TextStyle(
                            fontSize: 18.0, color: Colors.black45),
                        prefixIcon: const Icon(Icons.person, size: 30.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(width: 2.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30.0),
                    GestureDetector(
                      onTap: () {
                        if (_formkey.currentState!.validate()) {
                          setState(() {
                            email = mailcontroller.text;
                          });
                          resetPassword();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xff2C9CEE),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Center(
                          child: Text(
                            "Reset Password",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    if (widget.message)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account?",
                            style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 5.0),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SignUp(),
                                  ));
                            },
                            child: const Text(
                              "SignUp",
                              style: TextStyle(
                                color: Color(0xffff5722),
                                fontSize: 18.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
