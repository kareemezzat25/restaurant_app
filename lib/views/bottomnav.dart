import "package:curved_navigation_bar/curved_navigation_bar.dart";
import "package:date_format/date_format.dart";
import "package:flutter/material.dart";
import "package:resturant_app/views/history.dart";
import "package:resturant_app/views/home.dart";
import "package:resturant_app/views/orderview.dart";
import "package:resturant_app/views/profile.dart";
import "package:resturant_app/views/walletview.dart";

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int currentTabIndex = 0;
  late List<Widget> views;
  late Widget currentview;
  late HomeView home;
  late Profile profile;
  late Order order;
  late History history;
  late Wallet wallet;

  @override
  void initState() {
    home = HomeView();
    profile = Profile();
    order = Order();
    history = History();
    wallet = Wallet();
    views = [home, order, history, wallet, profile];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
          height: 65,
          backgroundColor: Colors.white,
          color: Colors.black,
          animationDuration: Duration(milliseconds: 400),
          onTap: (int index) {
            setState(() {
              currentTabIndex = index;
            });
          },
          items: const [
            Icon(
              Icons.home_outlined,
              color: Colors.white,
            ),
            Icon(
              Icons.shopping_bag_outlined,
              color: Colors.white,
            ),
            Icon(
              Icons.history_edu_rounded,
              color: Colors.white,
            ),
            Icon(
              Icons.wallet_outlined,
              color: Colors.white,
            ),
            Icon(
              Icons.person_outline,
              color: Colors.white,
            ),
          ]),
      body: views[currentTabIndex],
    );
  }
}
