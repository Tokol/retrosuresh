import 'dart:io' show Platform;
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class ArcadeMachine extends StatefulWidget {
  final Function(String) onPlayerSelected;

  const ArcadeMachine({
    super.key,
    required this.onPlayerSelected,
  });

  @override
  _ArcadeMachineState createState() => _ArcadeMachineState();
}

class _ArcadeMachineState extends State<ArcadeMachine> {
  int _selectedIndex = 0;
  final List<String> _players = ['Lecturer', 'Developer', 'Traveller'];
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

  void _moveSelection(String direction) {
    int newIndex = _selectedIndex;
    if (direction == 'Up' || direction == 'TopLeft' || direction == 'TopRight') {
      newIndex = (_selectedIndex - 1) % _players.length;
      if (newIndex < 0) newIndex = _players.length - 1;
    } else if (direction == 'Down' || direction == 'BottomLeft' || direction == 'BottomRight') {
      newIndex = (_selectedIndex + 1) % _players.length;
    }

    if (newIndex != _selectedIndex) {
      setState(() {
        _selectedIndex = newIndex;
      });
      DateTime now = DateTime.now();
      if (now.difference(_lastSoundPlayed).inMilliseconds >= 300) {
        _audioPlayer.stop();
        _audioPlayer.setVolume(0.11);
        _audioPlayer.play(AssetSource('coin.wav')).catchError((error) {
          print('Error playing coin sound: $error');
        });
        _lastSoundPlayed = now;
      }
    }
  }

  void _confirmSelection() {
    widget.onPlayerSelected(_players[_selectedIndex]);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double scaleFactor = size.width / 600;
    final double fontScale = scaleFactor.clamp(0.8, 1.5);
    final double imageScale = scaleFactor.clamp(0.8, 1.2);
    final double joystickSize = size.width < 600 ? 90.0 : 70.0;

    return FutureBuilder(
      future: GoogleFonts.pendingFonts([GoogleFonts.pressStart2p()]),
      builder: (context, snapshot) {
        return RawKeyboardListener(
          focusNode: _focusNode,
          onKey: (RawKeyEvent event) {
            if (event is RawKeyDownEvent) {
              if (event.logicalKey == LogicalKeyboardKey.enter) {
                _confirmSelection();
              } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                _moveSelection('Up');
              } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                _moveSelection('Down');
              }
            }
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth,
                    maxHeight: constraints.maxHeight,
                  ),
                  child: Container(
                    width: size.width * (size.width < 600 ? 0.9 : 0.8),
                    height: size.height * (size.width < 600 ? 0.95 : 0.9),
                    color: const Color(0xFF1C2526),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Header
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(12 * scaleFactor),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.black, Colors.red],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              border: Border.all(color: Colors.yellow, width: 2),
                            ),
                            child: Text(
                              'SURESH ARCADE',
                              style: GoogleFonts.pressStart2p(
                                fontSize: 16 * fontScale,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.yellow.withOpacity(0.8),
                                    blurRadius: 10,
                                    offset: Offset(0, 0),
                                  ),
                                ],
                              ).copyWith(
                                fontFamilyFallback: ['monospace'],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          // Main content (always show PlayerSelector)
                          Container(
                            padding: EdgeInsets.all(40),
                            width: size.width * (size.width < 600 ? 0.85 : 0.7),
                            margin: EdgeInsets.all(12 * scaleFactor),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.black87, Colors.grey.shade900],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(color: Colors.black, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.5),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Center(
                              child: _PlayerSelector(
                                selectedIndex: _selectedIndex,
                                onPlayerSelected: widget.onPlayerSelected,
                                fontScale: fontScale,
                                imageScale: imageScale,
                              ),
                            ),
                          ),
                          // Controls section
                          Padding(
                            padding: EdgeInsets.all(5 * scaleFactor),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _ArcadeJoystick(
                                  size: joystickSize,
                                  onDirectionChanged: (direction) {
                                    _moveSelection(direction);
                                  },
                                ),
                                _ArcadeButton(
                                  size: joystickSize,
                                  onPressed: _confirmSelection,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _ArcadeButton extends StatefulWidget {
  final double size;
  final VoidCallback onPressed;

  const _ArcadeButton({required this.size, required this.onPressed});

  @override
  _ArcadeButtonState createState() => _ArcadeButtonState();
}

class _ArcadeButtonState extends State<_ArcadeButton> with SingleTickerProviderStateMixin {
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
      widget.onPressed();
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
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red,
                border: Border.all(color: Colors.black, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black54,
                    blurRadius: 5,
                    offset: Offset(3, 3),
                  ),
                  BoxShadow(
                    color: Colors.white24,
                    blurRadius: 5,
                    offset: Offset(-3, -3),
                  ),
                ],
                gradient: RadialGradient(
                  colors: [
                    Colors.redAccent,
                    Colors.red,
                  ],
                  center: Alignment(-0.3, -0.3),
                  radius: 0.8,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.circle,
                  color: Colors.white.withOpacity(0.8),
                  size: widget.size * 0.4,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BlinkingText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const _BlinkingText({required this.text, required this.style});

  @override
  _BlinkingTextState createState() => _BlinkingTextState();
}

class _BlinkingTextState extends State<_BlinkingText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(seconds: 1), vsync: this)
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Text(widget.text, style: widget.style, textAlign: TextAlign.center),
    );
  }
}

class _PlayerSelector extends StatelessWidget {
  final int selectedIndex;
  final Function(String) onPlayerSelected;
  final double fontScale;
  final double imageScale;

