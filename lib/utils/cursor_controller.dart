import 'dart:ui';

abstract class CursorController {
  void showCustomCursor(String imagePath);
  void hideCustomCursor();
  void updateCursorPosition(Offset position);
}