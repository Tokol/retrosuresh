import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:suresh_portfilo/utils/device_info.dart';
import 'package:suresh_portfilo/utils/retro_splash_screen.dart';
import 'arcade_landing.dart';
import 'firebase/firebase_service.dart';
import 'providers/chat_provider.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Show splash screen immediately
  runApp(const MaterialApp(
    home: SplashController(),
    debugShowCheckedModeBanner: false,
  ));
}

class SplashController extends StatefulWidget {
  const SplashController({super.key});

  @override
  State<SplashController> createState() => _SplashControllerState();
}

class _SplashControllerState extends State<SplashController> {
  bool _isLoading = true;
  String? _ip;
  Map<String, dynamic>? _userAgent;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final startTime = DateTime.now();

    try {
      await Future.wait([
        FirebaseService.initialize(),
        _fetchUserData(),
      ]);

      // Calculate remaining time to reach minimum 500ms
      final elapsed = DateTime.now().difference(startTime);
      if (elapsed < const Duration(milliseconds: 500)) {
        await Future.delayed(const Duration(milliseconds: 500) - elapsed);
      }

      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('Initialization error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchUserData() async {
    _ip = await _getUserIP();
    _userAgent = await _getUserAgent();
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

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const RetroLoadingScreen()
        : MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ChatProvider(ip: _ip ?? 'unknown', device: _userAgent),
        ),
      ],
      child: const MyApp(),
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