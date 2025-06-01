import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_garaje/data/provider/activity_provider.dart';
import 'package:mi_garaje/data/provider/locale_notifier.dart';
import 'package:mi_garaje/view/screens/auth_wrapper.dart';
import 'package:mi_garaje/view/screens/error_screen.dart';
import 'package:provider/provider.dart' as provider;
import 'package:firebase_core/firebase_core.dart';
import 'package:mi_garaje/firebase_options.dart';
import 'package:mi_garaje/data/provider/auth_provider.dart';
import 'package:mi_garaje/data/provider/garage_provider.dart';
import 'package:mi_garaje/data/provider/global_types_view_model.dart';
import 'package:mi_garaje/data/provider/tab_update_notifier.dart';
import 'package:mi_garaje/shared/routes/app_routes.dart';
import 'package:mi_garaje/shared/themes/app_themes.dart';
import 'package:mi_garaje/data/provider/theme_notifier.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    ProviderScope(
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeAsync = ref.watch(themeProvider);
    final localeAsync = ref.watch(localeProvider);

    return provider.MultiProvider(
      providers: [
        provider.ChangeNotifierProvider(create: (_) => AuthProvider()),
        provider.ChangeNotifierProvider(create: (_) => GarageProvider()),
        provider.ChangeNotifierProvider(create: (_) => ActivityProvider()),
        provider.ChangeNotifierProvider(create: (_) => GlobalTypesViewModel()),
        provider.ChangeNotifierProvider(create: (_) => TabState()),
      ],
      child: localeAsync.when(
        data: (locale) => themeAsync.when(
          data: (themeMode) => MaterialApp(
            theme: AppThemes.lightTheme,
            darkTheme: AppThemes.darkTheme,
            themeMode: themeMode,
            locale: locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            routes: AppRoutes.routes,
            onGenerateRoute: AppRoutes.onGenerateRoute,
            debugShowCheckedModeBanner: false,
            title: 'Mi Garaje',
            home: const AuthWrapper(),
          ),
          loading: () => const CircularProgressIndicator(),
          error: (e, st) =>
              ErrorScreen(errorMessage: "Error al cargar el tema"),
        ),
        loading: () => const CircularProgressIndicator(),
        error: (e, st) => ErrorScreen(errorMessage: 'Error cargando locale'),
      ),
    );
  }
}
