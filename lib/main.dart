// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'arcade_landing.dart';
import 'firebase/firebase_service.dart';
import 'notfound404/notfound.dart';
import 'providers/chat_provider.dart';
import 'utils/retro_splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Web + Mobile safe init
  await FirebaseService.initialize();

  runApp(
    MultiProvider(
      providers: [
        // Create ChatProvider with empty/default values
        ChangeNotifierProvider(
          create: (_) => ChatProvider(ip: {}, device: {}, apiKey: ""),
        ),
      ],
      child: const AppRoot(),
    ),
  );
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Suresh’s Retro Arcade',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
          case null:
            return MaterialPageRoute(
              builder: (_) => const RetroLoadingScreen(),
              settings: settings,
            );

          case '/home':
            return MaterialPageRoute(builder: (_) => const ArcadeLanding());
        }

        return null;
      },
      onUnknownRoute: (settings) {
        final raw = settings.name ?? Uri.base.toString();
        final requested = Uri.tryParse(raw)?.path ?? raw;
        return MaterialPageRoute(
          builder: (_) => NotFoundPage(requested: requested),
        );
      },
    );
  }
}
