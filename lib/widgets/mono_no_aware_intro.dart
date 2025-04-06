import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:suresh_portfilo/widgets/pixel_border.dart';

class MonoNoAwareIntro extends StatefulWidget {
  final VoidCallback onComplete;
  const MonoNoAwareIntro({super.key, required this.onComplete});

  @override
  State<MonoNoAwareIntro> createState() => _MonoNoAwareIntroState();
}

class _MonoNoAwareIntroState extends State<MonoNoAwareIntro> with TickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late AnimationController _controller;
  bool _showButton = false;
  int _currentVisibleLines = 0;

  late AnimationController _blinkController;
  late Animation<double> _blinkAnimation;

  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _lines = [
    {
      "text": "Mono no aware (物の哀れ):",
      "duration": 2.0,
      "color": Colors.cyan,
      "size": 22.0,
    },
    {
      "text": "A Japanese word that describes the sadness",
      "duration": 2,
      "color": Colors.white,
      "size": 16.0,
    },
    {
      "text": "of realizing that everything we're living, witnessing, and enjoying —",
      "duration": 3,
      "color": Colors.white,
      "size": 16.0,
    },
    {
      "text": "no matter how beautiful — will one day be gone.",
      "duration": 2,
      "color": Colors.red,
      "size": 16.0,
    },
    {
      "text": "And maybe that's what makes it truly special —",
      "duration": 3,
      "color": Colors.green,
      "size": 16.0,
    },
    {
      "text": "because it won't last forever.",
      "duration": 2.0,
      "color": Colors.yellow,
      "size": 16.0,
    },
  ];

  @override
  void initState() {
    super.initState();
    final totalDuration = _lines.fold(0.0, (sum, line) => sum + line["duration"]) + 1.0;

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (totalDuration * 1000).round()),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _showButton = true);
      }
    });

    _startLineAnimations();
    _audioPlayer.setVolume(0.04);
    _audioPlayer.play(AssetSource('chiptune_melody.wav'));
    _audioPlayer.setReleaseMode(ReleaseMode.loop);

    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _blinkAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(_blinkController);
  }

  void _startLineAnimations() {
    double accumulatedTime = 0.0;
    for (int i = 0; i < _lines.length; i++) {
      Future.delayed(Duration(milliseconds: (accumulatedTime * 1000).round()), () {
        if (mounted) {
          setState(() => _currentVisibleLines = i + 1);
          // Auto-scroll to bottom when new line appears
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        }
      });
      accumulatedTime += _lines[i]["duration"];
    }
    _controller.forward();
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _controller.dispose();
    _audioPlayer.dispose();
    _blinkController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 600;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Scrollable content area
            Center(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: screenHeight - (isSmallScreen ? 100 : 150),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: isSmallScreen ? 20 : 40),
                      ...List.generate(_currentVisibleLines, (index) {
                        return Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            vertical: isSmallScreen ? 4.0 : 8.0,
                            horizontal: 16.0,
                          ),
                          child: Text(
                            _lines[index]["text"],
                            style: GoogleFonts.pressStart2p(
                              fontSize: isSmallScreen
                                  ? _lines[index]["size"] * 0.85
                                  : _lines[index]["size"],
                              color: _lines[index]["color"],
                              shadows: [
                                Shadow(
                                  color: (_lines[index]["color"] as Color).withOpacity(0.5),
                                  offset: const Offset(2, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }),
                      SizedBox(height: isSmallScreen ? 60 : 100), // Space for button
                    ],
                  ),
                ),
              ),
            ),

            // "View My Journey" button
            if (_showButton)
              Positioned(
                bottom: isSmallScreen ? 20.0 : 40.0,
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      _audioPlayer.play(AssetSource('select.wav'));
                      widget.onComplete();
                    },
                    child: AnimatedBuilder(
                      animation: _blinkController,
                      builder: (context, child) {
                        final scale = 1.0 + (_blinkAnimation.value * 0.1);
                        return Transform.scale(
                          scale: scale,
                          child: Opacity(
                            opacity: _blinkAnimation.value,
                            child: PixelBorderBox(
                              child: Padding(
                                padding: EdgeInsets.all(isSmallScreen ? 6.0 : 8.0),
                                child: Text(
                                  "View My Journey!",
                                  style: GoogleFonts.pressStart2p(
                                      fontSize: isSmallScreen ? 14 : 16,
                                      color: Colors.yellow,
                                      shadows: [
                                  Shadow(
                                  color: Colors.yellow.withOpacity(0.5),
                                  blurRadius: 8,
                                  offset: const Offset(0, 0),
                                  )],
                                ),
                              ),
                            ),
                          ),
                        ),
                        );
                      },
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}