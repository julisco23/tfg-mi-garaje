import 'package:flutter/material.dart';
import 'package:mi_garaje/data/models/user.dart';
import 'package:mi_garaje/data/services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;

  User? get user => _user;

  String get id => user!.id!;
  
  bool get isGoogle => user == null ? false : user!.isGoogle;
  bool get isPhotoURL => user == null ? false : user!.photoURL != null;

  void setUser(User? user) {
    _user = user;
    notifyListeners();
  }

  // Método de verificación de usuario
  Future<bool> checkUser() async{
    _user = await _authService.currentUser;

    print('CheckUser: ${_user != null}');

    return _user != null;
  }
  
  // Método de inicio de sesión
  Future<String?> signin(String email, String password) async {
    String? response = await _authService.signin(email: email, password: password);
    setUser(await _authService.currentUser);
    return response;
  }

  // Método de inicio de sesión con Google
  Future<String?> signInWithGoogle() async {
    String? response =  await _authService.signInWithGoogle();
    setUser(await _authService.currentUser);
    return response;
  }

  // Metodo de registro con Google
  Future<String?> signupWithGoogle() async {
    String? response =  await _authService.signupWithGoogle();
    setUser(await _authService.currentUser);
    return response;
  }

  // Método de vinculación de cuenta con Google
  Future<String?> linkWithGoogle() async {
    String? response = await _authService.linkWithGoogle();
    setUser(await _authService.currentUser);
    return response;
  }

  // Método de registro
  Future<String?> signup(String email, String password, String name) async {
    String? response = await _authService.signup(email: email, password: password, displayName: name);
    setUser(await _authService.currentUser);
    return response;
  }

  // Método de inicio de sesión anónimo
  Future<String?> signInAnonymously() async {
    String? response = await _authService.signInAnonymously();
    setUser(await _authService.currentUser);
    return response;
  }

  // Método de cierre de sesión
  Future<String?> signout() async {
    String? response;
    if (isGoogle) {
      response = await _authService.signOutGoogle();
    } else {
      response = await _authService.signout();
    }
    _user = user;
    print('User: $user');
    return response;
  }

  // Método de eliminación de cuenta
  Future<String?> eliminarCuenta() async {
    String? response = await _authService.deleteUserAccount();
    _user = user;
    return response;
  }

  // Método de vinculación de cuenta
  Future<String?> crearCuenta(String email, String password, String name) async {
    String? response = await _authService.linkAnonymousAccount(email, password, name);
    setUser(await _authService.currentUser);
    return response;
  }

  // Método de actualización de perfil
  Future<String?> actualizarProfile(String name, String? photo, bool isPhotoChanged) async {
    String? response = await _authService.updateProfile(name, photo, isPhotoChanged);
    setUser(await _authService.currentUser);
    return response;
  }
}

