import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:gif_view/gif_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

import '../../data/datas.dart';
import '../pixel_border.dart';

class TurtleServices extends StatefulWidget {
  const TurtleServices({super.key});

  @override
  State<TurtleServices> createState() => _TurtleServicesState();
}

class _TurtleServicesState extends State<TurtleServices>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  int? _selectedIndex;
  late AnimationController _controller;



  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _activateTurtle(int index) async {
    setState(() => _selectedIndex = index);

    // Play audio using just_audio
    await _audioPlayer.setAsset(turtleServices[index]['sound']);
    await _audioPlayer.setVolume(0.05);
    await _audioPlayer.play();

    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _selectedIndex = null);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.width < 600 ? 700 : 450,

      child: Stack(
        children: [

          Positioned.fill(
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black54,
                BlendMode.darken,
              ),
              child: GifView.asset(
                'images/sewer_bg.gif',
                fit: BoxFit.fill,
               // controller: GifController()..repeat(reverse: true),
              ),
            ),
          ),

          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => CustomPaint(
              painter: OozeDripPainter(_controller.value),
              size: Size.infinite,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  MediaQuery.of(context).size.width < 600
                      ? const SizedBox(height: 10)
                      : const SizedBox(height: 50),
                  Text(
                    'My Services',
                    style: GoogleFonts.pressStart2p(
                      fontSize: 20,
                      color: Colors.cyan,
                      shadows: [
                        const Shadow(color: Colors.greenAccent, blurRadius: 8),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: turtleServices.map((service) {
                            final index = turtleServices.indexOf(service);
                            return SizedBox(
                              width: MediaQuery.of(context).size.width < 600
                                  ? MediaQuery.of(context).size.width * 0.45
                                  : MediaQuery.of(context).size.width < 900
                                  ? MediaQuery.of(context).size.width * 0.3
                                  : MediaQuery.of(context).size.width * 0.22,
                              child: TurtleServiceCard(
                                service: service,
                                isSelected: _selectedIndex == index,
                                onTap: () => _activateTurtle(index),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OozeDripPainter extends CustomPainter {
  final double animationValue;

  OozeDripPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.green.withOpacity(0.5);
    for (int i = 0; i < 5; i++) {
      canvas.drawCircle(
        Offset(
          size.width * (i / 5),
          animationValue * 50,
        ),
        10,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class TurtleServiceCard extends StatefulWidget {
  final Map<String, dynamic> service;
  final bool isSelected;
  final VoidCallback onTap;

  const TurtleServiceCard({
    required this.service,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<TurtleServiceCard> createState() => _TurtleServiceCardState();
}

class _TurtleServiceCardState extends State<TurtleServiceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _shurikenAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shurikenAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (widget.isSelected) {
      _animationController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant TurtleServiceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _animationController.repeat();
    } else if (!widget.isSelected && oldWidget.isSelected) {
      _animationController.stop();
      _animationController.reset();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final turtleSize = screenWidth < 600
        ? 100.0
        : screenWidth < 900
        ? 150.0
        : 200.0;

    return GestureDetector(
      onTap: widget.onTap,
      child: PixelBorderBox(
        borderColor: widget.service['color'],
        scale: 1.5,
        padding: const EdgeInsets.all(4),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.service['color'].withOpacity(0.2),
                widget.service['color'].withOpacity(0.4),
              ],
            ),
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(left: 50, right: 8, bottom: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GifView.asset(
                        widget.service['icon'],
                        height: turtleSize,
                        width: turtleSize,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 4),
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                              color: Colors.black.withOpacity(0.6),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Service Icon
                                  Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: widget.service['color'].withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Image.asset(
                                      widget.service['service_icon'],
                                      width: screenWidth < 600 ? 22 : 36,
                                      height: screenWidth < 600 ? 22 : 36,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  // Service Name
                                  Flexible(
                                    child: Text(
                                      widget.service['name'],
                                      style: GoogleFonts.pressStart2p(
                                        fontSize: screenWidth < 600 ? 7 : 9, // Slightly smaller
                                        color: Colors.cyan,
                                        height: 1.2, // Tighter line height
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: screenWidth < 600 ? 40 : 50,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              color: Colors.black.withOpacity(0.5),
                              child: SingleChildScrollView(
                                child: Text(
                                  widget.service['quote'],
                                  style: GoogleFonts.pressStart2p(
                                    fontSize: screenWidth < 600 ? 6 : 8,
                                    color: widget.isSelected
                                        ? Colors.yellow
                                        : Colors.cyan,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: RotationTransition(
                  turns: _shurikenAnimation,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: widget.isSelected
                          ? [
                        BoxShadow(
                          color: widget.service['color'].withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                          : [],
                    ),
                    child: Image.asset(
                      'images/shuriken.png',
                      width: screenWidth < 600 ? 20 : 30,
                      color: widget.isSelected
                          ? null
                          : Colors.white.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}