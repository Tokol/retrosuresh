import 'package:flutter/material.dart';

import 'arcade_landing.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Suresh’s Retro Arcade',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: const ArcadeLanding(),
    );
  }
}







// Blinking Text

// Arcade Joystick (Now Functional)


// Arcade Button


// Portfolio Screen
