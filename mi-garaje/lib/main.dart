import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mi_garaje/data/provider/global_types_view_model.dart';
import 'package:provider/provider.dart';
import 'package:mi_garaje/view/screens/auth/login/login_view.dart';
import 'package:mi_garaje/data/provider/auth_provider.dart';
import 'package:mi_garaje/firebase_options.dart';
import 'package:mi_garaje/shared/routes/app_routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mi_garaje/view/screens/home/home_view.dart';
import 'package:mi_garaje/shared/themes/app_themes.dart';
import 'package:mi_garaje/shared/themes/theme_notifier.dart';
import 'package:mi_garaje/data/provider/garage_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Inicializar los Providers antes de runApp()
  final themeNotifier = ThemeNotifier(AppThemes.lightTheme);
  final authViewModel = AuthViewModel();
  final garageProvider = GarageProvider();
  final globalTypesViewModel = GlobalTypesViewModel();

  // Cargar tipos globales
  await globalTypesViewModel.loadGlobalTypes();

  // Cargar autenticación
  final bool isAuthenticated = await authViewModel.checkUser();

  // Si el usuario está autenticado, cargar sus datos antes de iniciar la app
  if (isAuthenticated) {
    garageProvider.initializeUser(authViewModel.user!.id!);
    globalTypesViewModel.initializeUser(authViewModel.user!.id!);
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => themeNotifier),
        ChangeNotifierProvider(create: (_) => authViewModel),
        ChangeNotifierProvider(create: (_) => garageProvider),
        ChangeNotifierProvider(create: (_) => globalTypesViewModel),
      ],
      child: MyApp(isAuthenticated: isAuthenticated),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isAuthenticated;

  const MyApp({super.key, required this.isAuthenticated});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      theme: themeNotifier.currentTheme,
      routes: AppRoutes.routes,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      debugShowCheckedModeBanner: false,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: PointerDeviceKind.values.toSet(),
      ),
      title: 'Mi Garage',
      home: isAuthenticated ? const HomeView() : const LoginView(),
    );
  }
}
