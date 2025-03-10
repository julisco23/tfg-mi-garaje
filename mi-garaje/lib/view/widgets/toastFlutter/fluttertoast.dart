import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastHelper {
  static void show(BuildContext context, String response) {
    if (kIsWeb) {
      // Si estamos en la web, muestra un Snackbar en lugar de un toast.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response),
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      Fluttertoast.showToast(
        msg: response,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Theme.of(context).primaryColor,
      );
    }
  }
}
