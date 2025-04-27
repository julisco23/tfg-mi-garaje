import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mi_garaje/data/provider/auth_provider.dart';
import 'package:mi_garaje/data/provider/global_types_view_model.dart';
import 'package:mi_garaje/view/screens/auth/login/login_view.dart';
import 'package:mi_garaje/view/screens/home/home_view.dart';
import 'package:mi_garaje/view/screens/splash_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    final AuthProvider authViewModel = context.read<AuthProvider>();
    final GlobalTypesViewModel globalTypesViewModel =
        context.read<GlobalTypesViewModel>();

    bool isAuthenticated = await authViewModel.checkUser();
    await globalTypesViewModel.loadGlobalTypes();

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
