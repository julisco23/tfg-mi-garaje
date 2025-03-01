import 'package:flutter/widgets.dart';

class AppDimensions {
  static double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;
  static double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
}

class AppConstants {
  static const int tabHistory = 0;
  static const int tabHome = 1;
  static const int tabProfile = 2;
}
