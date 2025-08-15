// lib/main.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_web_plugins/url_strategy.dart';

import 'arcade_landing.dart';
import 'firebase/firebase_service.dart';
import 'notfound404/notfound.dart';
import 'providers/chat_provider.dart';
import 'utils/device_info.dart';
import 'utils/retro_splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy(); // pretty URLs on web

  final providers = await _initializeProviders();

  runApp(
    MultiProvider(
      providers: providers,
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

      // Handle only known routes here
      onGenerateRoute: (settings) {
        // Browser deep-link path (e.g., "/this/does/not/exist")
        final browserPath = _normalizedPath(Uri.base);

        switch (settings.name) {
          case '/':
          case null:
          // If browser path isn't root, treat it as an unknown deep link -> 404 page
            if (browserPath != '/') {
              return MaterialPageRoute(
                builder: (_) => NotFoundPage(requested: browserPath),
                settings: settings,
              );
            }
            // Normal home
            return MaterialPageRoute(builder: (_) => const SplashController());

        // Add actual named pages here later:
        // case '/arcade':
        //   return MaterialPageRoute(builder: (_) => const ArcadeLanding());
        }

        // Unhandled -> let onUnknownRoute show the 404 page
        return null;
      },

      // Unknown path -> interactive 404
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

// Normalize / strip trailing slash (except root)
String _normalizedPath(Uri u) {
  final path = (u.path.isEmpty ? '/' : u.path);
  if (path.length > 1 && path.endsWith('/')) return path.substring(0, path.length - 1);
  return path;
}

// ---------- Providers ----------
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
    ChangeNotifierProvider(create: (_) => ChatProvider(ip: ip, device: userAgent)),
  ];
}

Future<String?> _getUserIP() async {
  try {
    final res = await http.get(Uri.parse('https://api.ipify.org?format=json'));
    if (res.statusCode == 200) {
      return (jsonDecode(res.body)['ip'] as String?) ?? 'unknown';
    }
  } catch (e) {
    debugPrint('Failed to fetch IP: $e');
  }
  return 'unknown';
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

// ---------- Splash -> App entry (NO nested MaterialApp) ----------
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
    final start = DateTime.now();
    try {
      await FirebaseService.initialize();

      // keep your retro splash visible a bit
      final elapsed = DateTime.now().difference(start);
      const min = Duration(seconds: 3);
      if (elapsed < min) {
        await Future.delayed(min - elapsed);
      }
    } catch (e) {
      debugPrint('Initialization error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading ? const RetroLoadingScreen() : const ArcadeLanding();
  }
}
