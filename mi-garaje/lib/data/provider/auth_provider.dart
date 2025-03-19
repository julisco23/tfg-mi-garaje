import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mi_garaje/data/models/family.dart';
import 'package:mi_garaje/data/models/user.dart';
import 'package:mi_garaje/data/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  Family? _family;

  User? get user => _user;
  Family? get family => _family;

  bool get isFamily => _family != null;
  bool get isUser => _user != null;

  String get id => _family?.id ?? _user!.id!;
  String get type => _family != null ? "families" : "users";

  bool get isGoogle => _user?.isGoogle ?? false;
  bool get isPhotoURL => _user?.photoURL != null;

  bool get isLastMember => _family?.members?.length == 1;

  // ✅ Establece usuario y notifica cambios si es necesario
  void setUser(User? user, {bool notify = true}) {
    _user = user;
    if (_user != null && _user!.hasFamily) {
      getFamily();
    }
    if (notify) notifyListeners();
  }

  // ✅ Verifica si el usuario está autenticado
  Future<bool> checkUser() async {
    setUser(await _authService.currentUser);
    return isUser;
  }

  // ✅ Cargar la familia del usuario
  Future<void> getFamily() async {
    if (_user?.idFamily == null) return;
    _family = await _authService.getFamily(_user!.idFamily!);
    notifyListeners();
  }

  // ✅ Iniciar sesión con email y contraseña
  Future<String?> signin(String email, String password) async {
    String? response = await _authService.signin(email: email, password: password);
    setUser(await _authService.currentUser);
    return response;
  }

  // ✅ Iniciar sesión con Google
  Future<String?> signInWithGoogle() async {
    String? response = await _authService.signInWithGoogle();
    setUser(await _authService.currentUser);
    return response;
  }

  // ✅ Registrarse con Google
  Future<String?> signupWithGoogle() async {
    String? response = await _authService.signupWithGoogle();
    setUser(await _authService.currentUser);
    return response;
  }

  // ✅ Vincular cuenta con Google
  Future<String?> linkWithGoogle() async {
    String? response = await _authService.linkWithGoogle();
    setUser(await _authService.currentUser);
    return response;
  }

  // ✅ Registro con email y contraseña
  Future<String?> signup(String email, String password, String name) async {
    String? response = await _authService.signup(email: email, password: password, displayName: name);
    setUser(await _authService.currentUser);
    return response;
  }

  // ✅ Iniciar sesión anónimo
  Future<String?> signInAnonymously() async {
    String? response = await _authService.signInAnonymously();
    setUser(await _authService.currentUser);
    return response;
  }

  // ✅ Cerrar sesión correctamente
  Future<String?> signout() async {
    String? response;
    if (isGoogle) {
      response = await _authService.signOutGoogle();
    } else {
      response = await _authService.signout();
    }
    _user = null; // 💡 Limpiar usuario después de cerrar sesión
    _family = null; // 💡 Limpiar familia también
    notifyListeners();
    return response;
  }

  // ✅ Eliminar cuenta correctamente
  Future<String?> eliminarCuenta() async {
    String? response = await _authService.deleteUserAccount();
    _user = null;
    _family = null;
    notifyListeners();
    return response;
  }

  // ✅ Vincular cuenta anónima con email
  Future<String?> crearCuenta(String email, String password, String name) async {
    String? response = await _authService.linkAnonymousAccount(email, password, name);
    setUser(await _authService.currentUser);
    return response;
  }

  // ✅ Actualizar perfil de usuario
  Future<String?> actualizarProfile(String name, String? photo, bool isPhotoChanged) async {
    String? response = await _authService.updateProfile(name, photo, isPhotoChanged);
    setUser(await _authService.currentUser);
    return response;
  }

  // ✅ Generar código de familia
  String generateFamilyCode() {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(Random().nextInt(chars.length))),
    );
  }

  // ✅ Convertirse en familia
  Future<void> convertirEnFamilia() async {
    if (_user == null) return;
    Family family = Family(
      name: "Familia de ${_user!.displayName}",
      code: generateFamilyCode(),
      members: [_user!],
    );
    await _authService.convertToFamily(family);
    setUser(await _authService.currentUser);
    await getFamily();
  }

  // ✅ Unirse a una familia
  Future<void> unirseAFamilia(String familyCode) async {
    await _authService.joinFamily(familyCode);
    setUser(await _authService.currentUser);
    await getFamily();
  }

  // ✅ Salir de la familia correctamente
  Future<void> salirDeFamilia() async {
    if (_family == null) return;
    await _authService.leaveFamily(isLastMember);
    if (isLastMember) {
      _family = null;
    }
    setUser(await _authService.currentUser);
  }
}
