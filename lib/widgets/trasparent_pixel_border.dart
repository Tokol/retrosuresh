import 'package:flutter/material.dart';

class TransparentPixelBorder extends StatelessWidget {
  final Widget child;
  final Color borderColor;
  final double borderWidth;
  final double shadowOffset;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? height;
  final double? width;

  const TransparentPixelBorder({
    super.key,
    required this.child,
    this.borderColor = Colors.yellow,
    this.borderWidth = 2.0,
    this.shadowOffset = 4.0,
    this.padding,
    this.margin,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        // Ensure complete transparency
        color: Colors.transparent,
        border: Border.all(
          color: borderColor.withOpacity(0.8), // Slightly transparent border
          width: borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(0.4),
            offset: Offset(shadowOffset, shadowOffset),
            blurRadius: 0,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: borderColor.withOpacity(0.4),
            offset: Offset(-shadowOffset, -shadowOffset),
            blurRadius: 0,
            spreadRadius: 0,
          ),
        ],
      ),
      child: child,
    );
  }
}