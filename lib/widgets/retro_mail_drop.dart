import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:country_flags/country_flags.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:math';
import 'package:flutter/scheduler.dart' show timeDilation;

import '../data/datas.dart';

class RetroPostcard extends StatefulWidget {
  final double fontScale;
  final double imageScale;

  const RetroPostcard({
    super.key,
    required this.fontScale,
    required this.imageScale,
  });

  @override
  State<RetroPostcard> createState() => _RetroPostcardState();
}

class _RetroPostcardState extends State<RetroPostcard>  with SingleTickerProviderStateMixin {

  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  bool _isAnimating = false;

  final Random _random = Random();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isFront = true;
  int _currentCardIndex = 0;
  bool _showFlipHint = true;
  double _cardTilt = 0.0;
  final FocusNode _focusNode = FocusNode();



  @override
  void initState() {
    super.initState();

    _flipController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 350),
    );

    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _flipController,
        curve: Curves.easeInOutBack,
      ),
    );

    // Reset animation state when completed
    _flipController.addStatusListener((status) {
      if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
        _isAnimating = false;
      }
    });

    _initAudio();
  }

  @override
  void dispose() {
    _flipController.removeStatusListener((status) {});
    _flipController.dispose();
    _audioPlayer.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _flipCard() async {
    if (_isAnimating || _flipController.status == AnimationStatus.forward) return;

    _isAnimating = true;
    HapticFeedback.lightImpact();

    // Play flip sound at start
    _playSound('paper_flip.mp3');

    if (_isFront) {
      await _flipController.forward();
    } else {
      await _flipController.reverse();
    }

    // Play page turn sound when animation completes
   // _playSound('book_page.mp3');

    setState(() {
      _isFront = !_isFront;
      _showFlipHint = false;
      _isAnimating = false;
    });
  }





  Future<void> _initAudio() async {
    await _audioPlayer.setAsset('camera_click.mp3');
  }

  Future<void> _playSound(String sound) async {
    try {
      await _audioPlayer.setAsset('$sound');
      await _audioPlayer.play();
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }



  void _navigateCard(int direction) async {
    await _playSound('camera_click.mp3');

    // Reset flip animation to show front face
    if (!_isFront) {
      await _flipController.reverse();
    } else {
      _flipController.value = 0; // Ensure we're at the start
    }

    setState(() {
      _currentCardIndex = (_currentCardIndex + direction) % postcards.length;
      if (_currentCardIndex < 0) _currentCardIndex = postcards.length - 1;
      _isFront = true; // Force front face to be shown
      _showFlipHint = true;
      _cardTilt = _random.nextDouble() * 0.1 - 0.05;
    });
  }

  @override
  Widget build(BuildContext context) {
    final postcard = postcards[_currentCardIndex];
    final size = MediaQuery.of(context).size;
    final cardWidth = min(size.width * 0.9, 400) * widget.imageScale;
    final cardHeight = min(size.height * 0.9, 400) * widget.imageScale;

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            _navigateCard(-1); // Navigate to previous card
          } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            _navigateCard(1); // Navigate to next card
          } else if (event.logicalKey == LogicalKeyboardKey.space ||
              event.logicalKey == LogicalKeyboardKey.enter) {
            _flipCard(); // Flip the card with spacebar or enter
          }
        }
      },
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/travel_bg.webp'),
            fit: BoxFit.cover,
            opacity: 0.15,
          ),
        ),
        padding: EdgeInsets.only(top: 30, bottom: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 2),
              GestureDetector(
                onTap: _flipCard,
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity! > 0) {
                    _navigateCard(-1);
                  } else if (details.primaryVelocity! < 0) {
                    _navigateCard(1);
                  }
                },
                child: MouseRegion(
                  onEnter: (_) => setState(() => _cardTilt = _random.nextDouble() * 0.1 - 0.05),
                  onExit: (_) => setState(() => _cardTilt = 0.0),
                  child: AnimatedBuilder(
                    animation: _flipAnimation,
                    builder: (context, child) {
                      final flipValue = _flipAnimation.value;
                      final shadowOpacity = (flipValue - 0.5).abs() * 0.6;
                      final scale = 1.0 - (flipValue - 0.5).abs() * 0.1;

                      return Transform(
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.002)
                          ..rotateY(flipValue * math.pi)
                          ..scale(scale),
                        alignment: Alignment.center,
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(shadowOpacity),
                                blurRadius: 20 * shadowOpacity,
                                spreadRadius: 2 * shadowOpacity,
                              ),
                            ],
                          ),
                          child: flipValue < 0.5
                              ? _buildPolaroidFront(postcard, cardWidth, cardHeight)
                              : Transform(
                            transform: Matrix4.identity()
                              ..rotateY(math.pi),
                            alignment: Alignment.center,
                            child: _buildPolaroidBack(postcard, cardWidth, cardHeight),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              _buildFilmStripNavigation(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPolaroidFront(Map<String, dynamic> postcard, double width, double height) {
    return Container(
      key: ValueKey('front_${postcard['country']}'),
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(width: 12 * widget.imageScale, color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(5, 5),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(
            painter: _PolaroidTexturePainter(_random),
          ),
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.all(8.0 * widget.imageScale),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: Image.asset(
                    postcard['image'],
                    fit: BoxFit.contain,
                    frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                      if (frame == null) return _buildLoadingPlaceholder();
                      return ColorFiltered(
                        colorFilter: ColorFilter.matrix([
                          0.8, 0.15, 0.05, 0, 0,
                          0.1, 0.7, 0.1, 0, 0,
                          0.1, 0.1, 0.7, 0, 0,
                          0, 0, 0, 1, 0,
                        ]),
                        child: child,
                      );
                    },
                    errorBuilder: (ctx, error, stack) => _buildErrorPlaceholder(),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: height * 0.15,
              padding: EdgeInsets.symmetric(
                horizontal: 8 * widget.fontScale,
                vertical: 4 * widget.fontScale,
              ),
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center, // Changed to center
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        postcard['location'],
                        style: GoogleFonts.anton(
                          fontSize: 14 * widget.fontScale,
                          color: Colors.black,
                          letterSpacing: 1.2,
                        ),
                        textAlign: TextAlign.center, // Added center alignment
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    postcard['date'],
                    style: GoogleFonts.robotoMono(
                      fontSize: 10 * widget.fontScale,
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center, // Added center alignment
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 5,
            left: 5,
            child: CustomPaint(
              painter: _CornerStickerPainter(color: postcard['stampColor']),
              size: Size(30, 30),
            ),
          ),
        ],
      ),
    );
  }

  // [Rest of your methods remain unchanged...]
  Widget _buildPolaroidBack(Map<String, dynamic> postcard, double width, double height) {
    // Calculate positions and sizes
    final stampSize = width * 0.15;
    final flagOffset = _random.nextDouble() * 20 - 10; // Random offset between -10 and 10
    final yearCode = postcard['date'].split(' ').last.substring(2); // Last 2 digits of year
    final countryCode = postcard['code'];

    return Container(
      key: ValueKey('back_${postcard['country']}'),
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Color(0xFFF8F5F0), // Vintage paper color
        border: Border.all(
          width: 12 * widget.imageScale,
          color: Color(0xFFE8E3D5), // Light border color
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: Offset(5, 5),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Paper texture
          CustomPaint(
            painter: _PolaroidBackPainter(_random),
          ),

          // Handwritten lines texture

          // Content
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 24 * widget.imageScale,
              vertical: 20 * widget.imageScale,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // From/To section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '✉️ From: Suresh Lama',
                      style: GoogleFonts.dancingScript(
                        fontSize: 14 * widget.fontScale,
                        color: Colors.black87,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(
                        'Kathmandu, Nepal',
                        style: GoogleFonts.dancingScript(
                          fontSize: 12 * widget.fontScale,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '📬 To: My Wonderful Visitors',
                      style: GoogleFonts.dancingScript(
                        fontSize: 14 * widget.fontScale,
                        color: Colors.black87,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(
                        'Portfolio Explorers\nDigital World',
                        style: GoogleFonts.dancingScript(
                          fontSize: 12 * widget.fontScale,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    Divider(
                      color: Colors.grey[400],
                      thickness: 1,
                      height: 24,
                    ),
                  ],
                ),

                // Message area with subtle border
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: Colors.grey[400]!,
                          width: 2,
                        ),
                      ),
                    ),
                    padding: EdgeInsets.only(left: 12),
                    child: SingleChildScrollView(
                      child: Text(
                        postcard['story'],
                        style: GoogleFonts.caveat(
                          fontSize: 14 * widget.fontScale,
                          color: Colors.black87,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ),
                ),

                // Bottom section

              ],
            ),
          ),

          // Postage stamp in top right
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              width: stampSize,
              height: stampSize * 1.2,
              decoration: BoxDecoration(
                color: postcard['stampColor'],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: Colors.black.withOpacity(0.5),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Stamp perforations
                  CustomPaint(
                    painter: _StampPerforationPainter(),
                    size: Size(stampSize, stampSize * 1.2),
                  ),

                  // Country flag (randomly positioned)
                  Positioned(
                    left: flagOffset.clamp(0, stampSize * 0.3),
                    top: flagOffset.clamp(0, stampSize * 0.3),
                    child: Transform.rotate(
                      angle: _random.nextDouble() * 0.2 - 0.1, // Slight random rotation
                      child: CountryFlag.fromCountryCode(
                        countryCode,
                        height: stampSize * 0.4,
                        width: stampSize * 0.6,
                        //borderRadius: 2,
                      ),
                    ),
                  ),

                  // Stamp text
                  Positioned(
                    bottom: 9,
                    right: 8,
                    child: Text(
                      '${postcard['country']}',
                      style: GoogleFonts.robotoMono(
                        fontSize: 9 * widget.fontScale,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Inside your _buildPolaroidBack method, after the Positioned widget for the stamp



                ],
              ),
            ),
          ),

          Positioned(
            top: 20 + stampSize * 1.2, // Position it right below the main stamp
            right: 20 - 5, // Slightly offset to the left to overlap the border
            child: Transform.rotate(
              angle: -0.1, // Slight rotation for authenticity
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.black.withOpacity(0.6),
                    width: 0.8,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text(
                  postcard['date'], // Using the same date as in the postcard
                  style: GoogleFonts.robotoMono(
                    fontSize: 8 * widget.fontScale,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

// Custom painter for stamp perforations


  Widget _buildFilmStripNavigation() {
    return Container(
      height: 40 * widget.imageScale,
      margin: EdgeInsets.only(top: 10 * widget.imageScale),
      child: Stack(
        children: [
          CustomPaint(
            painter: _FilmStripPainter(
              cardCount: postcards.length,
              activeIndex: _currentCardIndex,
            ),
            size: Size(double.infinity, 60 * widget.imageScale),
          ),
          Center(
            child: Container(
              height: 40 * widget.imageScale,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: postcards.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () async {
                      if (index != _currentCardIndex) {
                        await _playSound('camera_click.mp3');

                        // Reset flip animation to show front face
                        if (!_isFront) {
                          await _flipController.reverse();
                        } else {
                          _flipController.value = 0;
                        }

                        setState(() {
                          _currentCardIndex = index;
                          _isFront = true; // Force front face
                          _showFlipHint = true;
                          _cardTilt = _random.nextDouble() * 0.1 - 0.05;
                        });
                      }
                    },
                    child: Container(
                      width: 50 * widget.imageScale,
                      margin: EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: index == _currentCardIndex
                              ? Colors.amber
                              : Colors.grey[800]!,
                          width: 2,
                        ),
                      ),
                      child: Image.asset(
                        postcards[index]['image'],
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHiddenNavButton(IconData icon, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon, size: 24 * widget.fontScale),
      color: Colors.black.withOpacity(0.5),
      onPressed: onPressed,
    );
  }

  Widget _buildLoadingPlaceholder() {
    return CustomPaint(
      painter: _PolaroidTexturePainter(_random),
      child: Center(
        child: CircularProgressIndicator(
          color: Colors.brown[400],
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return CustomPaint(
      painter: _PolaroidTexturePainter(_random),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library, size: 40, color: Colors.brown[700]),
            SizedBox(height: 8),
            Text('Memory Unavailable',
                style: GoogleFonts.specialElite(
                  color: Colors.brown[800],
                  fontSize: 14,
                )),
          ],
        ),
      ),
    );
  }
}


// Custom Painters
class _PolaroidTexturePainter extends CustomPainter {
  final Random random;

  _PolaroidTexturePainter(this.random);

  @override
  void paint(Canvas canvas, Size size) {
    // Base white
    canvas.drawRect(
      Rect.fromLTRB(0, 0, size.width, size.height),
      Paint()..color = Colors.white,
    );

    // Scratches
    final scratchPaint = Paint()
      ..color = Colors.black.withOpacity(0.05)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 15; i++) {
      canvas.drawLine(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        scratchPaint,
      );
    }

    // Age spots
    for (int i = 0; i < 10; i++) {
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        random.nextDouble() * 8 + 2,
        Paint()..color = Colors.brown.withOpacity(0.03),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PolaroidBackPainter extends CustomPainter {
  final Random random;

  _PolaroidBackPainter(this.random);

  @override
  void paint(Canvas canvas, Size size) {
    // Base color with slight gradient
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white, Colors.grey[100]!],
      ).createShader(Rect.fromLTRB(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, size.height), gradientPaint);

    // Grid lines
    final gridPaint = Paint()
      ..color = Colors.grey[300]!.withOpacity(0.3)
      ..strokeWidth = 0.5;

    // Vertical lines
    for (double x = 20; x < size.width; x += 20) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    // Horizontal lines
    for (double y = 20; y < size.height; y += 20) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Fingerprint smudges
    final smudgePaint = Paint()
      ..color = Colors.black.withOpacity(0.03)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 5; i++) {
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        random.nextDouble() * 30 + 10,
        smudgePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FilmStripPainter extends CustomPainter {
  final int cardCount;
  final int activeIndex;

  _FilmStripPainter({required this.cardCount, required this.activeIndex});

  @override
  void paint(Canvas canvas, Size size) {
    // Film base
    final filmPaint = Paint()
      ..color = Colors.grey[850]!
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(0, 10, size.width, size.height - 10),
        Radius.circular(5),
      ),
      filmPaint,
    );

    // Sprocket holes
    final holePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    const holeRadius = 5.0;
    const holeSpacing = 15.0;

    // Top holes
    for (double x = holeSpacing; x < size.width; x += holeSpacing) {
      canvas.drawCircle(Offset(x, 5), holeRadius, holePaint);
    }

    // Bottom holes
    for (double x = holeSpacing; x < size.width; x += holeSpacing) {
      canvas.drawCircle(Offset(x, size.height - 5), holeRadius, holePaint);
    }

    // Active indicator
    if (cardCount > 0) {
      final activeWidth = size.width / cardCount;
      final activePaint = Paint()
        ..color = Colors.amber.withOpacity(0.3)
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(
            activeIndex * activeWidth,
            0,
            (activeIndex + 1) * activeWidth,
            size.height,
          ),
          Radius.circular(3),
        ),
        activePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CornerStickerPainter extends CustomPainter {
  final Color color;

  _CornerStickerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);

    // Sticker edge
    final edgePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, edgePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StampPerforationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw perforated edges
    final borderPath = Path()
      ..moveTo(2, 2)
      ..lineTo(size.width - 2, 2)
      ..lineTo(size.width - 2, size.height - 2)
      ..lineTo(2, size.height - 2)
      ..close();

    canvas.drawPath(borderPath, paint..color = Colors.white.withOpacity(0.8));

    // Draw dotted lines
    final dashPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Top edge
    for (double i = 5; i < size.width - 5; i += 5) {
      canvas.drawCircle(Offset(i, 2), 1, dashPaint);
    }
    // Bottom edge
    for (double i = 5; i < size.width - 5; i += 5) {
      canvas.drawCircle(Offset(i, size.height - 2), 1, dashPaint);
    }
    // Left edge
    for (double i = 5; i < size.height - 5; i += 5) {
      canvas.drawCircle(Offset(2, i), 1, dashPaint);
    }
    // Right edge
    for (double i = 5; i < size.height - 5; i += 5) {
      canvas.drawCircle(Offset(size.width - 2, i), 1, dashPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}