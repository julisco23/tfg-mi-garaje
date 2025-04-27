import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastHelper {
  static void show(String response) {
    if (kIsWeb) {
      print("En web no funciona el toast: $response");
    } else {
      Fluttertoast.showToast(
        msg: response,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }
}
