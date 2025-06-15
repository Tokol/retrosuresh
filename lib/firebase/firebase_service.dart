import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Initialize Firebase (call this in main.dart)
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDezZa7cfR2sMJH20K_e36Dqbn3zCB7cNY",
        authDomain: "operouterpr.firebaseapp.com",
        projectId: "operouterpr",
        storageBucket: "operouterpr.firebasestorage.app",
        messagingSenderId: "525745997597",
        appId: "1:525745997597:web:b17bc36e55b8505557c3f4",
      ),
    );
  }

  // Fetch OpenRouter key (with cache)
  static Future<String> getOpenRouterKey() async {
    try {
      final doc = await _firestore
          .collection('config')
          .doc('apiKeys')
          .get(const GetOptions(source: Source.server)); // Force fresh fetch
      return doc.data()?['openRouterKey'] ?? '';
    } catch (e) {
      throw Exception('API key fetch failed. Ensure Firestore rules allow access.');
    }
  }

  // Save message with error handling
  static Future<void> saveChatMessage({
    required String userId,
    required String role,
    required String text,
  }) async {
    try {
      await _firestore.collection('chats').add({
        'userId': userId,
        'role': role,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
        'ip': '', // Consider adding for security (get from request if server-side)
      });
    } catch (e) {
      throw Exception('Message save failed. User: $userId. Error: $e');
    }
  }

  // Optional: Get chat history
  static Stream<QuerySnapshot> getChatHistory(String userId) {
    return _firestore
        .collection('chats')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}