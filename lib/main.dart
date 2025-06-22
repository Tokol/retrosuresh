import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // ✅ Import provider
import 'package:suresh_portfilo/utils/device_info.dart';
import 'arcade_landing.dart';
import 'firebase/firebase_service.dart';
import 'providers/chat_provider.dart'; // ✅ Make sure this path is correct

import 'package:http/http.dart' as http;


void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  // Initialize Firebase through your service
  await FirebaseService.initialize();
  final ip = await _getUserIP();
  final userAgent = await _getUserAgent();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider( create: (_) => ChatProvider(ip: ip ?? 'unknown', device: userAgent), ), // ✅ Chat provider
      ],
      child: const MyApp(),
    ),
  );
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
