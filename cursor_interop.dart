// import 'dart:js/js_wasm.dart';
//
// @JS('flutterSetCursor')
// external void setCustomCursor(String cursorUrl);
//
// @JS('flutterResetCursor')
// external void resetCursor();
//
// class WebCursor {
//   static void setCursor(String imagePath, {String fallback = 'pointer'}) {
//     try {
//       if (imagePath == 'auto') {
//         resetCursor();
//       } else {
//         setCustomCursor(imagePath);
//       }
//     } catch (e) {
//       _setBasicCursor(fallback);
//     }
//   }
//
//   static void reset() {
//     try {
//       resetCursor();
//     } catch (e) {
//       _setBasicCursor('auto');
//     }
//   }
//
//   @JS('document.body.style.cursor')
//   external static set _setBasicCursor(String cursorType);
// }