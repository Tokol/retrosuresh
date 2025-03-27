import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PixelatedChatBubble extends StatefulWidget {
  final String text;
  final Color color;
  final double pixelSize;
  final double fontSize;
  final double scale;

  const PixelatedChatBubble({
    Key? key,
    required this.text,
    required this.color,
    this.pixelSize = 4.0,
    this.fontSize = 8.0,
    this.scale = 1.0,
  }) : super(key: key);

  @override
  _PixelatedChatBubbleState createState() => _PixelatedChatBubbleState();
}

class _PixelatedChatBubbleState extends State<PixelatedChatBubble> {
  final GlobalKey _textKey = GlobalKey();
  Size _textSize = const Size(0, 0);

  @override
  void initState() {
    super.initState();
    // Measure text size after the widget is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox? renderBox = _textKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        setState(() {
          _textSize = renderBox.size;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final padding = widget.pixelSize * 2;
    final bubbleWidth = _textSize.width + (2 * padding);
    final bubbleHeight = _textSize.height + (2 * padding);
    final tailHeight = 20 * widget.scale;

    return CustomPaint(
      size: Size(bubbleWidth, bubbleHeight + tailHeight), // Set size to include tail
      painter: _ChatBubblePainter(
        color: widget.color,
        pixelSize: widget.pixelSize,
        scale: widget.scale,
      ),
      child: Container(
        padding: EdgeInsets.all(padding),
        child: Text(
          widget.text,
          key: _textKey,
          style: GoogleFonts.pressStart2p(
            fontSize: widget.fontSize,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
          softWrap: true,
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _ChatBubblePainter extends CustomPainter {
  final Color color;
  final double pixelSize;
  final double scale;
  final Paint _borderPaint;

  _ChatBubblePainter({
    required this.color,
    required this.pixelSize,
    required this.scale,
  }) : _borderPaint = Paint()
    ..color = Colors.black
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0 * scale;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();

    // Main bubble body (excluding the tail)
    final tailHeight = 20 * scale;
    final bubbleRect = Rect.fromLTWH(
      0,
      0,
      size.width,
      size.height - tailHeight,
    );

    // Add the bubble rectangle
    path.addRect(bubbleRect);

    // Pixelated tail (centered bottom)
    final tailWidth = 20 * scale;
    final tailStartX = (size.width - tailWidth) / 2; // Center the tail
    final tailPath = Path()
      ..moveTo(tailStartX + (tailWidth / 2), size.height - tailHeight) // Top center of tail
      ..lineTo(tailStartX, size.height - (tailHeight * 0.3)) // Bottom left
      ..lineTo(tailStartX + (tailWidth * 0.3), size.height - (tailHeight * 0.3)) // Step for pixelated look
      ..lineTo(tailStartX + (tailWidth / 2), size.height) // Bottom center (point of the tail)
      ..lineTo(tailStartX + (tailWidth * 0.7), size.height - (tailHeight * 0.3)) // Step for pixelated look
      ..lineTo(tailStartX + tailWidth, size.height - (tailHeight * 0.3)) // Bottom right
      ..close();

    // Combine the bubble and tail paths
    final combinedPath = Path.combine(PathOperation.union, path, tailPath);

    // Apply pixelation effect
    final pixelatedPath = _createPixelatedPath(combinedPath, pixelSize);

    canvas.drawPath(pixelatedPath, paint);
    canvas.drawPath(pixelatedPath, _borderPaint);
  }

  Path _createPixelatedPath(Path originalPath, double pixelSize) {
    final bounds = originalPath.getBounds();
    final pixelatedPath = Path();

    // Iterate over the path and approximate it with pixelated steps
    double currentX = bounds.left;
    double currentY = bounds.top;
    pixelatedPath.moveTo(currentX, currentY);

    final metrics = originalPath.computeMetrics();
    for (var metric in metrics) {
      for (double t = 0; t <= metric.length; t += pixelSize) {
        final tangent = metric.getTangentForOffset(t);
        if (tangent != null) {
          currentX = (tangent.position.dx / pixelSize).round() * pixelSize;
          currentY = (tangent.position.dy / pixelSize).round() * pixelSize;
          pixelatedPath.lineTo(currentX, currentY);
        }
      }
    }

    pixelatedPath.close();
    return pixelatedPath;
  }

  @override
  bool shouldRepaint(covariant _ChatBubblePainter oldDelegate) =>
      color != oldDelegate.color || pixelSize != oldDelegate.pixelSize || scale != oldDelegate.scale;
}