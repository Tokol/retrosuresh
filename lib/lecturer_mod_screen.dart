import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:suresh_portfilo/widgets/college_journey_section.dart';

import 'package:suresh_portfilo/widgets/retro_screen_Wrapper.dart';
import 'package:suresh_portfilo/widgets/space_invaders/space_invaders_message_blaster.dart';
import 'package:suresh_portfilo/widgets/testimonal_widget.dart';
import 'package:vibration/vibration.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

import 'data/datas.dart';

class LecturerModeScreen extends StatefulWidget {
  final VoidCallback onBack;

  const LecturerModeScreen({super.key, required this.onBack});

  @override
  _LecturerModeScreenState createState() => _LecturerModeScreenState();
}

class _LecturerModeScreenState extends State<LecturerModeScreen> with TickerProviderStateMixin {
  int _currentTextIndex = 0;
  final FocusNode _focusNode = FocusNode();
  final AudioPlayer _audioPlayer = AudioPlayer();
  DateTime _lastSoundPlayed = DateTime.now();



  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _nextSegment() {
    if (_currentTextIndex < storyText.length - 1) {
      setState(() {
        _currentTextIndex++;
      });
      _playSound();
      _triggerVibration();
    }
  }

  void _previousSegment() {
    if (_currentTextIndex > 0) {
      setState(() {
        _currentTextIndex--;
      });
      _playSound();
    }
  }

  void _playSound() {
    DateTime now = DateTime.now();
    if (now.difference(_lastSoundPlayed).inMilliseconds >= 300) {
      _audioPlayer.stop();
      _audioPlayer.setVolume(0.3);
      _audioPlayer.play(AssetSource('blip.wav')).catchError((error) {
        print('Error playing sound: $error');
      });
      _lastSoundPlayed = now;
    }
  }

  void _triggerVibration() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 50);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double scaleFactor = size.width / 600;
    final double fontScale = scaleFactor.clamp(0.8, 1.5);
    final double imageScale = scaleFactor.clamp(0.8, 1.2);

    return RetroScreenWrapper(
      title: 'LECTURER MODE',
      onBack: widget.onBack,
      child: RawKeyboardListener(
        focusNode: _focusNode,
        onKey: (RawKeyEvent event) {
          if (event is RawKeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
              _nextSegment();
            } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              _previousSegment();
            }
          }
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20 * scaleFactor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Sprite Story Section
                _buildSpriteStory(size, imageScale, fontScale),
                SizedBox(height: 20 * fontScale),
                // Navigation Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildButton('BACK', _previousSegment, fontScale, _currentTextIndex > 0),
                    SizedBox(width: 20 * fontScale),
                    _buildButton('NEXT', _nextSegment, fontScale, _currentTextIndex < storyText.length - 1),
                  ],
                ),
                SizedBox(height: 30 * fontScale),
                // College Journey Section
                CollegeJourneySection(
                  size: size,
                  imageScale: imageScale,
                  fontScale: fontScale,
                  scaleFactor: scaleFactor,
                ),




// Inside your build method's Column:
                SizedBox(height: 30 * fontScale),
                ArcadeTestimonialWidget( // Add the new section here
                  scale: 1.2,
                  testimonials: collegeTestimonials,
                ),
                SizedBox(height: 30 * fontScale),


                SizedBox(height: 30 * fontScale),
                SpaceInvadersMessageBlaster(scale: 1.0),
                SizedBox(height: 30 * fontScale),
                // Placeholder for other sections

              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpriteStory(Size size, double imageScale, double fontScale) {
    final double spritePosition = (size.width * 0.6) * (_currentTextIndex / (storyText.length - 1));
    final double scaleFactor = size.width / 600;

    return SizedBox(
      height: 250 * imageScale,
      child: Stack(
        children: [
          Positioned(
            left: spritePosition.clamp(0, size.width * 0.6),
            top: 20 * imageScale,
            child: Transform.scale(
              scaleX: _currentTextIndex % 2 == 0 ? 1 : -1,
              child: Image.asset(
                'images/teacher.png',
                width: 60 * imageScale,
                height: 60 * imageScale,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.error,
                  color: Colors.red,
                  size: 60 * imageScale,
                ),
              ),
            ),
          ),
          Positioned(
            top: 100 * imageScale,
            left: 20 * fontScale,
            right: 20 * fontScale,
            child: Container(
              padding: EdgeInsets.all(10 * fontScale),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                border: Border.all(color: Colors.yellow, width: 4 * scaleFactor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.yellow,
                    offset: Offset(4 * scaleFactor, 4 * scaleFactor),
                    blurRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.yellow,
                    offset: Offset(-4 * scaleFactor, -4 * scaleFactor),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: AnimatedTextKit(
                key: ValueKey(_currentTextIndex),
                animatedTexts: [
                  TypewriterAnimatedText(
                    storyText[_currentTextIndex],
                    textStyle: GoogleFonts.pressStart2p(
                      fontSize: 12 * fontScale,
                      color: Colors.white,
                    ).copyWith(fontFamilyFallback: ['monospace']),
                    speed: const Duration(milliseconds: 50),
                  ),
                ],
                isRepeatingAnimation: false,
                pause: Duration.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String label, VoidCallback onPressed, double fontScale, bool enabled) {
    return ElevatedButton(
      onPressed: enabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: enabled ? Colors.red : Colors.grey,
        padding: EdgeInsets.symmetric(horizontal: 10 * fontScale, vertical: 5 * fontScale),
      ),
      child: Text(
        label,
        style: GoogleFonts.pressStart2p(
          fontSize: 10 * fontScale,
          color: Colors.white,
        ).copyWith(fontFamilyFallback: ['monospace']),
      ),
    );
  }
}