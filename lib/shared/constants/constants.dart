import 'package:flutter/widgets.dart';
import 'package:mi_garaje/view/screens/home/history_tab/history_view.dart';
import 'package:mi_garaje/view/screens/home/car_tab/car_view.dart';
import 'package:mi_garaje/view/screens/home/profile_tab/profile_view.dart';

class AppDimensions {
  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;
  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;
}

class AppConstants {
  static const int tabHistory = 0;
  static const int tabHome = 1;
  static const int tabProfile = 2;

  static const int fuel = 0;
  static const int repair = 1;
  static const int record = 2;

  static final widgetTabs = [
    HistoryView(),
    CarTabView(),
    Perfil(),
  ];
}
