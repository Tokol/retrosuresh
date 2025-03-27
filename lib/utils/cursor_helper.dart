// import 'package:flutter/foundation.dart';
//
// class CursorHelper {
//   static bool get isWeb => kIsWeb;
//
//   /// Sets cursor with platform-specific implementation
//   static void setCursor({
//     required String imagePath,
//     String webFallback = 'pointer',
//     required Function() nativeCallback,
//   }) {
//     if (isWeb) {
//       _setWebCursor(imagePath, webFallback);
//     } else {
//       nativeCallback();
//     }
//   }
//
//   /// Resets cursor with platform-specific implementation
//   static void resetCursor({
//     required Function() nativeCallback,
//   }) {
//     if (isWeb) {
//       _resetWebCursor();
//     } else {
//       nativeCallback();
//     }
//   }
//
//   // Web-specific implementations
//   static void _setWebCursor(String imagePath, String fallback) {
//     try {
//       // Conditional import for web-only code
//       if (isWeb) {
//         import('package:your_app/web/cursor_interop.dart')
//             .then((module) {
//           module.WebCursor.setCursor(imagePath, fallback: fallback);
//         });
//       }
//     } catch (e) {
//       debugPrint('Web cursor error: $e');
//     }
//   }
//
//   static void _resetWebCursor() {
//     try {
//       if (isWeb) {
//         import('package:your_app/web/cursor_interop.dart')
//             .then((module) {
//           module.WebCursor.resetCursor();
//         });
//       }
//     } catch (e) {
//       debugPrint('Web cursor reset error: $e');
//     }
//   }
// }