import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Assuming PixelBorderBox is defined in this file or imported
class PixelBorderBox extends StatelessWidget {
  final double height;
  final Color borderColor;
  final double scale;
  final Widget child;

  const PixelBorderBox({
    super.key,
    required this.height,
    required this.borderColor,
    required this.scale,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 4 * scale),
        color: Colors.black,
      ),
      child: child,
    );
  }
}

class ArcadeTestimonialWidget extends StatefulWidget {
  final List<Map<String, String>> testimonials;
  final double scale;

  const ArcadeTestimonialWidget({
    super.key,
    required this.testimonials,
    this.scale = 1.0,
  });

  @override
  State<ArcadeTestimonialWidget> createState() => _ArcadeTestimonialWidgetState();
}

class _ArcadeTestimonialWidgetState extends State<ArcadeTestimonialWidget>
    with TickerProviderStateMixin {
  late AnimationController _flickerController;
  late List<AnimationController> _bounceControllers; // For avatar bounce
  final ScrollController _scrollController = ScrollController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _flickerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    // Initialize bounce controllers for avatar animation
    _bounceControllers = List.generate(
      widget.testimonials.length,
          (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1000),
        lowerBound: -2.0,
        upperBound: 2.0,
      )..repeat(reverse: true),
    );
  }

  @override
  void dispose() {
    _flickerController.dispose();
    for (var controller in _bounceControllers) {
      controller.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Pixelated Flickering Title
        AnimatedBuilder(
          animation: _flickerController,
          builder: (context, child) {
            return Opacity(
              opacity: 0.7 + (_flickerController.value * 0.3),
              child: Text(
                'TESTIMONIALS',
                style: GoogleFonts.pressStart2p(
                  fontSize: 16 * widget.scale,
                  color: const Color(0xFF00FF00),
                  shadows: [
                    Shadow(
                      color: Colors.greenAccent,
                      offset: Offset(1 * widget.scale, 2 * widget.scale),
                      blurRadius: 0,
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        SizedBox(height: 16 * widget.scale),

        // Main Arcade Cabinet Display
        PixelBorderBox(
          height: 300 * widget.scale,
          borderColor: _getColor(_currentIndex), // Dynamic color based on index
          scale: widget.scale,
          child: Stack(
              children: [
              // CRT Screen Effects
              _buildCrtEffects(),

          // Testimonials List (Manual Scroll Only)
          ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics:BouncingScrollPhysics(),
          itemCount: widget.testimonials.length,
          itemBuilder: (context, index) {
            return _buildPixelTestimonialCard(widget.testimonials[index], index);
          },
        ),
      ],
    ),
    ),

    // Pixelated Navigation Buttons
    SizedBox(height: 16 * widget.scale),
    Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    _buildPixelButton('<', () => _scrollTo(_currentIndex - 1)),
    SizedBox(width: 24 * widget.scale),
    _buildPixelButton('>', () => _scrollTo(_currentIndex + 1)),
    ],
    ),
    ],
    );
  }

  Widget _buildCrtEffects() {
    return Stack(
      children: [
        // Screen Curvature
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              radius: 1.5,
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.black,
              ],
            ),
          ),
        ),

        // Pixelated Scanlines
        CustomPaint(
          painter: _PixelScanlinesPainter(
            lineHeight: 1 * widget.scale,
            spacing: 3 * widget.scale,
            opacity: 0.1,
          ),
        ),

        // Vignette Effect
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              radius: 0.8,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPixelTestimonialCard(Map<String, String> testimonial, int index) {
    final color = _getColor(index);

    return Container(
      width: 280 * widget.scale,
      margin: EdgeInsets.all(16 * widget.scale),
      child: Column(
        children: [
          // Pixel Avatar Frame with Bounce
          AnimatedBuilder(
            animation: _bounceControllers[index],
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _bounceControllers[index].value),
                child: child,
              );
            },
            child: Container(
              width: 64 * widget.scale,
              height: 64 * widget.scale,
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(
                  color: color,
                  width: 2 * widget.scale,
                ),
                image: DecorationImage(
                  image: AssetImage(testimonial['avatar']!),
                  filterQuality: FilterQuality.none,
                ),
              ),
            ),
          ),

          // Pixel Text Box
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 8 * widget.scale),
              padding: EdgeInsets.all(12 * widget.scale),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(
                  color: color,
                  width: 2 * widget.scale,
                ),
              ),
              child: SingleChildScrollView(
                child: Text(
                  testimonial['text']!,
                  style: GoogleFonts.pressStart2p(
                    fontSize: 8 * widget.scale,
                    color: Colors.white,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ),

          // Pixel Info Box
          Container(
            padding: EdgeInsets.all(8 * widget.scale),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              border: Border.all(
                color: color,
                width: 1 * widget.scale,
              ),
            ),
            child: Column(
              children: [
                Text(
                  testimonial['name']!,
                  style: GoogleFonts.pressStart2p(
                    fontSize: 10 * widget.scale,
                    color: color,
                  ),
                ),
                Text(
                  testimonial['position']!,
                  style: GoogleFonts.pressStart2p(
                    fontSize: 8 * widget.scale,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPixelButton(String symbol, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40 * widget.scale,
        height: 40 * widget.scale,
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(
            color: const Color(0xFFFF0000),
            width: 2 * widget.scale,
          ),
        ),
        child: Center(
          child: Text(
            symbol,
            style: GoogleFonts.pressStart2p(
              fontSize: 16 * widget.scale,
              color: const Color(0xFFFF0000),
            ),
          ),
        ),
      ),
    );
  }

  void _scrollTo(int index) {
    final newIndex = index.clamp(0, widget.testimonials.length - 1);

    setState(() {
      _currentIndex = newIndex;
    });

    _scrollController.animateTo(
      newIndex * 280.0 * widget.scale,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Color _getColor(int index) {
    const colors = [
      Color(0xFFFF00FF), // Purple
      Color(0xFF00FFFF), // Cyan
      Color(0xFFFFFF00), // Yellow
      Color(0xFF00FF00), // Green
    ];
    return colors[index % colors.length];
  }
}

class _PixelScanlinesPainter extends CustomPainter {
  final double lineHeight;
  final double spacing;
  final double opacity;

  const _PixelScanlinesPainter({
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