import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:resturant_app/views/login.dart';
import 'package:resturant_app/widgets/textwidget.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});
  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Container(
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height / 2.5,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomLeft,
                      colors: [Color(0xFFff5c30), Color(0xFFe74b1a)])),
            ),
            Container(
              margin:
                  EdgeInsets.only(top: MediaQuery.of(context).size.height / 3),
              height: MediaQuery.of(context).size.height / 2,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40))),
            ),
            Container(
              margin: EdgeInsets.only(top: 60, left: 20, right: 20),
              child: Column(
                children: [
                  Center(
                    child: Image.asset(
                      "images/logo.jpg",
                      width: MediaQuery.of(context).size.width / 2.5,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 50),
                  Material(
                    borderRadius: BorderRadius.circular(20),
                    elevation: 2,
                    child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height / 1.8,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 30,
                            ),
                            Text("Sign up",
                                style: TextWidget.HeadLineTextFieldStyle()),
                            SizedBox(
                              height: 30,
                            ),
                            TextField(
                              decoration: InputDecoration(
                                  hintText: "Name",
                                  hintStyle:
                                      TextWidget.semiBoldTextFieldStyle(),
                                  prefixIcon: Icon(Icons.person_2_outlined)),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            TextField(
                              decoration: InputDecoration(
                                  hintText: "Email",
                                  hintStyle:
                                      TextWidget.semiBoldTextFieldStyle(),
                                  prefixIcon: Icon(Icons.email_outlined)),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            TextField(
                              obscureText: true,
                              decoration: InputDecoration(
                                  hintText: "Password",
                                  hintStyle:
                                      TextWidget.semiBoldTextFieldStyle(),
                                  prefixIcon: Icon(Icons.password_outlined)),
                            ),
                            const SizedBox(
                              height: 40,
                            ),
                            Container(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                width: 200,
                                decoration: BoxDecoration(
                                    color: Color(0xffff5722),
                                    borderRadius: BorderRadius.circular(20)),
                                child: const Center(
                                  child: Text(
                                    "SignUp",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ))
                          ],
                        )),
                  ),
                  SizedBox(height: 70),
                  RichText(
                    text: TextSpan(
                      text: "Already have an account? ",
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                      children: [
                        TextSpan(
                          text: "Login",
                          style: const TextStyle(
                              color: Color(0xffff5722),
                              fontWeight: FontWeight.bold),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // Navigate to the Login page
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Login()),
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
