import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_garaje/data/models/family.dart' as my;
import 'package:mi_garaje/data/models/user.dart';
import 'package:mi_garaje/data/services/auth_service.dart';

class AuthState {
  final User? user;
  final my.Family? family;

  AuthState({this.user, this.family});

  bool get isUser => user != null;
  bool get isFamily => family != null;

  String get id => family?.id ?? user?.id ?? '';

  String get type => family != null ? "families" : "users";

  bool get isGoogle => user?.isGoogle ?? false;
  bool get isPhotoURL => user!.photoURL != null;

  bool get isLastMember => family!.members!.length == 1;

  AuthState copyWith({User? user, my.Family? family}) {
    return AuthState(
      user: user ?? this.user,
      family: family ?? this.family,
    );
  }
}

class AuthNotifier extends AsyncNotifier<AuthState> {
  final AuthService _authService = AuthService();

  @override
  FutureOr<AuthState> build() async {
    final user = await _authService.currentUser;
    my.Family? family;
    if (user != null && user.hasFamily) {
      family = await _authService.getFamily(user.idFamily!);
    }
    return AuthState(user: user, family: family);
  }

  Future<void> updateUser() async {
    User? user = await _authService.currentUser;
    my.Family? family;
    if (user != null && user.hasFamily) {
      family = await _authService.getFamily(user.idFamily!);
    }
    state = AsyncData(AuthState(user: user, family: family));
  }

  Future<bool> checkUser() async {
    await updateUser();
    return state.value?.isUser ?? false;
  }

  Future<String?> signin(String email, String password) async {
    final response =
        await _authService.signin(email: email, password: password);
    await updateUser();
    return response;
  }

  Future<String?> signInWithGoogle() async {
    final response = await _authService.signInWithGoogle();
    await updateUser();
    return response;
  }

  Future<String?> signupWithGoogle() async {
    final response = await _authService.signupWithGoogle();
    await updateUser();
    return response;
  }

  Future<String?> linkWithGoogle() async {
    final response = await _authService.linkWithGoogle();
    await updateUser();
    return response;
  }

  Future<String?> signup(String email, String password, String name) async {
    final response = await _authService.signup(
        email: email, password: password, displayName: name);
    await updateUser();
    return response;
  }

  Future<String?> signInAnonymously() async {
    final response = await _authService.signInAnonymously();
    await updateUser();
    return response;
  }

  Future<String?> signout() async {
    String? response;
    if (state.value?.isGoogle ?? false) {
      response = await _authService.signOutGoogle();
    } else {
      response = await _authService.signout();
    }
    await updateUser();
    return response;
  }

  Future<String?> eliminarCuenta() async {
    await salirDeFamilia();
    final response = await _authService.deleteUserAccount();
    state = AsyncData(AuthState(user: null, family: null));
    return response;
  }

  Future<String?> crearCuenta(
      String email, String password, String name) async {
    final response =
        await _authService.linkAnonymousAccount(email, password, name);
    await updateUser();
    return response;
  }

  Future<String?> actualizarProfile(
      String name, String? photo, bool isPhotoChanged) async {
    final userId = state.value?.user?.id;
    if (userId == null) return "No user logged in";
    final response =
        await _authService.updateProfile(name, photo, isPhotoChanged, userId);
    await updateUser();
    return response;
  }

  Future<String?> actualizarFamilia(String name) async {
    if (state.value?.family?.id == null) return "No family found";
    final response =
        await _authService.updateFamilyProfile(name, state.value!.family!.id!);
    await updateUser();
    return response;
  }

  String generateFamilyCode() {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return String.fromCharCodes(
      Iterable.generate(
          6, (_) => chars.codeUnitAt(Random().nextInt(chars.length))),
    );
  }

  Future<void> convertirEnFamilia() async {
    final user = state.value?.user;
    if (user == null) return;
    final family = my.Family(
      name: "Familia de ${user.displayName}",
      code: generateFamilyCode(),
      members: [user],
    );
    await _authService.convertToFamily(family, user.id!);
    await updateUser();
  }

  Future<void> unirseAFamilia(String familyCode) async {
    if (state.value?.user?.id == null) return;
    await _authService.joinFamily(familyCode, state.value!.user!.id!);
    await updateUser();
  }

  Future<void> salirDeFamilia() async {
    if (state.value?.family == null || state.value?.user == null) return;
    await _authService.leaveFamily(state.value!.isLastMember,
        state.value!.user!.id!, state.value!.family!.id!);
    await updateUser();
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
