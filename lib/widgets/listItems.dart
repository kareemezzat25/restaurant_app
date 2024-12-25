import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:resturant_app/widgets/showitemButton.dart';

class ShowItemWidget extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const ShowItemWidget({
    Key? key,
    required this.selectedCategory,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 100,
        viewportFraction: 0.38,
        autoPlay: false,
      ),
      items: [
        ShowItemButton(
          imagePath: "images/ice-cream.png",
          itemName: "Ice-cream",
          isSelected: selectedCategory == "Ice-cream",
          onTap: () {
            onCategorySelected("Ice-cream");
          },
        ),
        ShowItemButton(
          imagePath: "images/burger.png",
          itemName: "Burger",
          isSelected: selectedCategory == "Burger",
          onTap: () {
            onCategorySelected("Burger");
          },
        ),
        ShowItemButton(
          imagePath: "images/pizza.png",
          itemName: "Pizza",
          isSelected: selectedCategory == "Pizza",
          onTap: () {
            onCategorySelected("Pizza");
          },
        ),
        ShowItemButton(
          imagePath: "images/salad.png",
          itemName: "Salad",
          isSelected: selectedCategory == "Salad",
          onTap: () {
            onCategorySelected("Salad");
          },
        ),
        ShowItemButton(
          imagePath: "images/apple-juice.png",
          itemName: "juices",
          isSelected: selectedCategory == "juices",
          onTap: () {
            onCategorySelected("juices");
          },
        ),
        ShowItemButton(
          imagePath: "images/sandwich.png",
          itemName: "Sandwiches",
          isSelected: selectedCategory == "Sandwiches",
          onTap: () {
            onCategorySelected("Sandwiches");
          },
        ),
        ShowItemButton(
          imagePath: "images/breakfast.png",
          itemName: "Breakfast",
          isSelected: selectedCategory == "Breakfast",
          onTap: () {
            onCategorySelected("Breakfast");
          },
        ),
        ShowItemButton(
          imagePath: "images/shawarma.png",
          itemName: "Shawarma",
          isSelected: selectedCategory == "Shawarma",
          onTap: () {
            onCategorySelected("Shawarma");
          },
        ),
        ShowItemButton(
          imagePath: "images/steak.png",
          itemName: "Steak",
          isSelected: selectedCategory == "Steak",
          onTap: () {
            onCategorySelected("Steak");
          },
        ),
        ShowItemButton(
          imagePath: "images/fried-chicken.png",
          itemName: "FriedChicken",
          isSelected: selectedCategory == "FriedChicken",
          onTap: () {
            onCategorySelected("FriedChicken");
          },
        ),
        ShowItemButton(
          imagePath: "images/spaghetti.png",
          itemName: "Pastas",
          isSelected: selectedCategory == "Pastas",
          onTap: () {
            onCategorySelected("Pastas");
          },
        ),
        ShowItemButton(
          imagePath: "images/donut.png",
          itemName: "Desserts",
          isSelected: selectedCategory == "Desserts",
          onTap: () {
            onCategorySelected("Desserts");
          },
        ),
        ShowItemButton(
          imagePath: "images/hot-drink.png",
          itemName: "hot-drink",
          isSelected: selectedCategory == "hot-drink",
          onTap: () {
            onCategorySelected("hot-drink");
          },
        ),
      ],
    );
  }
}
