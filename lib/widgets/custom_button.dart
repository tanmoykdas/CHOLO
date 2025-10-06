import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onPressed;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  // Constructor for the CustomButton widget
  CustomButton({
    required this.text,
    required this.onPressed,
    this.backgroundColor = Colors.blueAccent,  // Default background color
    this.textColor = Colors.white,  // Default text color
    this.borderRadius = 30.0,  // Default border radius for rounded corners
    this.padding = const EdgeInsets.symmetric(horizontal: 40, vertical: 15),  // Default padding
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        primary: backgroundColor,  // Background color of the button
        onPrimary: textColor,  // Text color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),  // Rounded corners
        ),
        padding: padding,  // Padding for the button
        elevation: 8,
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
