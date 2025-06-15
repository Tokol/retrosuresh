import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // ✅ Import provider
import 'arcade_landing.dart';
import 'firebase/firebase_service.dart';
import 'providers/chat_provider.dart'; // ✅ Make sure this path is correct
import 'package:firebase_core/firebase_core.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase through your service
  await FirebaseService.initialize();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatProvider()), // ✅ Chat provider
      ],
      child: const MyApp(),
    ),
  );
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
