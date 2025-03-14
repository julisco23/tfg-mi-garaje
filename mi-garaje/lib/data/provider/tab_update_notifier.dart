import 'package:flutter/material.dart';

class TabState with ChangeNotifier {
  List<String> _activityTypes = [];
  bool _isScrollable = false;

  List<String> get activityTypes => _activityTypes;
  bool get isScrollable => _isScrollable;

  void upadteScrpollable() {
    _isScrollable = _activityTypes.length > 5;
  }

  void inicializar(List<String> types) {
    _activityTypes = types;
    upadteScrpollable();
  }

  void newTab(String text) {
    _activityTypes.add(text);
    upadteScrpollable();
    notifyListeners();
  }

  void removeTab(String text) {
    _activityTypes.remove(text);
    upadteScrpollable();
    notifyListeners();
  }

  void editTab(String oldText, String newText) {
    final index = _activityTypes.indexOf(oldText);
    _activityTypes[index] = newText;
    notifyListeners();
  }
}

