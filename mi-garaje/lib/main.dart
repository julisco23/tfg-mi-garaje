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

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeNotifier(AppThemes.lightTheme)),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => GarageProvider()),
        ChangeNotifierProvider(create: (_) => GlobalTypesViewModel()),
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
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final garageProvider = Provider.of<GarageProvider>(context, listen: false);

    final isAuthenticated = authViewModel.checkUser();

    if (isAuthenticated) {
      garageProvider.initializeUser(authViewModel.user!.id!);
      Provider.of<GlobalTypesViewModel>(context, listen: false).initialize(authViewModel.user!.id!);
    }

    return MaterialApp(
      theme: themeNotifier.currentTheme,
      routes: AppRoutes.routes,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      debugShowCheckedModeBanner: false,
      title: 'Mi Garage',
      home: isAuthenticated
        ? const HomeView() 
        : const LoginView(),
    );
  }
}