// show_item_button.dart
import 'package:flutter/material.dart';

class ShowItemButton extends StatelessWidget {
  final String imagePath;
  final String itemName;
  final bool isSelected;
  Function onTap = () {};

  ShowItemButton({
    Key? key,
    required this.imagePath,
    required this.itemName,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 120,
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Image.asset(
                imagePath,
                color: isSelected
                    ? Colors.white
                    : Colors.black, // Icon color based on selection
                height: 40,
                width: 40,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 5),
              Text(
                itemName,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
