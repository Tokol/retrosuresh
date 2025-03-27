import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:suresh_portfilo/widgets/pixel_border.dart';
import 'package:suresh_portfilo/widgets/space_invaders/pixel_scanlines_painter.dart';

class SpaceInvadersForm extends StatelessWidget {
  final AnimationController flickerController;
  final double dynamicScale;
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController messageController;
  final VoidCallback onLaunch;
  final VoidCallback onTyping;

  const SpaceInvadersForm({
    super.key,
    required this.flickerController,
    required this.dynamicScale,
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.messageController,
    required this.onLaunch,
    required this.onTyping,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'images/space_invader_bg.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              debugPrint('Error loading form background: $error');
              return Container(
                color: Colors.black,
                child: const Center(
                  child: Text(
                    'Form Background Missing',
                    style: TextStyle(color: Colors.red, fontSize: 20),
                  ),
                ),
              );
            },
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: PixelScanlinesPainter(
              lineHeight: 1 * dynamicScale,
              spacing: 3 * dynamicScale,
              opacity: 0.1,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(8 * dynamicScale),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: flickerController,
                builder: (context, child) {
                  return Opacity(
                    opacity: 0.7 + (flickerController.value * 0.3),
                    child: Text(
                      'Contact Me and \nBLAST YOUR MESSAGE TO SPACE!',
                      style: GoogleFonts.pressStart2p(
                        fontSize: 14 * dynamicScale, // Reduced from 16
                        color: const Color(0xFF00FF00),
                        shadows: [
                          Shadow(
                            color: Colors.greenAccent,
                            offset: Offset(1 * dynamicScale, 2 * dynamicScale),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
              SizedBox(height: 12 * dynamicScale), // Reduced from 16
              Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PixelBorderBox(
                      height: 40 * dynamicScale, // Reduced from 50
                      borderColor: const Color(0xFFFF00FF),
                      scale: dynamicScale,
                      child: TextFormField(
                        controller: nameController,
                        style: GoogleFonts.vt323(
                          fontSize: 14 * dynamicScale, // Reduced from 16
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Name',
                          hintStyle: GoogleFonts.vt323(
                            fontSize: 14 * dynamicScale, // Reduced from 16
                            color: Colors.white70,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(6 * dynamicScale),
                          errorStyle: GoogleFonts.pressStart2p( // More noticeable pixel font
                            fontSize: 8,
                            color: const Color(0xFFFF5555),
                            letterSpacing: 0.5,
                          ),// Reduced from 8
                        ),
                        validator: (value) =>
                        value?.isEmpty ?? true ? 'Please enter your name' : null,
                        onChanged: (_) => onTyping(),
                      ),
                    ),
                    SizedBox(height: 12 * dynamicScale), // Reduced from 8
                    PixelBorderBox(
                      height: 40 * dynamicScale, // Reduced from 50
                      borderColor: const Color(0xFF00FFFF),
                      scale: dynamicScale,
                      child: TextFormField(
                        controller: emailController,
                        style: GoogleFonts.vt323(
                          fontSize: 14 * dynamicScale, // Reduced from 16
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Email',
                          hintStyle: GoogleFonts.vt323(
                            fontSize: 14 * dynamicScale, // Reduced from 16
                            color: Colors.white70,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(6 * dynamicScale),
                          errorStyle: GoogleFonts.pressStart2p( // More noticeable pixel font
                            fontSize: 8,
                            color: const Color(0xFFFF5555),
                            letterSpacing: 0.5,
                          ),// Reduced from 8
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Please enter your email';
                          if (!value!.contains('@') || !value.contains('.')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                        onChanged: (_) => onTyping(),
                      ),
                    ),
                    SizedBox(height: 12 * dynamicScale), // Reduced from 8
                    PixelBorderBox(
                      height: 80 * dynamicScale, // Reduced from 100
                      borderColor: const Color(0xFFFFFF00),
                      scale: dynamicScale,
                      child: TextFormField(
                        controller: messageController,
                        style: GoogleFonts.vt323(
                          fontSize: 14 * dynamicScale, // Reduced from 16
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Message',
                          hintStyle: GoogleFonts.vt323(
                            fontSize: 14 * dynamicScale, // Reduced from 16
                            color: Colors.white70,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(6 * dynamicScale),
                          errorStyle: GoogleFonts.pressStart2p( // More noticeable pixel font
                            fontSize: 8,
                            color: const Color(0xFFFF5555),
                            letterSpacing: 0.5,
                          ),// Reduced from 8
                        ),
                        maxLines: 3,
                        validator: (value) =>
                        value?.isEmpty ?? true ? 'Please enter your message' : null,
                        onChanged: (_) => onTyping(),
                      ),
                    ),
                    SizedBox(height: 12 * dynamicScale), // Reduced from 16
                    GestureDetector(
                      onTap: onLaunch,
                      child: Container(
                        width: 90 * dynamicScale, // Reduced from 100
                        height: 35 * dynamicScale, // Reduced from 40
                        decoration: BoxDecoration(
                          color: Colors.black,
                          border: Border.all(
                            color: formKey.currentState?.validate() ?? false
                                ? const Color(0xFFFF00FF)
                                : Colors.grey,
                            width: 2 * dynamicScale,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'LAUNCH',
                            style: GoogleFonts.pressStart2p(
                              fontSize: 12 * dynamicScale, // Reduced from 14
                              color: formKey.currentState?.validate() ?? false
                                  ? const Color(0xFFFF00FF)
                                  : Colors.grey,
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
        ),
      ],
    );
  }
}