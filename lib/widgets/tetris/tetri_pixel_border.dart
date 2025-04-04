import 'package:flutter/material.dart';

class TetrisPixelBorderBox extends StatelessWidget {
  final Widget child;
  final Color color;
  final double thickness;
  final EdgeInsetsGeometry padding;

  const TetrisPixelBorderBox({
    Key? key,
    required this.child,
    this.color = Colors.yellow,
    this.thickness = 4.0,
    this.padding = const EdgeInsets.all(8),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: color,
          width: thickness,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.7),
            offset: Offset(thickness / 2, thickness / 2),
            blurRadius: 0,
          ),
          BoxShadow(
            color: color.withOpacity(0.3),
            offset: Offset(-thickness / 2, -thickness / 2),
            blurRadius: 0,
          ),
        ],
      ),
      padding: padding,
      child: child,
    );
  }
}