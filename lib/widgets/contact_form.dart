// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:suresh_portfilo/widgets/pixel_border.dart';
//
// class _PixelScanlinesPainter extends CustomPainter {
//   final double lineHeight;
//   final double spacing;
//   final double opacity;
//
//   const _PixelScanlinesPainter({
//     required this.lineHeight,
//     required this.spacing,
//     required this.opacity,
//   });
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.white.withOpacity(opacity)
//       ..style = PaintingStyle.fill;
//
//     final lineSpacing = lineHeight + spacing;
//     final lineCount = (size.height / lineSpacing).ceil();
//
//     for (var i = 0; i < lineCount; i++) {
//       final y = i * lineSpacing;
//       canvas.drawRect(
//         Rect.fromLTWH(0, y, size.width, lineHeight),
//         paint,
//       );
//     }
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }
//
// class SpaceInvadersMessageBlaster extends StatefulWidget {
//   final double scale;
//
//   const SpaceInvadersMessageBlaster({
//     super.key,
//     this.scale = 1.0,
//   });
//
//   @override
//   State<SpaceInvadersMessageBlaster> createState() =>
//       _SpaceInvadersMessageBlasterState();
// }
//
// class _SpaceInvadersMessageBlasterState
//     extends State<SpaceInvadersMessageBlaster> with TickerProviderStateMixin {
//   // Form state
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _messageController = TextEditingController();
//
//   // Screen state
//   bool _isGameScreen = false;
//   bool _isSuccess = false;
//
//   // Animation controllers
//   late AnimationController _flickerController;
//   late AnimationController _projectileController;
//   late AnimationController _explosionController;
//
//   // Game state
//   double _spaceshipX = 0.5;
//   double? _projectileY;
//   bool _isProjectileFired = false;
//
//   // Audio players
//   late AudioPlayer _laserPlayer;
//   late AudioPlayer _explosionPlayer;
//   late AudioPlayer _jinglePlayer;
//   late AudioPlayer _typingPlayer;
//   late AudioPlayer _errorPlayer;
//
//   // Throttle drag updates to prevent MouseTracker conflicts
//   DateTime _lastDragUpdate = DateTime.now();
//   final Duration _debounceDuration = const Duration(milliseconds: 16); // ~60 FPS
//
//   // Dynamic scale factor based on screen size
//   late double _dynamicScale;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeAnimations();
//     _initializeAudio();
//   }
//
//   Future<void> _initializeAnimations() async {
//     _flickerController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 3000),
//     )..repeat(reverse: true);
//
//     _projectileController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1000),
//     )..addListener(() {
//       setState(() {
//         _projectileY = 1.0 - _projectileController.value;
//         if (_projectileY != null && _projectileY! < 0.1) {
//           _projectileController.stop();
//           _isProjectileFired = false;
//           _projectileY = null;
//           _explosionController.forward();
//           _explosionPlayer.play();
//         }
//       });
//     });
//
//     _explosionController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 500),
//     )..addStatusListener((status) {
//       if (status == AnimationStatus.completed) {
//         setState(() => _isSuccess = true);
//         _jinglePlayer.play();
//       }
//     });
//   }
//
//   Future<void> _initializeAudio() async {
//     _laserPlayer = AudioPlayer();
//     _explosionPlayer = AudioPlayer();
//     _jinglePlayer = AudioPlayer();
//     _typingPlayer = AudioPlayer();
//     _errorPlayer = AudioPlayer();
//
//     try {
//       await _laserPlayer.setAsset('assets/laser_shoot.wav');
//       await _explosionPlayer.setAsset('assets/explosion.wav');
//       await _jinglePlayer.setAsset('assets/success.wav');
//       await _typingPlayer.setAsset('assets/ckack.m4a');
//       await _errorPlayer.setAsset('assets/error_bleep.flac');
//     } catch (e) {
//       debugPrint('Error loading audio: $e');
//     }
//   }
//
//   @override
//   void dispose() {
//     _flickerController.dispose();
//     _projectileController.dispose();
//     _explosionController.dispose();
//     _nameController.dispose();
//     _emailController.dispose();
//     _messageController.dispose();
//     _laserPlayer.dispose();
//     _explosionPlayer.dispose();
//     _jinglePlayer.dispose();
//     _typingPlayer.dispose();
//     _errorPlayer.dispose();
//     super.dispose();
//   }
//
//   void _launchGame() {
//     if (_formKey.currentState!.validate()) {
//       // Reset all game states
//       _explosionController.reset();
//       _projectileController.reset();
//
//       setState(() {
//         _isGameScreen = true;
//         _isSuccess = false;
//         _spaceshipX = 0.5;
//         _projectileY = null;
//         _isProjectileFired = false;
//       });
//
//       // Force a frame update
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         setState(() {});
//       });
//     } else {
//       _errorPlayer.play();
//     }
//   }
//
//   void _fireProjectile() {
//     if (!_isProjectileFired) {
//       _isProjectileFired = true;
//       _projectileY = 1.0;
//       _projectileController.forward(from: 0.0);
//       _laserPlayer.play();
//     }
//   }
//
//   void _resetForm() {
//     setState(() {
//       _isGameScreen = false;
//       _isSuccess = false;
//       _nameController.clear();
//       _emailController.clear();
//       _messageController.clear();
//     });
//   }
//
//   Future<void> _playTypingSound() async {
//     try {
//       await _typingPlayer.seek(Duration.zero);
//       await _typingPlayer.play();
//     } catch (e) {
//       debugPrint('Error playing typing sound: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // Calculate dynamic scale based on screen width
//     final screenWidth = MediaQuery.of(context).size.width;
//     _dynamicScale = widget.scale * (screenWidth / 600); // Adjusted reference width to 600px to reduce zoom
//
//     // Calculate game height
//     final screenHeight = MediaQuery.of(context).size.height;
//     final gameHeight = screenHeight * 0.8; // Game height as a percentage of screen height
//
//     return _isGameScreen
//         ? SizedBox(
//       height: gameHeight,
//       width: double.infinity, // Take full available width
//       child: _buildGameScreen(),
//     )
//         : _buildFormScreen();
//   }
//
//   Widget _buildFormScreen() {
//     return Stack(
//       children: [
//         Positioned.fill(
//           child: Image.asset(
//             'images/space_invader_bg.jpg',
//             fit: BoxFit.cover,
//             errorBuilder: (context, error, stackTrace) {
//               debugPrint('Error loading form background: $error');
//               return Container(
//                 color: Colors.black,
//                 child: const Center(
//                   child: Text(
//                     'Form Background Missing',
//                     style: TextStyle(color: Colors.red, fontSize: 20),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//         Positioned.fill(
//           child: CustomPaint(
//             painter: _PixelScanlinesPainter(
//               lineHeight: 1 * _dynamicScale,
//               spacing: 3 * _dynamicScale,
//               opacity: 0.1,
//             ),
//           ),
//         ),
//         Padding(
//           padding: EdgeInsets.all(16 * _dynamicScale),
//           child: Column(
//             mainAxisSize: MainAxisSize.min, // Wrap content height
//             children: [
//               AnimatedBuilder(
//                 animation: _flickerController,
//                 builder: (context, child) {
//                   return Opacity(
//                     opacity: 0.7 + (_flickerController.value * 0.3),
//                     child: Text(
//                       'BLAST YOUR MESSAGE TO SPACE!',
//                       style: GoogleFonts.pressStart2p(
//                         fontSize: 16 * _dynamicScale,
//                         color: const Color(0xFF00FF00),
//                         shadows: [
//                           Shadow(
//                             color: Colors.greenAccent,
//                             offset: Offset(1 * _dynamicScale, 2 * _dynamicScale),
//                             blurRadius: 0,
//                           ),
//                         ],
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   );
//                 },
//               ),
//               SizedBox(height: 24 * _dynamicScale),
//               Form(
//                 key: _formKey,
//                 autovalidateMode: AutovalidateMode.onUserInteraction,
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min, // Wrap content height
//                   children: [
//                     PixelBorderBox(
//                       height: 50 * _dynamicScale,
//                       borderColor: const Color(0xFFFF00FF),
//                       scale: _dynamicScale,
//                       child: TextFormField(
//                         controller: _nameController,
//                         style: GoogleFonts.vt323(
//                           fontSize: 16 * _dynamicScale,
//                           color: Colors.white,
//                         ),
//                         decoration: InputDecoration(
//                           hintText: 'Name',
//                           hintStyle: GoogleFonts.vt323(
//                             fontSize: 16 * _dynamicScale,
//                             color: Colors.white70,
//                           ),
//                           border: InputBorder.none,
//                           contentPadding: EdgeInsets.all(8 * _dynamicScale),
//                         ),
//                         validator: (value) =>
//                         value?.isEmpty ?? true ? 'Please enter your name' : null,
//                         onChanged: (_) {
//                           setState(() {});
//                           _playTypingSound();
//                         },
//                       ),
//                     ),
//                     SizedBox(height: 16 * _dynamicScale),
//                     PixelBorderBox(
//                       height: 50 * _dynamicScale,
//                       borderColor: const Color(0xFF00FFFF),
//                       scale: _dynamicScale,
//                       child: TextFormField(
//                         controller: _emailController,
//                         style: GoogleFonts.vt323(
//                           fontSize: 16 * _dynamicScale,
//                           color: Colors.white,
//                         ),
//                         decoration: InputDecoration(
//                           hintText: 'Email',
//                           hintStyle: GoogleFonts.vt323(
//                             fontSize: 16 * _dynamicScale,
//                             color: Colors.white70,
//                           ),
//                           border: InputBorder.none,
//                           contentPadding: EdgeInsets.all(8 * _dynamicScale),
//                         ),
//                         validator: (value) {
//                           if (value?.isEmpty ?? true) return 'Please enter your email';
//                           if (!value!.contains('@') || !value.contains('.')) {
//                             return 'Please enter a valid email';
//                           }
//                           return null;
//                         },
//                         onChanged: (_) {
//                           setState(() {});
//                           _playTypingSound();
//                         },
//                       ),
//                     ),
//                     SizedBox(height: 16 * _dynamicScale),
//                     PixelBorderBox(
//                       height: 100 * _dynamicScale,
//                       borderColor: const Color(0xFFFFFF00),
//                       scale: _dynamicScale,
//                       child: TextFormField(
//                         controller: _messageController,
//                         style: GoogleFonts.vt323(
//                           fontSize: 16 * _dynamicScale,
//                           color: Colors.white,
//                         ),
//                         decoration: InputDecoration(
//                           hintText: 'Message',
//                           hintStyle: GoogleFonts.vt323(
//                             fontSize: 16 * _dynamicScale,
//                             color: Colors.white70,
//                           ),
//                           border: InputBorder.none,
//                           contentPadding: EdgeInsets.all(8 * _dynamicScale),
//                         ),
//                         maxLines: 3,
//                         validator: (value) =>
//                         value?.isEmpty ?? true ? 'Please enter your message' : null,
//                         onChanged: (_) {
//                           setState(() {});
//                           _playTypingSound();
//                         },
//                       ),
//                     ),
//                     SizedBox(height: 24 * _dynamicScale),
//                     GestureDetector(
//                       onTap: _launchGame,
//                       child: Container(
//                         width: 100 * _dynamicScale,
//                         height: 40 * _dynamicScale,
//                         decoration: BoxDecoration(
//                           color: Colors.black,
//                           border: Border.all(
//                             color: _formKey.currentState?.validate() ?? false
//                                 ? const Color(0xFFFF00FF)
//                                 : Colors.grey,
//                             width: 2 * _dynamicScale,
//                           ),
//                         ),
//                         child: Center(
//                           child: Text(
//                             'LAUNCH',
//                             style: GoogleFonts.pressStart2p(
//                               fontSize: 14 * _dynamicScale,
//                               color: _formKey.currentState?.validate() ?? false
//                                   ? const Color(0xFFFF00FF)
//                                   : Colors.grey,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildGameScreen() {
//     return GestureDetector(
//       onTap: _fireProjectile,
//       onHorizontalDragUpdate: (details) {
//         final now = DateTime.now();
//         if (now.difference(_lastDragUpdate) < _debounceDuration) {
//           return; // Skip update if too soon
//         }
//         _lastDragUpdate = now;
//
//         setState(() {
//           _spaceshipX += details.delta.dx / MediaQuery.of(context).size.width;
//           _spaceshipX = _spaceshipX.clamp(0.0, 1.0);
//         });
//       },
//       child: Stack(
//         children: [
//           Positioned.fill(
//             child: Image.asset(
//               'images/space_invader_bg.jpg',
//               fit: BoxFit.cover,
//               errorBuilder: (context, error, stackTrace) {
//                 debugPrint('Error loading game background: $error');
//                 return Container(
//                   color: Colors.black,
//                   child: const Center(
//                     child: Text(
//                       'Game Background Missing',
//                       style: TextStyle(color: Colors.red, fontSize: 20),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//           Positioned.fill(
//             child: CustomPaint(
//               painter: _PixelScanlinesPainter(
//                 lineHeight: 1 * _dynamicScale,
//                 spacing: 3 * _dynamicScale,
//                 opacity: 0.3,
//               ),
//             ),
//           ),
//           Positioned(
//             left: _spaceshipX *
//                 (MediaQuery.of(context).size.width - 32 * _dynamicScale),
//             bottom: 16 * _dynamicScale,
//             child: Image.asset(
//               'images/battleship.png',
//               width: 32 * _dynamicScale,
//               height: 32 * _dynamicScale,
//               fit: BoxFit.contain,
//               errorBuilder: (context, error, stackTrace) {
//                 debugPrint('Error loading battleship: $error');
//                 return Container(
//                   width: 32 * _dynamicScale,
//                   height: 32 * _dynamicScale,
//                   color: Colors.blue,
//                   child: const Center(
//                     child: Text(
//                       'Ship',
//                       style: TextStyle(color: Colors.white, fontSize: 10),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//           if (!_isSuccess)
//             Positioned(
//               left: (MediaQuery.of(context).size.width - 16 * _dynamicScale) / 2,
//               top: 16 * _dynamicScale,
//               child: Image.asset(
//                 'images/alien.png',
//                 width: 16 * _dynamicScale,
//                 height: 16 * _dynamicScale,
//                 fit: BoxFit.contain,
//                 errorBuilder: (context, error, stackTrace) {
//                   debugPrint('Error loading alien: $error');
//                   return Container(
//                     width: 16 * _dynamicScale,
//                     height: 16 * _dynamicScale,
//                     color: Colors.green,
//                     child: const Center(
//                       child: Text(
//                         'Alien',
//                         style: TextStyle(color: Colors.white, fontSize: 8),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           if (_isProjectileFired)
//             AnimatedBuilder(
//               animation: _projectileController,
//               builder: (context, child) {
//                 if (_projectileY == null) {
//                   return const SizedBox.shrink();
//                 }
//                 return Positioned(
//                   left: _spaceshipX *
//                       (MediaQuery.of(context).size.width - 16 * _dynamicScale) +
//                       (16 * _dynamicScale),
//                   bottom: _projectileY! *
//                       (MediaQuery.of(context).size.height - 32 * _dynamicScale),
//                   child: Image.asset(
//                     'images/envelope.png',
//                     width: 16 * _dynamicScale,
//                     height: 16 * _dynamicScale,
//                     fit: BoxFit.contain,
//                     errorBuilder: (context, error, stackTrace) {
//                       debugPrint('Error loading envelope: $error');
//                       return Container(
//                         width: 16 * _dynamicScale,
//                         height: 16 * _dynamicScale,
//                         color: Colors.white,
//                         child: const Center(
//                           child: Text(
//                             'Proj',
//                             style: TextStyle(color: Colors.black, fontSize: 8),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 );
//               },
//             ),
//           if (_explosionController.isAnimating)
//             Positioned(
//               left: (MediaQuery.of(context).size.width - 32 * _dynamicScale) / 2,
//               top: 16 * _dynamicScale,
//               child: AnimatedBuilder(
//                 animation: _explosionController,
//                 builder: (context, child) {
//                   final frame = (_explosionController.value * 4).floor();
//                   return Image.asset(
//                     'images/explosion_${frame + 1}.png', // Fixed typo: explosion${frame + 1} to explosion_${frame + 1}
//                     width: 32 * _dynamicScale,
//                     height: 32 * _dynamicScale,
//                     fit: BoxFit.contain,
//                     errorBuilder: (context, error, stackTrace) {
//                       debugPrint('Error loading explosion frame: $error');
//                       return Container(
//                         width: 32 * _dynamicScale,
//                         height: 32 * _dynamicScale,
//                         color: Colors.red,
//                         child: const Center(
//                           child: Text(
//                             'Boom',
//                             style: TextStyle(color: Colors.white, fontSize: 10),
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//           if (_isSuccess)
//             Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     'MESSAGE SENT!',
//                     style: GoogleFonts.pressStart2p(
//                       fontSize: 24 * _dynamicScale,
//                       color: const Color(0xFF00FF00),
//                       shadows: [
//                         Shadow(
//                           color: Colors.greenAccent,
//                           offset: Offset(1 * _dynamicScale, 2 * _dynamicScale),
//                           blurRadius: 0,
//                         ),
//                       ],
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   SizedBox(height: 24 * _dynamicScale),
//                   GestureDetector(
//                     onTap: _resetForm,
//                     child: Container(
//                       width: 150 * _dynamicScale,
//                       height: 40 * _dynamicScale,
//                       decoration: BoxDecoration(
//                         color: Colors.black,
//                         border: Border.all(
//                           color: const Color(0xFFFF00FF),
//                           width: 2 * _dynamicScale,
//                         ),
//                       ),
//                       child: Center(
//                         child: Text(
//                           'SEND ANOTHER',
//                           style: GoogleFonts.pressStart2p(
//                             fontSize: 16 * _dynamicScale,
//                             color: const Color(0xFFFF00FF),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }