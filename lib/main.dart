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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  // Initialize providers first
  final providers = await _initializeProviders();

  // Show splash screen with providers
  runApp(
    MultiProvider(
      providers: providers,
      child: const MaterialApp(
        home: SplashController(),
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
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

class SplashController extends StatefulWidget {
  const SplashController({super.key});

  @override
  State<SplashController> createState() => _SplashControllerState();
}

class _SplashControllerState extends State<SplashController> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final startTime = DateTime.now();

    try {
      await FirebaseService.initialize();


      // Calculate remaining time to reach minimum 500ms
      final elapsed = DateTime.now().difference(startTime);
      if (elapsed < const Duration(seconds: 3)) {
        await Future.delayed(const Duration(seconds: 3) - elapsed);
      }

      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('Initialization error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const RetroLoadingScreen()
        : const MyApp();
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