

import 'package:flutter/material.dart';

class PixelBorderBox extends StatelessWidget {
  final Widget child;
  final Color borderColor;
  final double scale;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? height;
  final double? width;
  final BoxDecoration? decoration;


  const PixelBorderBox({
    super.key,
    required this.child,
    this.borderColor= Colors.yellow, // Default purple
    this.scale = 1.0,
    this.padding,
    this.margin,
    this.height,
    this.width,
    this.decoration,

  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(
          color: borderColor,
          width: 4 * scale,
        ),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(0.7),
            offset: Offset(4 * scale, 4 * scale),
            blurRadius: 0,
          ),
          BoxShadow(
            color: borderColor.withOpacity(0.7),
            offset: Offset(-4 * scale, -4 * scale),
            blurRadius: 0,
          ),
        ],
      ),
      child: child,
    );
  }
}