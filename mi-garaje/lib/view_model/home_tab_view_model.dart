import 'package:flutter/material.dart';

class HomeTabViewModel extends ChangeNotifier {
  late int _selectedIndex;
  int get selectedIndex => _selectedIndex;

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void resetIndex() {
    _selectedIndex = 1;
    notifyListeners();
  }
}
