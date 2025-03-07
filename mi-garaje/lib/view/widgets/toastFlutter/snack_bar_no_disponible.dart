import 'package:flutter/material.dart';

class NoDisponibleSnackBar {
  static void show(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Funcionalidad no disponible."),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
