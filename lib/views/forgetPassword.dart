import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:resturant_app/views/signup.dart';

class ForgotPassword extends StatefulWidget {
  bool message;
  ForgotPassword({super.key, required this.message});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController mailcontroller = new TextEditingController();

  String email = "";

  final _formkey = GlobalKey<FormState>();

  resetPassword() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.black,
          content: Text(
            "Password Reset Email has been sent !",
            style: TextStyle(color: Colors.white, fontSize: 18.0),
          )));
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
          "No user found for that email.",
          style: TextStyle(fontSize: 18.0),
        )));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(
            14,
          ),
          child: Column(
            children: [
              const SizedBox(
                height: 70.0,
              ),
              Container(
                alignment: Alignment.topCenter,
                child: const Text(
                  "Forget Password?",
                  style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              const Text(
                textAlign: TextAlign.center,
                "Enter your email and we will send a link to reset your password.",
                style: TextStyle(
                  fontSize: 14.0,
                ),
              ),
              Expanded(
                  child: Form(
                      key: _formkey,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: ListView(
                          children: [
                            Container(
                              padding: const EdgeInsets.only(left: 10.0),
                              decoration: BoxDecoration(
                                border: Border.all(width: 2.0),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: TextFormField(
                                controller: mailcontroller,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please Enter Email';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                    hintText: "Email",
                                    hintStyle: TextStyle(
                                        fontSize: 18.0, color: Colors.black45),
                                    prefixIcon: Icon(
                                      Icons.person,
                                      size: 30.0,
                                    ),
                                    border: InputBorder.none),
                              ),
                            ),
                            const SizedBox(
                              height: 30.0,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 22.0),
                              child: GestureDetector(
                                onTap: () {
                                  if (_formkey.currentState!.validate()) {
                                    setState(() {
                                      email = mailcontroller.text;
                                    });
                                    resetPassword();
                                  }
                                },
                                child: Container(
                                  width: 100,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      color: const Color(0xff2C9CEE),
                                      borderRadius: BorderRadius.circular(18)),
                                  child: const Center(
                                    child: Text(
                                      "Reset Password",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20.0,
                            ),
                            if (widget.message)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Don't have an account?",
                                    style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    width: 5.0,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const SignUp()));
                                    },
                                    child: const Text(
                                      "SignUp",
                                      style: TextStyle(
                                          color: Color(0xffff5722),
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  )
                                ],
                              )
                          ],
                        ),
                      ))),
            ],
          ),
        ),
      ),
    );
  }
}
