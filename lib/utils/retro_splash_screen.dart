import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';

import '../firebase/firebase_service.dart';
import '../providers/chat_provider.dart';

class RetroLoadingScreen extends StatefulWidget {
  const RetroLoadingScreen({super.key});

  @override
  State<RetroLoadingScreen> createState() => _RetroLoadingScreenState();
}

class _RetroLoadingScreenState extends State<RetroLoadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progressAnimation;
  bool _assetsLoaded = false;
  double _progress = 0.0;


  Map<String, dynamic>? _device;
  String? _ipv4;
  String? _ipv6;
  String? _apiKey;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _progressAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _initApp();
  }

  Future<void> _initApp() async {
    try {
      // 1️⃣ Initialize Firebase first
      await FirebaseService.initialize();

      // 2️⃣ Get FirebaseAuth instance safely
      final auth = FirebaseAuth.instance;

      // 3️⃣ Ensure user is signed in (anonymous if needed)
      User? user = auth.currentUser;
      if (user == null) {
        final cred = await auth.signInAnonymously();
        user = cred.user;
      }

      // 4️⃣ Load assets, API key, device info, IP addresses concurrently
      await Future.wait([
        _loadAssets(),
      //  _loadApiKey(), // if want to work with open router
        _loadOpenApiKEY(),
        _loadDeviceInfo(),
        _loadIpAddress(),
      ]);

      // 5️⃣ Save unique visitor (Firestore)
      await _saveUniqueVisitor();

      // 6️⃣ Update your ChatProvider with all info
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      chatProvider.updateData(
        ip: {
          "ipv4": _ipv4 ?? "unknown",
          "ipv6": _ipv6 ?? "unknown",
        },
        device: _device ?? {"platform": "unknown"},
        apiKey: _apiKey ?? "",
        user: user,
      );

      // 7️⃣ Navigate to Home screen if mounted
      if (mounted) {
        final currentPath = Uri.base.path; // <-- check current URL
        if (currentPath == '/' || currentPath == '/home') {
          Navigator.pushReplacementNamed(context, "/home");
        }
        // else: do nothing → NotFoundPage will be shown
      }
    } catch (e, stack) {
      debugPrint("❌ Error initializing app: $e");
      debugPrint('$stack');
    }
  }


  Future<void> _loadApiKey() async {
    final doc = await FirebaseFirestore.instance
        .collection("config")
        .doc("apiKeys")
        .get();
    _apiKey = doc.data()?["openRouterKey"];
    _updateProgress();
  }

   Future<void> _loadOpenApiKEY() async {

     final doc = await FirebaseFirestore.instance
         .collection("config")
         .doc("OpenApi")
         .get();
     _apiKey = doc.data()?["Key"];
     _updateProgress();



  }


  Future<void> _loadDeviceInfo() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    final info = await deviceInfoPlugin.deviceInfo;
    _device = info.data;
    _updateProgress();
  }

  Future<Map<String, String?>> _loadIpAddress() async {
    String? ipv4;
    String? ipv6;

    try {
      // Get IPv4
      final res4 = await http.get(Uri.parse("https://api.ipify.org?format=json"));
      if (res4.statusCode == 200) {
        _ipv4 = jsonDecode(res4.body)["ip"];
      }

      // Get IPv6
      final res6 = await http.get(Uri.parse("https://api64.ipify.org?format=json"));
      if (res6.statusCode == 200) {
        _ipv6 = jsonDecode(res6.body)["ip"];
      }
    } catch (e) {
      print("Failed to get IPs: $e");
    }

    return {"ipv4": ipv4, "ipv6": ipv6};
  }

  Future<void> _loadAssets() async {
    try {
      await precacheImage(const AssetImage("images/splash_bg.jpg"), context);
      if (mounted) {
        setState(() => _assetsLoaded = true);
      }
    } catch (_) {}
    _updateProgress();
  }

  void _updateProgress() {
    setState(() {
      _progress += 0.25;
      _controller.animateTo(_progress);
    });
  }


  Future<void> _saveUniqueVisitor() async {
    try {
      if (_ipv4 == null && _ipv6 == null) return; // no IPs found

      final visitors = FirebaseFirestore.instance.collection("visitors");

      // 🔍 Check if either IPv4 or IPv6 already exists
      final query = await visitors
          .where("ipv4", isEqualTo: _ipv4)
          .get();

      final query2 = await visitors
          .where("ipv6", isEqualTo: _ipv6)
          .get();

      if (query.docs.isNotEmpty || query2.docs.isNotEmpty) {
        debugPrint("👀 Visitor already exists, not saving.");
        return; // ✅ already exists
      }

      // ✅ Save new visitor
      await visitors.add({
        "ipv4": _ipv4 ?? "unknown",
        "ipv6": _ipv6 ?? "unknown",
        "device": _device != null ? sanitizeForFirestore(_device!) : {},
        "timestamp": FieldValue.serverTimestamp(),
      });

      debugPrint("🎉 New unique visitor saved!");
    } catch (e) {
      debugPrint("❌ Error saving visitor: $e");
    }
  }


  Map<String, dynamic> sanitizeForFirestore(Map<String, dynamic> input) {
    Map<String, dynamic> output = {};

    input.forEach((key, value) {
      if (value == null) {
        output[key] = "unknown";
      } else if (value is String || value is num || value is bool) {
        output[key] = value;
      } else if (value is Enum) {
        output[key] = value.name;
      } else if (value is Map) {
        output[key] = sanitizeForFirestore(Map<String, dynamic>.from(value));
      } else if (value is List) {
        output[key] = value.map((e) {
          if (e == null) return "unknown";
          if (e is String || e is num || e is bool) return e;
          if (e is Enum) return e.name;
          if (e is Map) return sanitizeForFirestore(Map<String, dynamic>.from(e));
          return e.toString();
        }).toList();
      } else {
        output[key] = value.toString();
      }
    });

    return output;
  }



  Widget _buildPixelLoadingBar(double progress) {
    const int totalSegments = 12;
    final int filledSegments = (progress * totalSegments).floor();

    return Container(
      height: 28,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.black, Colors.red],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border.all(color: Colors.yellow, width: 2),
      ),
      child: Row(
        children: List.generate(totalSegments, (index) {
          final isFilled = index < filledSegments;
          final glitchEffect =
              isFilled && ((_controller.value * 20 % 1) > 0.85);

          return Expanded(
            child: Container(
              margin: const EdgeInsets.all(1.5),
              decoration: BoxDecoration(
                color: isFilled
                    ? (glitchEffect ? Colors.pink : Colors.yellow)
                    : Colors.grey[900],
                border: Border.all(color: Colors.black, width: 1),
              ),
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          Container(color: Colors.black),

          if (_assetsLoaded)
            Positioned.fill(
              child: Image.asset(
                "images/splash_bg.jpg",
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),

          Container(color: Colors.black.withOpacity(0.6)),

          Positioned(
            bottom: screenHeight * 0.08,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, _) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "LOADING...",
                      style: GoogleFonts.pressStart2p(
                        fontSize: 14,
                        color: Colors.yellow,
                        shadows: [
                          Shadow(
                            color: Colors.red.withOpacity(0.7),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: _buildPixelLoadingBar(_progressAnimation.value),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "${(_progress * 100).toStringAsFixed(0)}%",
                      style: GoogleFonts.pressStart2p(
                        fontSize: 10,
                        color: Colors.yellow,
                        shadows: [
                          Shadow(
                            color: Colors.red.withOpacity(0.5),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
