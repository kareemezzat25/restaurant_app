import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:resturant_app/views/signup.dart';

class OnboardingScreen extends StatelessWidget {
  final PageController _pageController = PageController();

  Widget _buildImage(String assetName, [double width = 350]) {
    return Image.asset('assets/images/$assetName', height: 300, width: width);
  }

  @override
  Widget build(BuildContext context) {
    const pageDecoration = PageDecoration(
        titleTextStyle: TextStyle(
            fontSize: 24.0,
            color: Color(0xFF202020),
            fontWeight: FontWeight.w700),
        pageColor: Colors.white,
        imagePadding: EdgeInsets.zero,
        imageFlex: 3);

    return IntroductionScreen(
      globalBackgroundColor: Colors.white,
      dotsDecorator: DotsDecorator(
          color: Color(0xFF707070),
          activeColor: Color(0xFFFF6E73),
          activeSize: Size(10, 10),
          activeShape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))),
      showNextButton: true,
      showDoneButton: true,
      showBackButton: true,
      back: Text(
        "Back",
        style: TextStyle(
            fontSize: 18,
            color: Color(0xFFFF6E73),
            fontWeight: FontWeight.bold),
      ),
      next: Text(
        "Next",
        style: TextStyle(
            fontSize: 18,
            color: Color(0xFFFF6E73),
            fontWeight: FontWeight.bold),
      ),
      done: Text("Finish",
          style: TextStyle(
              fontSize: 18,
              color: Color(0xFFFF6E73),
              fontWeight: FontWeight.bold)),
      onDone: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => SignUp()));
      },
      pages: [
        PageViewModel(
          title: "Select from Our Best Menu",
          body: "",
          image: _buildImage('screen1.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Easy and Online Payment",
          body: "",
          image: _buildImage('screen2.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Get It Delivered",
          body: "",
          image: _buildImage('screen3.png'),
          decoration: pageDecoration,
        ),
      ],
    );
  }
}
