import 'package:flutter/material.dart';

class TabState with ChangeNotifier {
  List<String> _activityTypes = [];
  bool _isScrollable = false;

  List<String> get activityTypes => _activityTypes;
  bool get isScrollable => _isScrollable;

  void inicializar(List<String> types) {
    _activityTypes = types;
    _isScrollable = types.length > 4; // Ajusta según la cantidad de tabs
  }

  void newTab(String text) {
    _activityTypes.add(text);
    _isScrollable = _activityTypes.length > 4; // Ajusta según la cantidad de tabs
    notifyListeners();
  }

  void removeTab(String text) {
    _activityTypes.remove(text);
    _isScrollable = _activityTypes.length > 4; // Ajusta según la cantidad de tabs
    notifyListeners();
  }

  void editTab(String oldText, String newText) {
    final index = _activityTypes.indexOf(oldText);
    _activityTypes[index] = newText;
    notifyListeners();
  }
}

