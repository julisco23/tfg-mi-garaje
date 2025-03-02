import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastHelper {
  static void show(BuildContext context, String response) {
    Fluttertoast.showToast(
      msg: response,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.SNACKBAR,
      backgroundColor: Theme.of(context).primaryColor,
    );
  }
}
