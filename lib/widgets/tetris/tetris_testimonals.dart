import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:suresh_portfilo/models/testimonals.dart';
import 'package:suresh_portfilo/widgets/tetris/tetris_block.dart';

class TetrisTestimonials extends StatefulWidget {
  const TetrisTestimonials({Key? key}) : super(key: key);

  @override
  State<TetrisTestimonials> createState() => _TetrisTestimonialsState();
}

class _TetrisTestimonialsState extends State<TetrisTestimonials> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final List<Testimonial> testimonials = [
    Testimonial(
      name: "Nabin Mahara",
      photo: "images/student1.webp",
      quote: "Suresh Lama Sir makes coding an adventure!",
      position: "Final Year Student",
      organization: "London College",
    ),
    Testimonial(
      name: "Colleague C",
      photo: "images/student3.webp",
      quote: "A true professional with passion!",
      position: "Colleague",
      organization: "[Org Name]",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initAudio();
    _precacheImages();
  }

  Future<void> _initAudio() async {
    try {
      await _audioPlayer.setAsset("sword_clink.mp3");
      await _audioPlayer.setVolume(0.3); // Lower volume
    } catch (e) {
      debugPrint("Audio error: $e");
    }
  }

  Future<void> _precacheImages() async {
    for (final testimonial in testimonials) {
      precacheImage(AssetImage(testimonial.photo), context);
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final blockWidth = size.width * 0.25; // 25% of screen width
    const blockHeight = 80.0; // Tetris-like fixed height

    return SizedBox(
      height: size.height * 0.8, // Respect parent constraint
      child: Stack(
        children: [
          // Tetris grid background
          Positioned.fill(
            child: CustomPaint(
              painter: _TetrisMiniGridPainter(gridSize: 20),
            ),
          ),

          // Falling blocks area with extra space
          Positioned.fill(
            child: OverflowBox(
              alignment: Alignment.topCenter,
              maxHeight: size.height * 1.5, // Space for falling animation
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < testimonials.length; i++)
                    _buildTetrisBlock(testimonials[i], i, blockWidth, blockHeight),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTetrisBlock(Testimonial testimonial, int index, double width, double height) {
    return SizedBox(
      width: width,
      height: height,
      child: TetrisBlock(
        testimonial: testimonial,
        index: index,
        audioPlayer: _audioPlayer,
        blockType: _getBlockType(index),
      ),
    );
  }

  String _getBlockType(int index) {
    const shapes = ['I', 'J', 'L', 'O', 'S', 'T', 'Z'];
    return shapes[index % shapes.length];
  }
}

class _TetrisMiniGridPainter extends CustomPainter {
  final double gridSize;

  const _TetrisMiniGridPainter({this.gridSize = 20});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00BFFF).withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw grid
    for (var x = 0; x < size.width; x += gridSize as int) {
      canvas.drawLine(Offset(x.toDouble(), 0), Offset(x.toDouble(), size.height), paint);
    }
    for (var y = 0; y < size.height; y += gridSize as int) {
      canvas.drawLine(Offset(0, y.toDouble()), Offset(size.width, y.toDouble()), paint);
    }

    // Draw border
    final borderPaint = Paint()
      ..color = const Color(0xFF00FFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}