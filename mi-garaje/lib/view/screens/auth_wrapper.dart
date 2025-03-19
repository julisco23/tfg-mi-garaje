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
    final authViewModel = Provider.of<AuthProvider>(context, listen: false);
    final globalTypesViewModel = Provider.of<GlobalTypesViewModel>(context, listen: false);

    bool isAuthenticated = await authViewModel.checkUser();
    await globalTypesViewModel.loadGlobalTypes();
    
    if (isAuthenticated) {
      await globalTypesViewModel.initializeUser(authViewModel.id);
    }

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
