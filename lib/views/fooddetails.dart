import 'package:flutter/material.dart';
import 'package:resturant_app/widgets/textwidget.dart';

class FoodDetails extends StatefulWidget {
  const FoodDetails({super.key});

  @override
  State<FoodDetails> createState() => _DetailsState();
}

class _DetailsState extends State<FoodDetails> {
  int counter = 1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back_ios_new_outlined,
              color: Colors.black,
            ),
          ),
          actions: []),
      body: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Image.asset("images/Cheeseburger.jpg",
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 3,
              fit: BoxFit.fill),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Burgers",
                    style: TextWidget.semiBoldTextFieldStyle(),
                  ),
                  Text(
                    "cheese Burge",
                    style: TextWidget.boldTextFieldStyle(),
                  ),
                ],
              ),
              Spacer(),
              GestureDetector(
                onTap: () {
                  if (counter > 1) --counter;
                  setState(() {});
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10)),
                  child: Icon(
                    Icons.remove,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 20),
              Text("$counter", style: TextWidget.semiBoldTextFieldStyle()),
              SizedBox(
                width: 20,
              ),
              GestureDetector(
                onTap: () {
                  counter++;
                  setState(() {});
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10)),
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                ),
              )
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Text(
              "A cheeseburger is a hamburger with a slice of melted cheese on top of the meat patty,Cheeseburgers can include variations in structure,a cheeseburger may include various condiments and other toppings such as lettuce, tomato, onion, pickles, bacon, avocado, mushrooms, mayonnaise, ketchup, and mustard.",
              style: TextWidget.LightTextFieldStyle()),
          SizedBox(height: 10),
          Row(
            children: [
              Text("Delivery Time", style: TextWidget.semiBoldTextFieldStyle()),
              SizedBox(
                width: 35,
              ),
              Icon(Icons.alarm, color: Colors.black54),
              SizedBox(width: 5),
              Text("30 min", style: TextWidget.semiBoldTextFieldStyle()),
            ],
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Total price",
                        style: TextWidget.semiBoldTextFieldStyle()),
                    Text("\$28", style: TextWidget.semiBoldTextFieldStyle())
                  ],
                ),
                Container(
                    width: MediaQuery.of(context).size.width / 2,
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.black),
                    child: Row(
                      children: [
                        Text("Add to cart",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontFamily: 'Pappions')),
                        SizedBox(width: 30),
                        Container(
                            padding: EdgeInsets.all(3),
                            child: Icon(Icons.shopping_cart_outlined,
                                color: Colors.white))
                      ],
                    ))
              ],
            ),
          )
        ]),
      ),
    );
  }
}
