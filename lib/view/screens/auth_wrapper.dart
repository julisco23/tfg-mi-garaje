import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_garaje/data/provider/auth_notifier.dart';
import 'package:mi_garaje/view/screens/auth/login/login_view.dart';
import 'package:mi_garaje/view/screens/home/home_view.dart';
import 'package:mi_garaje/view/screens/splash_screen.dart';

class AuthWrapper extends ConsumerStatefulWidget {
  const AuthWrapper({super.key});

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper> {
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    bool isAuthenticated = await ref.read(authProvider.notifier).checkUser();

    setState(() {
      _isAuthenticated = isAuthenticated;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SplashScreen();
    }
    return _isAuthenticated ? const HomeView() : const LoginView();
  }
}
