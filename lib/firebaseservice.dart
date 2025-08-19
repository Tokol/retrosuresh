// lib/firebase/firebase_service.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  static Future<void> initialize() async {
    if (kIsWeb) {
      // 🔑 Replace these with your Firebase Web SDK settings
      const firebaseConfig = FirebaseOptions(
        apiKey: "AIzaSyDezZa7cfR2sMJH20K_e36Dqbn3zCB7cNY",
        authDomain: "operouterpr.firebaseapp.com",
        projectId: "operouterpr",
        storageBucket: "operouterpr.firebasestorage.app",// ⚠️ must end with .appspot.com
        messagingSenderId: "525745997597",
        appId: "1:525745997597:web:b17bc36e55b8505557c3f4",
      );




      await Firebase.initializeApp(options: firebaseConfig);
    } else {
      // Mobile platforms: auto-detects from google-services.json / Info.plist
      await Firebase.initializeApp();
    }
  }
}
