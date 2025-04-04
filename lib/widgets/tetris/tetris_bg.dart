import 'dart:math';

import 'package:flutter/material.dart';


class TetrisGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF00BFFF) // Light blue grid lines
      ..strokeWidth = 1;

    // Calculate grid cell size (10x20 grid)
    final cellWidth = size.width / 10;
    final cellHeight = size.height / 20;

    // Draw vertical lines
    for (int i = 0; i <= 10; i++) {
      canvas.drawLine(
        Offset(i * cellWidth, 0),
        Offset(i * cellWidth, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (int i = 0; i <= 20; i++) {
      canvas.drawLine(
        Offset(0, i * cellHeight),
        Offset(size.width, i * cellHeight),
        paint,
      );
    }

    // Draw cyan border
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF00FFFF) // Cyan border
      ..strokeWidth = 2;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      borderPaint,
    );

    // Draw stars (8 random 2x2 white squares in the top quarter)
    final starPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;
    final random = Random();
    for (int i = 0; i < 8; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * (size.height / 4); // Top quarter
      canvas.drawRect(
        Rect.fromLTWH(x, y, 2, 2),
        starPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}