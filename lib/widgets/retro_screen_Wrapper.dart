import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RetroScreenWrapper extends StatefulWidget {
  final String title;
  final VoidCallback onBack;
  final Widget child;

  const RetroScreenWrapper({
    super.key,
    required this.title,
    required this.onBack,
    required this.child,
  });

  @override
  _RetroScreenWrapperState createState() => _RetroScreenWrapperState();
}

class _RetroScreenWrapperState extends State<RetroScreenWrapper> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  DateTime _lastSoundPlayed = DateTime.now();

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _handleBack() async {
    DateTime now = DateTime.now();
    if (now.difference(_lastSoundPlayed).inMilliseconds >= 300) {
      await _audioPlayer.stop();
      _audioPlayer.setVolume(0.3); // Stop any currently playing sound
      await _audioPlayer.play(AssetSource('select.mp3')); // Play the sound
      _lastSoundPlayed = now;
    }
    widget.onBack(); // Call the onBack callback
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double scaleFactor = size.width / 600;
    final double fontScale = scaleFactor.clamp(0.8, 1.5);
    final double imageScale = scaleFactor.clamp(0.8, 1.2);

    return Scaffold(
      backgroundColor: const Color(0xFF1C2526),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12 * scaleFactor, vertical: 8 * scaleFactor),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.black, Colors.red],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                border: Border.all(color: Colors.yellow, width: 2),
              ),
              child: Row(
                children: [
                  _BackButton(onTap: _handleBack, imageScale: imageScale),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: GoogleFonts.pressStart2p(
                        fontSize: 16 * fontScale,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.yellow.withOpacity(0.8),
                            blurRadius: 10,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ).copyWith(
                        fontFamilyFallback: ['monospace'],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(width: 40 * imageScale),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black87, Colors.grey.shade900],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: widget.child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackButton extends StatefulWidget {
  final VoidCallback onTap;
  final double imageScale;

  const _BackButton({required this.onTap, required this.imageScale});

  @override
  _BackButtonState createState() => _BackButtonState();
}

class _BackButtonState extends State<_BackButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward().then((_) {
      _controller.reverse();
      widget.onTap();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Image.asset(
              'images/back_icon.png',
              width: 40 * widget.imageScale,
              height: 40 * widget.imageScale,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 40,
                );
              },
            ),
          );
        },
      ),
    );
  }
}