import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:suresh_portfilo/widgets/space_invaders/pixel_scanlines_painter.dart';
import 'dart:math' as math;

class SpaceInvadersGame extends StatefulWidget {
  final double dynamicScale;
  final double spaceshipX;
  final double alienX;
  final bool isSuccess;
  final VoidCallback onResetForm;

  const SpaceInvadersGame({
    super.key,
    required this.dynamicScale,
    required this.spaceshipX,
    required this.alienX,
    required this.isSuccess,
    required this.onResetForm,
  });

  @override
  State<SpaceInvadersGame> createState() => _SpaceInvadersGameState();
}

class _SpaceInvadersGameState extends State<SpaceInvadersGame> with TickerProviderStateMixin {
  late AnimationController _projectileController;
  late AnimationController _explosionController;
  late AnimationController _blastWidthController;
  late AnimationController _blastOpacityController;
  bool _isProjectileFired = false;
  bool _shouldExplode = false;

  @override
  void initState() {
    super.initState();
    _projectileController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed && _shouldExplode) {
        _explosionController.forward();
      }
    });

    _explosionController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _blastWidthController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _blastOpacityController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(SpaceInvadersGame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSuccess && !oldWidget.isSuccess) {
      _shouldExplode = true;
      if (_projectileController.status == AnimationStatus.completed) {
        _explosionController.forward();
      }
    }
  }

  @override
  void dispose() {
    _projectileController.dispose();
    _explosionController.dispose();
    _blastWidthController.dispose();
    _blastOpacityController.dispose();
    super.dispose();
  }

  void _fireBlast() {
    if (_isProjectileFired) return;

    setState(() {
      _isProjectileFired = true;
      _shouldExplode = false;
    });

    _projectileController.forward();
    _blastWidthController.forward();
    _blastOpacityController.forward();
  }

  void _resetAllAnimations() {
    _projectileController.reset();
    _blastWidthController.reset();
    _blastOpacityController.reset();
    _explosionController.reset();
    setState(() {
      _isProjectileFired = false;
      _shouldExplode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _fireBlast,
      child: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'images/space_invader_bg.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: Colors.black);
              },
            ),
          ),

          // Pixel scanlines overlay
          Positioned.fill(
            child: CustomPaint(
              painter: PixelScanlinesPainter(
                lineHeight: 1 * widget.dynamicScale,
                spacing: 3 * widget.dynamicScale,
                opacity: 0.3,
              ),
            ),
          ),

          // Spaceship
          Positioned(
            left: widget.spaceshipX * (MediaQuery.of(context).size.width - 32 * widget.dynamicScale),
            bottom: 16 * widget.dynamicScale,
            child: Image.asset(
              'images/battleship.png',
              width: 32 * widget.dynamicScale,
              height: 32 * widget.dynamicScale,
              fit: BoxFit.contain,
            ),
          ),

          // Alien (hidden during explosion)
          if (!_explosionController.isAnimating && !widget.isSuccess)
            Positioned(
              left: widget.alienX * (MediaQuery.of(context).size.width - 16 * widget.dynamicScale),
              top: 16 * widget.dynamicScale,
              child: Image.asset(
                'images/alien.png',
                width: 16 * widget.dynamicScale,
                height: 16 * widget.dynamicScale,
                fit: BoxFit.contain,
              ),
            ),

          // Blasting animation
          if (_isProjectileFired)
            AnimatedBuilder(
              animation: Listenable.merge([
                _projectileController,
                _blastWidthController,
                _blastOpacityController,
              ]),
              builder: (context, child) {
                final spaceshipCenterX = widget.spaceshipX *
                    (MediaQuery.of(context).size.width - 32 * widget.dynamicScale) +
                    (16 * widget.dynamicScale);

                return Positioned(
                  left: spaceshipCenterX - (16 * widget.dynamicScale * _blastWidthController.value),
                  bottom: 48 * widget.dynamicScale,
                  child: Opacity(
                    opacity: _blastOpacityController.value,
                    child: Container(
                      width: 32 * widget.dynamicScale * _blastWidthController.value,
                      height: MediaQuery.of(context).size.height * _projectileController.value,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.yellow.withOpacity(0.8),
                            Colors.orange.withOpacity(0.6),
                            const Color(0xFFFF0000).withOpacity(0.2),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        borderRadius: BorderRadius.circular(8 * widget.dynamicScale),
                      ),
                    ),
                  ),
                );
              },
            ),

          // Explosion animation
          if (_explosionController.isAnimating || (widget.isSuccess && _shouldExplode))
            AnimatedBuilder(
              animation: _explosionController,
              builder: (context, child) {
                final frame = (_explosionController.value * 4).floor() + 1;
                return Positioned(
                  left: widget.alienX * (MediaQuery.of(context).size.width - 32 * widget.dynamicScale),
                  top: 16 * widget.dynamicScale,
                  child: Image.asset(
                    'images/explosion$frame.png',
                    width: 32 * widget.dynamicScale,
                    height: 32 * widget.dynamicScale,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback explosion if images are missing
                      return Container(
                        width: 32 * widget.dynamicScale,
                        height: 32 * widget.dynamicScale,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.orange.withOpacity(1 - _explosionController.value),
                        ),
                        child: Center(
                          child: Text(
                            'BOOM!',
                            style: TextStyle(
                              fontSize: 8 * widget.dynamicScale,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),

          // Success message
          if (widget.isSuccess && !_explosionController.isAnimating)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'MESSAGE SENT!',
                    style: GoogleFonts.pressStart2p(
                      fontSize: 24 * widget.dynamicScale,
                      color: const Color(0xFF00FF00),
                      shadows: [
                        Shadow(
                          color: Colors.greenAccent,
                          offset: Offset(1 * widget.dynamicScale, 2 * widget.dynamicScale),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24 * widget.dynamicScale),
                  GestureDetector(
                    onTap: () {
                      _resetAllAnimations();
                      widget.onResetForm();
                    },
                    child: Container(
                      width: 150 * widget.dynamicScale,
                      height: 40 * widget.dynamicScale,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        border: Border.all(
                          color: const Color(0xFFFF00FF),
                          width: 2 * widget.dynamicScale,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'SEND ANOTHER',
                          style: GoogleFonts.pressStart2p(
                            fontSize: 12 * widget.dynamicScale,
                            color: const Color(0xFFFF00FF),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}