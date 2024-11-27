import 'dart:math';

import 'package:flutter/material.dart';
import 'package:resturant_app/views/fooddetails.dart';
import 'package:resturant_app/widgets/textwidget.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeState();
}

class _HomeState extends State<HomeView> {
  bool icecream = false;
  bool salad = false;
  bool burger = false;
  bool pizza = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          margin: EdgeInsets.only(left: 10, top: 40, bottom: 40),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Hello uname,",
                        style: TextWidget.boldTextFieldStyle()),
                    Container(
                        margin: EdgeInsets.only(right: 20),
                        padding: EdgeInsets.all(3),
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(10)),
                        child: Icon(Icons.shopping_cart, color: Colors.white))
                  ],
                ),
                SizedBox(height: 20),
                Text("Delicious Food",
                    style: TextWidget.HeadLineTextFieldStyle()),
                Text("Discover and get Great Food",
                    style: TextWidget.LightTextFieldStyle()),
                SizedBox(
                  height: 20,
                ),
                Container(
                    margin: EdgeInsets.only(right: 10), child: showItem()),
                SizedBox(height: 30),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Container(
                        margin: EdgeInsets.all(4),
                        child: Material(
                          elevation: 1,
                          borderRadius: BorderRadius.circular(15),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => FoodDetails()));
                            },
                            child: Container(
                              padding: EdgeInsets.all(14),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Image.asset("images/Cheeseburger.jpg",
                                        height: 150,
                                        width: 150,
                                        fit: BoxFit.fill),
                                    Text("veggie Taco Hash",
                                        style: TextWidget
                                            .semiBoldTextFieldStyle()),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text("Fresh and healthy",
                                        style:
                                            TextWidget.LightTextFieldStyle()),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      "\$25",
                                      style:
                                          TextWidget.semiBoldTextFieldStyle(),
                                    )
                                  ]),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Container(
                        margin: EdgeInsets.all(4),
                        child: Material(
                          elevation: 1,
                          borderRadius: BorderRadius.circular(15),
                          child: Container(
                            padding: EdgeInsets.all(14),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Image.asset("images/icecream.jpg",
                                      height: 150,
                                      width: 150,
                                      fit: BoxFit.fill),
                                  Text("icecream Hash",
                                      style:
                                          TextWidget.semiBoldTextFieldStyle()),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text("Fresh and healthy",
                                      style: TextWidget.LightTextFieldStyle()),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    "\$18",
                                    style: TextWidget.semiBoldTextFieldStyle(),
                                  )
                                ]),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 30),
                Container(
                  margin: EdgeInsets.only(right: 10),
                  child: Material(
                    elevation: 5,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: EdgeInsets.all(5),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset("images/salad.jpg",
                                height: 120, width: 120, fit: BoxFit.fill),
                            SizedBox(
                              width: 20,
                            ),
                            Column(
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width / 2,
                                  child: Text(
                                    "Pizza Margherita",
                                    style: TextWidget.semiBoldTextFieldStyle(),
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width / 2,
                                  child: Text(
                                    "is a typical Neapolitan pizza",
                                    style: TextWidget.LightTextFieldStyle(),
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width / 2,
                                  child: Text(
                                    "\$25",
                                    style: TextWidget.semiBoldTextFieldStyle(),
                                  ),
                                )
                              ],
                            )
                          ]),
                    ),
                  ),
                )
              ],
            ),
          )),
    );
  }

  Widget showItem() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            icecream = true;
            salad = false;
            pizza = false;
            burger = false;
            setState(() {});
          },
          child: Material(
            elevation: 5,
            borderRadius: BorderRadius.circular(10),
            child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: icecream ? Colors.black : Colors.white,
                    borderRadius: BorderRadius.circular(10)),
                child: Image.asset("images/icecream.png",
                    height: 40, width: 40, fit: BoxFit.fill)),
          ),
        ),
        GestureDetector(
          onTap: () {
            burger = true;
            salad = false;
            pizza = false;
            icecream = false;
            setState(() {});
          },
          child: Material(
            elevation: 5,
            borderRadius: BorderRadius.circular(10),
            child: Container(
                decoration: BoxDecoration(
                    color: burger ? Colors.black : Colors.white,
                    borderRadius: BorderRadius.circular(10)),
                padding: EdgeInsets.all(10),
                child: Image.asset("images/burger.png",
                    height: 40, width: 40, fit: BoxFit.fill)),
          ),
        ),
        GestureDetector(
          onTap: () {
            pizza = true;
            salad = false;
            burger = false;
            icecream = false;
            setState(() {});
          },
          child: Material(
            elevation: 5,
            borderRadius: BorderRadius.circular(10),
            child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: pizza ? Colors.black : Colors.white,
                    borderRadius: BorderRadius.circular(10)),
                child: Image.asset("images/pizza.png",
                    height: 40, width: 40, fit: BoxFit.fill)),
          ),
        ),
        GestureDetector(
          onTap: () {
            salad = true;
            pizza = false;
            burger = false;
            icecream = false;
            setState(() {});
          },
          child: Material(
            elevation: 5,
            borderRadius: BorderRadius.circular(10),
            child: Container(
                decoration: BoxDecoration(
                    color: salad ? Colors.black : Colors.white,
                    borderRadius: BorderRadius.circular(10)),
                padding: EdgeInsets.all(10),
                child: Image.asset("images/salad.png",
                    height: 40, width: 40, fit: BoxFit.fill)),
          ),
        )
      ],
    );
  }
}
