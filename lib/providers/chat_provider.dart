import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatProvider with ChangeNotifier {
  Map<String, String>? ip;
  Map<String, dynamic>? device;
  String? apiKey;
  User? firebaseUser;

  ChatProvider({
    required this.ip,
    required this.device,
    required this.apiKey,
    this.firebaseUser,
  });

  final List<Map<String, String>> _messages = [];
  List<Map<String, String>> get messages => _messages;

  void addUserMessage(String text) {
    _messages.add({"role": "user", "text": text});
    notifyListeners();
  }

  void addAssistantMessage(String text) {
    _messages.add({"role": "assistant", "text": text});
    notifyListeners();
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }

  // ✅ Normalize device here
  void updateData({
    required Map<String, String> ip,
    required Map<String, dynamic> device,
    required String apiKey,
    User? user,
  }) {
    this.ip = ip;
    this.device = sanitizeForFirestore(device);
    this.apiKey = apiKey;
    this.firebaseUser = user;
    notifyListeners();
  }


  Map<String, dynamic> sanitizeForFirestore(Map<String, dynamic> input) {
    Map<String, dynamic> output = {};

    input.forEach((key, value) {
      if (value == null) {
        output[key] = "unknown";
      } else if (value is String || value is num || value is bool) {
        output[key] = value;
      } else if (value is Enum) {
        output[key] = value.name; // ✅ store clean enum name
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

}

