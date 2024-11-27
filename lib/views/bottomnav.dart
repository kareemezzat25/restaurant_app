import "package:curved_navigation_bar/curved_navigation_bar.dart";
import "package:flutter/material.dart";
import "package:resturant_app/views/home.dart";
import "package:resturant_app/views/orderview.dart";
import "package:resturant_app/views/profileview.dart";
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
  late Wallet wallet;

  @override
  void initState() {
    home = HomeView();
    profile = Profile();
    order = Order();
    wallet = Wallet();
    views = [home, order, wallet, profile];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
          height: 65,
          backgroundColor: Colors.white,
          color: Colors.black,
          animationDuration: Duration(milliseconds: 500),
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
