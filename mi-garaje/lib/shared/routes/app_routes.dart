import 'package:flutter/material.dart';
import 'package:mi_garaje/view/screens/auth/login/login_view.dart';
import 'package:mi_garaje/view/screens/auth/signup/signup_view.dart';
import 'package:mi_garaje/view/screens/home/car_tab/garage/garage_view.dart';
import 'package:mi_garaje/view/screens/home/car_tab/record_view/record_view.dart';
import 'package:mi_garaje/view/screens/home/car_tab/refuel_view/refuel_view.dart';
import 'package:mi_garaje/view/screens/home/car_tab/repair_view/repair_view.dart';
import 'package:mi_garaje/view/screens/home/home_view.dart';
import 'package:mi_garaje/view/screens/home/profile_tab/settings_views/types_view.dart';
import 'package:mi_garaje/view/screens/home/profile_tab/settings_view.dart';

import 'route_names.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    RouteNames.login: (context) => LoginView(),
    RouteNames.signup: (context) => SignupView(),
    RouteNames.home: (context) => HomeView(),
  };

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments != null ? settings.arguments as Map<String, dynamic> : {};
    switch (settings.name) {
      case RouteNames.garage:
        return _slideTransition(const GarageView());

      case RouteNames.refuel:
        return _slideTransition(RefuelView(
          refuel: args['refuel'],
          carName: args['carName'],
        ));

      case RouteNames.repair:
        return _slideTransition(RepairView(
          repair: args['repair'],
          carName: args['carName'],
        ));

      case RouteNames.record:
        return _slideTransition(RecordView(
          record: args['record'],
          carName: args['carName'],
        ));

      case RouteNames.settings:
        return _slideTransition(SettingsView(garageViewModel: args['garageViewModel']));

      case RouteNames.types:
        return _slideTransition(TypesView(type: args['type']));


      default:
        return MaterialPageRoute(builder: (context) => HomeView());
    }
  }

  static PageRouteBuilder _slideTransition(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);
        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }
}
