import 'package:flutter/material.dart';
import 'package:resturant_app/views/signup.dart';

class OnboardingScreen extends StatelessWidget {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white, // Set the page background color to white
        child: PageView(
          controller: _pageController,
          children: [
            buildPage(
              image: "images/screen1.png",
              title: "Select from Our Best Menu",
              description: "Pick your food from our menu more than 35 times.",
              buttonText: "Next",
              onPressed: () {
                _pageController.nextPage(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),
            buildPage(
              image: "images/screen2.png",
              title: "Easy and Online Payment",
              description:
                  "You can pay cash on delivery and Card payment is available.",
              buttonText: "Next",
              onPressed: () {
                _pageController.nextPage(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),
            buildPage(
              image: "images/screen3.png",
              title: "Get It Delivered",
              description: "Enjoy hot and fresh food at your doorstep.",
              buttonText: "Start",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUp()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPage({
    required String image,
    required String title,
    required String description,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Spacer(flex: 2),
          Image.asset(
            image,
            height: 300, // Adjusted for better scaling
            fit: BoxFit.contain,
          ),
          SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors
                  .black, // Black text for better visibility on white background
            ),
          ),
          SizedBox(height: 10),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54, // Softer black for the description
            ),
          ),
          Spacer(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFF5722),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
            ),
            onPressed: onPressed,
            child: Text(
              buttonText,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }
}