  const _PlayerSelector({
    required this.selectedIndex,
    required this.onPlayerSelected,
    required this.fontScale,
    required this.imageScale,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'SELECT YOUR AVATAR',
          style: GoogleFonts.pressStart2p(fontSize: 18 * fontScale, color: Colors.white).copyWith(
            fontFamilyFallback: ['monospace'],
          ),
        ),
        SizedBox(height: 20 * fontScale),
        _PlayerButton(
          text: 'LECTURER',
          imagePath: 'images/lecturer.png',
          isSelected: selectedIndex == 0,
          onTap: () => onPlayerSelected('Lecturer'),
          fontScale: fontScale,
          imageScale: imageScale,
        ),
        _PlayerButton(
          text: 'DEVELOPER',
          imagePath: 'images/programmar.png',
          isSelected: selectedIndex == 1,
          onTap: () => onPlayerSelected('Developer'),
          fontScale: fontScale,
          imageScale: imageScale,
        ),
        _PlayerButton(
          text: 'TRAVELLER',
          imagePath: 'images/traveller.png',
          isSelected: selectedIndex == 2,
          onTap: () => onPlayerSelected('Traveller'),
          fontScale: fontScale,
          imageScale: imageScale,
        ),
      ],
    );
  }
}

class _PlayerButton extends StatelessWidget {
  final String text;
  final String imagePath;
  final bool isSelected;
  final VoidCallback onTap;
  final double fontScale;
  final double imageScale;

  const _PlayerButton({
    required this.text,
    required this.imagePath,
    required this.isSelected,
    required this.onTap,
    required this.fontScale,
    required this.imageScale,
  });

  @override
  Widget build(BuildContext context) {
    bool isTouchDevice = kIsWeb || (Platform.isAndroid || Platform.isIOS);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10 * fontScale),
      child: isTouchDevice
          ? GestureDetector(
        onTap: onTap,
        child: _buildButtonContent(),
      )
          : MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: _buildButtonContent(),
        ),
      ),
    );
  }

  Widget _buildButtonContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isSelected)
          Padding(
            padding: EdgeInsets.only(right: 10 * imageScale),
            child: Image.asset(
              'images/mario.png',
              width: 40 * imageScale,
              height: 40 * imageScale,
            ),
          ),
        Padding(
          padding: EdgeInsets.only(right: 10 * imageScale),
          child: Image.asset(
            imagePath,
            width: 40 * imageScale,
            height: 40 * imageScale,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.error,
                color: Colors.red,
                size: 40 * imageScale,
              );
            },
          ),
        ),
        Text(
          text,
          style: GoogleFonts.pressStart2p(
            fontSize: 16 * fontScale,
            color: isSelected ? Colors.yellow : Colors.white,
          ).copyWith(
            fontFamilyFallback: ['monospace'],
          ),
        ),
      ],
    );
  }
}

class _ArcadeJoystick extends StatefulWidget {
  final double size;
  final Function(String) onDirectionChanged;

  const _ArcadeJoystick({required this.size, required this.onDirectionChanged});

  @override
  _ArcadeJoystickState createState() => _ArcadeJoystickState();
}

class _ArcadeJoystickState extends State<_ArcadeJoystick> with SingleTickerProviderStateMixin {
  Offset _position = Offset.zero;
  late double _maxDistance;
  late AnimationController _controller;
  late Animation<Offset> _animation;
  String _lastDirection = 'Center';
  DateTime _lastUpdate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _maxDistance = widget.size * 0.4;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _animation = Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updatePosition(Offset newPosition) {
    double distance = sqrt(newPosition.dx * newPosition.dx + newPosition.dy * newPosition.dy);
    if (distance > _maxDistance) {
      double angle = atan2(newPosition.dy, newPosition.dx);
      newPosition = Offset(_maxDistance * cos(angle), _maxDistance * sin(angle));
    }
    _animation = Tween<Offset>(begin: _position, end: newPosition).animate(_controller);
    _controller.forward(from: 0);
    _position = newPosition;
    DateTime now = DateTime.now();
    if (now.difference(_lastUpdate).inMilliseconds < 100) return;
    _lastUpdate = now;
    String direction = 'Center';
    if (distance > 10) {
      double angle = atan2(newPosition.dy, newPosition.dx) * 180 / pi;
      if (angle >= -22.5 && angle < 22.5) {
        direction = 'Right';
      } else if (angle >= 22.5 && angle < 67.5) {
        direction = 'BottomRight';
      } else if (angle >= 67.5 && angle < 112.5) {
        direction = 'Down';
      } else if (angle >= 112.5 && angle < 157.5) {
        direction = 'BottomLeft';
      } else if (angle >= 157.5 || angle < -157.5) {
        direction = 'Left';
      } else if (angle >= -157.5 && angle < -112.5) {
        direction = 'TopLeft';
      } else if (angle >= -112.5 && angle < -67.5) {
        direction = 'Up';
      } else if (angle >= -67.5 && angle < -22.5) {
        direction = 'TopRight';
      }
      if (distance < 20) {
        if (direction.contains('Right')) {
          direction = 'MiddleRight';
        } else if (direction.contains('Left')) {
          direction = 'MiddleLeft';
        }
      }
    }
    if (_lastDirection != direction) {
      _lastDirection = direction;
      widget.onDirectionChanged(direction);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        _updatePosition(details.localPosition - Offset(widget.size / 2, widget.size / 2));
      },
      onPanEnd: (details) {
        _updatePosition(Offset.zero);
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey,
          border: Border.all(color: Colors.yellow, width: 3),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.translate(
                offset: _animation.value,
                child: Container(
                  width: widget.size * 0.6,
                  height: widget.size * 0.6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}