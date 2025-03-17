import 'package:flutter/material.dart';

class TabState with ChangeNotifier {
  List<String> _activityTypes = [];

  int tabIndex = 0;

  List<String> get activityTypes => _activityTypes;
  bool get isScrollable => _activityTypes.length > 4;

  void inicializar(List<String> types) {
    _activityTypes = types;
  }

  void newTab(String text) {
    _activityTypes.add(text);
    notifyListeners();
  }

  void removeTab(String text) {
    _activityTypes.remove(text);
    notifyListeners();
  }

  void editTab(String oldText, String newText) {
    final index = _activityTypes.indexOf(oldText);
    _activityTypes[index] = newText;
    notifyListeners();
  }
}

