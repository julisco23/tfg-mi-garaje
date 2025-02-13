import 'package:flutter/material.dart';
import 'package:mi_garaje/view/auth/login/login_view.dart';
import 'package:mi_garaje/view/auth/signup/signup_view.dart';
import 'package:mi_garaje/view/garage/garage_view.dart';
import 'package:mi_garaje/view/home/home_view.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/login': (context) => LoginView(),
    '/signup': (context) => SignupView(),
    '/home': (context) => HomeView(),
  };

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case "/garage":
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            return const GarageView();
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(position: offsetAnimation, child: child);
          },
        );
      default:
        return MaterialPageRoute(builder: (context) => HomeView());
    }
  }
}


