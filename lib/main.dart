import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:suresh_portfilo/utils/device_info.dart';
import 'package:suresh_portfilo/utils/retro_splash_screen.dart';
import 'arcade_landing.dart';
import 'firebase/firebase_service.dart';
import 'providers/chat_provider.dart';
import 'package:http/http.dart' as http;

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MaterialApp(
      home: _InitializationWrapper(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class _InitializationWrapper extends StatefulWidget {
  @override
  State<_InitializationWrapper> createState() => _InitializationWrapperState();
}

class _InitializationWrapperState extends State<_InitializationWrapper> {
  late final Future<List<SingleChildWidget>> _providersFuture;
  bool _providersReady = false;

  @override
  void initState() {
    super.initState();
    _providersFuture = _initializeProviders();
  }

  Future<List<SingleChildWidget>> _initializeProviders() async {
    String? ip;
    Map<String, dynamic>? userAgent;

    try {
      ip = await _getUserIP();
      userAgent = await _getUserAgent();
    } catch (e) {
      debugPrint('Error initializing provider data: $e');
      ip = 'unknown';
      userAgent = {'error': e.toString()};
    }

    return [
      ChangeNotifierProvider(
        create: (_) => ChatProvider(ip: ip, device: userAgent),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SingleChildWidget>>(
      future: _providersFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return MultiProvider(
            providers: snapshot.data!,
            child: const SplashController(),
          );
        }
        return const Material(
          color: Colors.black,
          child: Center(child: CircularProgressIndicator(color: Colors.yellow)),
        );
      },
    );
  }
}

Future<String?> _getUserIP() async {
  try {
    final response = await http.get(Uri.parse('https://api.ipify.org?format=json'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['ip'] as String?;
    }
  } catch (e) {
    debugPrint('Failed to fetch IP: $e');
  }
  return null;
}

Future<Map<String, dynamic>?> _getUserAgent() async {
  if (kIsWeb) {
    try {
      return await WebDeviceInfo.getAllDetails();
    } catch (e) {
      debugPrint('Error getting device info: $e');
      return {'error': e.toString()};
    }
  }
  return {'platform': 'non-web'};
}

class SplashController extends StatelessWidget {
  const SplashController({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: FirebaseService.initialize(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return const MyApp();
        }
        return const RetroLoadingScreen();
      },
    );
  }
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