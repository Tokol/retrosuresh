import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';

import '../data/datas.dart';

class CollegeJourneySection extends StatefulWidget {
  final Size size;
  final double imageScale;
  final double fontScale;
  final double scaleFactor;

  const CollegeJourneySection({
    super.key,
    required this.size,
    required this.imageScale,
    required this.fontScale,
    required this.scaleFactor,
  });

  @override
  _CollegeJourneySectionState createState() => _CollegeJourneySectionState();
}

class _CollegeJourneySectionState extends State<CollegeJourneySection>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _carAnimation;
  late Animation<double> _roadAnimation;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  late AnimationController _instructionController;
  late Animation<double> _instructionAnimation;
  int _currentCollegeIndex = 0;
  int _previousCollegeIndex = 0;
  final AudioPlayer _audioPlayer = AudioPlayer();
  DateTime _lastSoundPlayed = DateTime.now();
  double _carDirection = 1;
  bool _isEngineSoundPlaying = false;
  bool _hasInteracted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _carAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _roadAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.linear),
      ),
    );

    _carAnimation.addStatusListener((status) {
      if (!mounted) return;
      if (status == AnimationStatus.forward) {
        _playEngineSound();
      } else if (status == AnimationStatus.completed) {
        _stopEngineSound();
      }
    });

    _instructionController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );
    _instructionAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _instructionController,
        curve: Curves.easeOut,
      ),
    );
    _instructionController.forward();

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(begin: 1.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _bounceController,
        curve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _instructionController.dispose();
    _controller.dispose();

    try {
      _audioPlayer.stop().then((_) {
        _audioPlayer.dispose();
      }).catchError((e) {
        _audioPlayer.dispose();
      });
    } catch (e) {
      _audioPlayer.dispose();
    }

    super.dispose();
  }

  void _playSound(String path) async {
    if (!mounted) return;

    DateTime now = DateTime.now();
    if (now.difference(_lastSoundPlayed).inMilliseconds >= 300) {
      try {
        await _audioPlayer.stop();
        if (!mounted) return;
        await _audioPlayer.setAsset(path);
        if (!mounted) return;
        await _audioPlayer.setVolume(0.3);
        if (!mounted) return;
        await _audioPlayer.play();
        if (mounted) {
          setState(() {
            _lastSoundPlayed = now;
          });
        }
      } catch (error) {
        debugPrint('Error playing sound: $error');
      }
    }
  }

  void _playEngineSound() async {
    if (!mounted || _isEngineSoundPlaying) return;

    try {
      await _audioPlayer.stop();
      if (!mounted) return;
      await _audioPlayer.setAsset('assets/retro_engine.wav');
      if (!mounted) return;
      await _audioPlayer.setVolume(0.3);
      if (!mounted) return;
      await _audioPlayer.setLoopMode(LoopMode.one);
      await _audioPlayer.play();
      if (mounted) {
        setState(() {
          _isEngineSoundPlaying = true;
        });
      }
    } catch (error) {
      debugPrint('Error playing engine sound: $error');
    }
  }

  void _stopEngineSound() async {
    if (_isEngineSoundPlaying) {
      await _audioPlayer.setLoopMode(LoopMode.off);
      await _audioPlayer.stop();
      if (mounted) {
        setState(() {
          _isEngineSoundPlaying = false;
        });
      }
    }
  }

  void _moveToCollege(int index) {
    if (colleges.isEmpty) return;
    if (index < 0 || index >= colleges.length) return;

    if (index != _currentCollegeIndex) {
      if (mounted) {
        setState(() {
          _previousCollegeIndex = _currentCollegeIndex;
          _carDirection = index > _currentCollegeIndex ? 1 : -1;
          _currentCollegeIndex = index;
          _hasInteracted = true;
          _playSound('assets/click.wav');
          _controller.reset();
          _controller.forward();
          _bounceController.forward(from: 0.0);
        });
      }
      if (!_hasInteracted && mounted) {
        _instructionController.forward(from: 0.0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (colleges.isEmpty) {
      return const Center(
        child: Text(
          'No colleges available',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return FocusableActionDetector(
      actions: {
        NextFocusAction: CallbackAction<NextFocusIntent>(
          onInvoke: (intent) {
            _moveToCollege(_currentCollegeIndex + 1);
            return null;
          },
        ),
        PreviousFocusAction: CallbackAction<PreviousFocusIntent>(
          onInvoke: (intent) {
            _moveToCollege(_currentCollegeIndex - 1);
            return null;
          },
        ),
      },
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.arrowRight): const NextFocusIntent(),
        LogicalKeySet(LogicalKeyboardKey.arrowLeft): const PreviousFocusIntent(),
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'INSTITUTIONS WHERE I TEACH',
                style: GoogleFonts.pressStart2p(
                  fontSize: 16 * widget.fontScale,
                  color: Colors.yellow,
                ).copyWith(fontFamilyFallback: ['monospace']),
              ),
              SizedBox(height: 10 * widget.fontScale),
              FadeTransition(
                opacity: _instructionAnimation,
                child: Text(
                  'Click a college to drive there!',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 10 * widget.fontScale,
                    color: Colors.white,
                  ).copyWith(fontFamilyFallback: ['monospace']),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 10 * widget.fontScale),
              // College markers and road section
              SizedBox(
                height: (200 * widget.imageScale).clamp(150, 300), // Increased height to accommodate larger images
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 140 * widget.imageScale, // Adjusted to fit larger college images
                      child: AnimatedRoad(
                        scaleFactor: widget.scaleFactor,
                        animation: _roadAnimation,
                        isAnimating: _controller.isAnimating,
                      ),
                    ),
                    ..._buildCollegeMarkers(),
                    AnimatedBuilder(
                      animation: Listenable.merge([_carAnimation, _bounceAnimation]),
                      builder: (context, child) {
                        final positions = [
                          widget.size.width * 0.2,
                          widget.size.width * 0.5,
                          widget.size.width * 0.8,
                        ];
                        final startPos = positions[_previousCollegeIndex];
                        final endPos = positions[_currentCollegeIndex];
                        final currentPos = startPos + (endPos - startPos) * _carAnimation.value;
                        return Positioned(
                          left: currentPos,
                          top: 80 * widget.imageScale, // Adjusted to fit larger car
                          child: Transform.scale(
                            scale: _bounceAnimation.value,
                            child: Transform.scale(
                              scaleX: _carDirection,
                              child: child,
                            ),
                          ),
                        );
                      },
                      child: Image.asset(
                        'images/retro_car.png',
                        width: 140 * widget.imageScale,
                        height: 60 * widget.imageScale,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.error,
                          color: Colors.red,
                          size: 120 * widget.imageScale,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20 * widget.imageScale),
              // Info box with constrained height for SingleChildScrollView
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20 * widget.fontScale),
                padding: EdgeInsets.all(10 * widget.fontScale),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  border: Border.all(color: Colors.yellow, width: 4 * widget.scaleFactor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.yellow,
                      offset: Offset(4 * widget.scaleFactor, 4 * widget.scaleFactor),
                      blurRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.yellow,
                      offset: Offset(-4 * widget.scaleFactor, -4 * widget.scaleFactor),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: constraints.maxHeight * 0.3,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          colleges[_currentCollegeIndex]['name']?.toString() ?? 'Unknown College',
                          style: GoogleFonts.pressStart2p(
                            fontSize: 12 * widget.fontScale,
                            color: Colors.yellow,
                          ).copyWith(fontFamilyFallback: ['monospace']),
                          textAlign: TextAlign.center,
                          softWrap: true,
                          overflow: TextOverflow.visible,
                        ),
                        SizedBox(height: 8 * widget.fontScale),
                        Text(
                          'Course: ${colleges[_currentCollegeIndex]['course']?.toString() ?? 'N/A'}',
                          style: GoogleFonts.pressStart2p(
                            fontSize: 10 * widget.fontScale,
                            color: Colors.white,
                          ).copyWith(fontFamilyFallback: ['monospace']),
                          textAlign: TextAlign.center,
                          softWrap: true,
                          overflow: TextOverflow.visible,
                        ),
                        SizedBox(height: 8 * widget.fontScale),
                        Text(
                          'Semester: ${colleges[_currentCollegeIndex]['semester']?.toString() ?? 'N/A'}',
                          style: GoogleFonts.pressStart2p(
                            fontSize: 10 * widget.fontScale,
                            color: Colors.white,
                          ).copyWith(fontFamilyFallback: ['monospace']),
                          textAlign: TextAlign.center,
                          softWrap: true,
                          overflow: TextOverflow.visible,
                        ),
                        SizedBox(height: 8 * widget.fontScale),
                        Text(
                          'Affiliated to: ${colleges[_currentCollegeIndex]['affiliation']?.toString() ?? 'N/A'}',
                          style: GoogleFonts.pressStart2p(
                            fontSize: 10 * widget.fontScale,
                            color: Colors.white,
                          ).copyWith(fontFamilyFallback: ['monospace']),
                          textAlign: TextAlign.center,
                          softWrap: true,
                          overflow: TextOverflow.visible,
                        ),
                        SizedBox(height: 12 * widget.fontScale),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildPixelButton('<', () => _moveToCollege(_currentCollegeIndex - 1)),
                            SizedBox(width: 20 * widget.scaleFactor),
                            _buildPixelButton('>', () => _moveToCollege(_currentCollegeIndex + 1)),
                          ],
                        ),
                        SizedBox(height: 12 * widget.fontScale),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20 * widget.fontScale),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildCollegeMarkers() {
    final positions = [
      widget.size.width * 0.2,
      widget.size.width * 0.5,
      widget.size.width * 0.8,
    ];
    return positions.asMap().entries.map((entry) {
      final index = entry.key;
      final position = entry.value;
      return Stack(
        children: [
          Positioned(
            left: position,
            top: (5 + 80) * widget.imageScale,
            child: CustomPaint(
              size: Size(0, (140 - 5 - 80) * widget.imageScale), // Adjusted for larger college images
              painter: DottedLinePainter(scaleFactor: widget.scaleFactor),
            ),
          ),
          Positioned(
            left: position - (40 * widget.imageScale * (_currentCollegeIndex == index ? 2.0 : 1.0)), // Adjusted for larger size
            top: 5 * widget.imageScale,
            child: _buildPixelatedImage(
              colleges[index]['photo']?.toString() ?? 'images/default_college.png',
              widget.imageScale,
              index,
            ),
          ),
        ],
      );
    }).toList();
  }

  Widget _buildPixelatedImage(String path, double imageScale, int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      margin: EdgeInsets.only(bottom: 5 * imageScale),
      decoration: BoxDecoration(
        boxShadow: _currentCollegeIndex == index
            ? [
          BoxShadow(
            color: Colors.yellow.withOpacity(0.5),
            offset: Offset(2 * imageScale, 2 * imageScale),
            blurRadius: 0,
          ),
          BoxShadow(
            color: Colors.yellow.withOpacity(0.5),
            offset: Offset(-2 * imageScale, -2 * imageScale),
            blurRadius: 0,
          ),
        ]
            : [],
      ),
      child: GestureDetector(
        onTap: () => _moveToCollege(index),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedScale(
            scale: _currentCollegeIndex == index ? 2.0 : 1.0, // Scale to 2x when selected
            duration: const Duration(milliseconds: 100),
            child: SizedBox(
              width: 80 * imageScale,
              height: 80 * imageScale,
              child: Stack(
                children: [
                  Image.asset(
                    path,
                    width: 80 * imageScale,
                    height: 80 * imageScale,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.none,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.school,
                      color: Colors.white,
                      size: 80 * imageScale,
                    ),
                  ),
                  Positioned.fill(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      color: _currentCollegeIndex == index
                          ? Colors.yellow.withOpacity(0.2)
                          : Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPixelButton(String symbol, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 20 * widget.scaleFactor,
        height: 20 * widget.scaleFactor,
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(
            color: Colors.yellow,
            width: 2 * widget.scaleFactor,
          ),
        ),
        child: Center(
          child: Text(
            symbol,
            style: GoogleFonts.pressStart2p(
              fontSize: 16 * widget.fontScale,
              color: Colors.yellow,
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedRoad extends StatelessWidget {
  final double scaleFactor;
  final Animation<double> animation;
  final bool isAnimating;

  const AnimatedRoad({
    super.key,
    required this.scaleFactor,
    required this.animation,
    required this.isAnimating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 10 * scaleFactor,
      color: Colors.grey,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return CustomPaint(
            painter: RetroRoadPainter(
              offset: isAnimating ? animation.value : 0,
              scaleFactor: scaleFactor,
            ),
            child: Container(),
          );
        },
      ),
    );
  }
}

class RetroRoadPainter extends CustomPainter {
  final double offset;
  final double scaleFactor;

  RetroRoadPainter({required this.offset, required this.scaleFactor});

  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 2 * scaleFactor
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(0, 0),
      Offset(size.width, 0),
      borderPaint,
    );
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      borderPaint,
    );

    final dashPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2 * scaleFactor
      ..style = PaintingStyle.stroke;

    final dashWidth = 20 * scaleFactor;
    final dashSpace = 10 * scaleFactor;
    final totalDashLength = dashWidth + dashSpace;
    final offsetPixels = offset * totalDashLength;

    double startX = -offsetPixels % totalDashLength;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        dashPaint,
      );
      startX += totalDashLength;
    }
  }

  @override
  bool shouldRepaint(covariant RetroRoadPainter oldDelegate) {
    return oldDelegate.offset != offset || oldDelegate.scaleFactor != scaleFactor;
  }
}

class DottedLinePainter extends CustomPainter {
  final double scaleFactor;

  DottedLinePainter({required this.scaleFactor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 2 * scaleFactor
      ..style = PaintingStyle.stroke;

    const dashHeight = 5.0;
    const dashSpace = 5.0;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(0, startY),
        Offset(0, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}