import "package:curved_navigation_bar/curved_navigation_bar.dart";
import "package:flutter/material.dart";
import "package:resturant_app/admin/addfooditem.dart";
import "package:resturant_app/views/profile.dart";
import "package:resturant_app/admin/searchfood.dart";
import "package:resturant_app/admin/usersview.dart";
import "package:resturant_app/views/home.dart";

class BottomNavAdmin extends StatefulWidget {
  const BottomNavAdmin({super.key});

  @override
  State<BottomNavAdmin> createState() => _BottomNavAdminState();
}

class _BottomNavAdminState extends State<BottomNavAdmin> {
  int currentTabIndex = 0;
  late List<Widget> views;
  late Widget currentview;
  late SearchFoodItem home;
  late AddItem add;
  late Usersview users;
  late Profile profile;

  @override
  void initState() {
    home = SearchFoodItem();
    add = AddItem();
    users = Usersview();
    profile = Profile();
    views = [home, add, users, profile];

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
              Icons.add_circle_outline,
              color: Colors.white,
            ),
            Icon(
              Icons.person_2,
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
