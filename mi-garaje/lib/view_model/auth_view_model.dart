import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mi_garaje/data/services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User get usuario => _authService.usuarioActual!;
  bool get esAnonimo => _authService.usuarioActual == null ? false : usuario.isAnonymous;
  bool get esGoogle => _authService.usuarioActual == null ? false : usuario.providerData.isEmpty ? false : usuario.providerData[0].providerId == 'google.com';

  // Método para obtener el nombre del usuario
  String get nombreUsuario {
    return esAnonimo ? "Cuenta Anónima" : (usuario.displayName ?? usuario.email!);
  }

  // Validación de correo electrónico
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return '* Correo electrónico es obligatorio.';
    }
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!regex.hasMatch(value)) {
      return '* Correo electrónico inválido (@).';
    }
    return null;
  }

  // Validación de la contraseña
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '* Contraseña es obligatoria.';
    }
    if (value.length < 6) {
      return '* La contraseña debe tener al menos 6 caracteres.';
    }
    return null;
  }

  // Validación del nombre (solo para signup)
  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return '* Nombre es obligatorio.';
    }
    return null;
  }

  // Método de inicio de sesión
  Future<String?> signin(String email, String password) async {
    return await _authService.signin(email: email, password: password);
  }

  // Método de inicio de sesión con Google
  Future<String?> signInWithGoogle() async {
    return await _authService.signInWithGoogle();
  }

  // Método de registro
  Future<String?> signup(String email, String password, String name) async {
    return await _authService.signup(email: email, password: password, displayName: name);
  }

  // Método de inicio de sesión anónimo
  Future<String?> signInAnonymously() async {
    return await _authService.signInAnonymously();
  }

  // Método de cierre de sesión
  Future<String?> signout() async {
    if (esGoogle) {
      return await _authService.signOutGoogle();
    }
    return await _authService.signout();
  }

  // Método de eliminación de cuenta
  Future<String?> eliminarCuenta() async {
    String? response = await _authService.deleteAccount();
    return response;
  }

  // Método de vinculación de cuenta
  Future<String?> crearCuenta(String email, String password, String name) async {
    return await _authService.linkAnonymousAccount(email, password, name);
  }

  // Método de actualización de perfil
  Future<String?> actualizarProfile(String name) async {
    String? response = await _authService.updateProfile(name);
    notifyListeners();
    return response;
  }
}

