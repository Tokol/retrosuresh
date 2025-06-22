import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RetroLoadingScreen extends StatefulWidget {
  const RetroLoadingScreen({super.key});

  @override
  State<RetroLoadingScreen> createState() => _RetroLoadingScreenState();
}

class _RetroLoadingScreenState extends State<RetroLoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _progress = 0.0;
  final double textScale = 1.2;
  //late Future<void> _imagePrecacheFuture;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..addListener(() {
      setState(() => _progress = _controller.value);
    });
    _controller.forward();
  }

  Widget _buildPixelLoadingBar() {
    const int totalSegments = 12;
    int filledSegments = (_progress * totalSegments).floor();

    return Container(
      height: 28,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.black, Colors.red],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border.all(color: Colors.yellow, width: 2),
      ),
      child: Row(
        children: List.generate(totalSegments, (index) {
          bool isFilled = index < filledSegments;
          bool glitchEffect = isFilled && (DateTime.now().millisecond % 150 < 15);

          return Expanded(
            child: Container(
              margin: const EdgeInsets.all(1.5),
              decoration: BoxDecoration(
                color: isFilled
                    ? (glitchEffect ? Colors.pink : Colors.yellow)
                    : Colors.grey[900],
                border: Border.all(color: Colors.black, width: 1),
              ),
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              "images/splash_bg.jpg",
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),

          // Dark overlay
          Container(color: Colors.black.withOpacity(0.6)),

          // Loading Content - Positioned lower
          Positioned(
            bottom: screenHeight * 0.08, // Adjust this value to move up/down
            left: 0,
            right: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // LOADING text
                Text(
                  "LOADING...",
                  style: GoogleFonts.pressStart2p(
                    fontSize: 14 * textScale,
                    color: Colors.yellow,
                    shadows: [
                      Shadow(
                        color: Colors.red.withOpacity(0.7),
                        blurRadius: 10,
                        offset: Offset.zero,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 8-bit loading bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: _buildPixelLoadingBar(),
                ),
                const SizedBox(height: 16),

                // Percentage counter
                Text(
                  "${(_progress * 100).toStringAsFixed(0)}%",
                  style: GoogleFonts.pressStart2p(
                    fontSize: 10 * textScale,
                    color: Colors.yellow,
                    shadows: [
                      Shadow(
                        color: Colors.red.withOpacity(0.5),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // CRT scanlines
          IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black.withOpacity(0.15)],
                  stops: const [0.98, 1.0],
                  tileMode: TileMode.repeated,
                  transform: const GradientRotation(0.05),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}