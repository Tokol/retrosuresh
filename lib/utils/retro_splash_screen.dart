import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RetroLoadingScreen extends StatefulWidget {
  const RetroLoadingScreen({super.key});

  @override
  State<RetroLoadingScreen> createState() => _RetroLoadingScreenState();
}

class _RetroLoadingScreenState extends State<RetroLoadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progressAnimation;
  final double textScale = 1.2;
  bool _assetsLoaded = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _progressAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    // Start animation immediately
    _controller.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load assets here when context is safe to use
    if (!_assetsLoaded) {
      _loadAssets();
    }
  }

  Future<void> _loadAssets() async {
    try {
      await precacheImage(
        const AssetImage("images/splash_bg.jpg"),
        context,
      );
      if (mounted) {
        setState(() => _assetsLoaded = true);
      }
    } catch (e) {
      debugPrint('Error precaching image: $e');
      if (mounted) {
        setState(() => _assetsLoaded = true); // Continue even if image fails
      }
    }
  }

  Widget _buildPixelLoadingBar(double progress) {
    const int totalSegments = 12;
    final int filledSegments = (progress * totalSegments).floor();

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
          final isFilled = index < filledSegments;
          final glitchEffect = isFilled && ((_controller.value * 20 % 1) > 0.85);

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
          // Fallback background if image isn't loaded yet
          Container(color: Colors.black),

          // Background Image (only shown when assets are loaded)
          if (_assetsLoaded)
            Positioned.fill(
              child: Image.asset(
                "images/splash_bg.jpg",
                fit: BoxFit.cover,
                alignment: Alignment.center,
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: Colors.black),
              ),
            ),

          // Dark overlay
          Container(color: Colors.black.withOpacity(0.6)),

          // Loading Content
          Positioned(
            bottom: screenHeight * 0.08,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, _) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: _buildPixelLoadingBar(_progressAnimation.value),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "${(_progressAnimation.value * 100).toStringAsFixed(0)}%",
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
                );
              },
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