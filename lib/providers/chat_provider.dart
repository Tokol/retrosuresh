import 'package:flutter/material.dart';

class ChatProvider with ChangeNotifier {
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
}
