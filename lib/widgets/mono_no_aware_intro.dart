// mono_no_aware_intro.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';

class MonoNoAwareIntro extends StatefulWidget {
  final VoidCallback onComplete;
  const MonoNoAwareIntro({super.key, required this.onComplete});

  @override
  State<MonoNoAwareIntro> createState() => _MonoNoAwareIntroState();
}

class _MonoNoAwareIntroState extends State<MonoNoAwareIntro> with TickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late AnimationController _controller;
  final List<String> _lines = [
    "Mono no aware (物の哀れ):",
    "A Japanese word that describes the sadness",
    "of realizing that everything we’re living, witnessing, and enjoying —",
    "no matter how beautiful — will one day be gone.",
    "And maybe that’s what makes it truly special —",
    "because it won’t last forever.",
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..forward();

    // Play background chiptune melody
    _audioPlayer.setVolume(0.3);
    _audioPlayer.play(AssetSource('chiptune_melody.wav')); // Placeholder sound
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final progress = _controller.value;
            final lineCount = _lines.length;
            final durationPerLine = 1.0 / lineCount;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_lines.length, (index) {
                final start = index * durationPerLine;
                final end = (index + 1) * durationPerLine;
                final opacity = (progress - start) / (end - start);
                final clampedOpacity = opacity.clamp(0.0, 1.0);

                return Opacity(
                  opacity: clampedOpacity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Text(
                      _lines[index],
                      style: GoogleFonts.pressStart2p(
                        fontSize: index == 0 ? 20 : 16,
                        color: _getLineColor(index),
                        shadows: [
                          Shadow(
                            color: _getLineColor(index).withOpacity(0.5),
                            offset: const Offset(2, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }

  Color _getLineColor(int index) {
    switch (index) {
      case 0: return Colors.cyan; // "Mono no aware"
      case 1: return Colors.white; // "A Japanese word..."
      case 2: return Colors.white; // "of realizing..."
      case 3: return Colors.red; // "no matter how beautiful..."
      case 4: return Colors.green; // "And maybe that’s..."
      case 5: return Colors.yellow; // "because it won’t last..."
      default: return Colors.white;
    }
  }
}