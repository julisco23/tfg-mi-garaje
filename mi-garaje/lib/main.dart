import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mi_garaje/view/auth/login/login_view.dart';
import 'package:mi_garaje/view_model/auth_view_model.dart';
import 'package:mi_garaje/data/services/auth_service.dart';
import 'package:mi_garaje/firebase_options.dart';
import 'package:mi_garaje/shared/routes/app_routes.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:mi_garaje/view/home/home_view.dart';
import 'package:mi_garaje/shared/themes/app_themes.dart';
import 'package:mi_garaje/shared/themes/theme_notifier.dart';
import 'package:mi_garaje/view_model/garage_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeNotifier(AppThemes.lightTheme)),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => GarageViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return AnimatedTheme(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      data: themeNotifier.currentTheme,
      child: MaterialApp(
        theme: themeNotifier.currentTheme,
        routes: AppRoutes.routes,
        onGenerateRoute: AppRoutes.onGenerateRoute,
        debugShowCheckedModeBanner: false,
        title: 'Mi Garage',
        home: FutureBuilder<bool>(
          future: AuthService().comprobarUsuarioAutenticado(),
          builder: (context, snapshot) {
            if (snapshot.data == true) {
              return HomeView();
            } else {
              return LoginView();
            }
          },
        ),
      ),
    );
  }
}
