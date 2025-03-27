import 'package:flutter/material.dart';

class PixelScanlinesPainter extends CustomPainter {
  final double lineHeight;
  final double spacing;
  final double opacity;

  const PixelScanlinesPainter({
    required this.lineHeight,
    required this.spacing,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    final lineSpacing = lineHeight + spacing;
    final lineCount = (size.height / lineSpacing).ceil();

    for (var i = 0; i < lineCount; i++) {
      final y = i * lineSpacing;
      canvas.drawRect(
        Rect.fromLTWH(0, y, size.width, lineHeight),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}