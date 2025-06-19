import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_garaje/data/models/family.dart' as my;
import 'package:mi_garaje/data/models/user.dart';
import 'package:mi_garaje/data/notifier/activity_notifier.dart';
import 'package:mi_garaje/data/notifier/garage_notifier.dart';
import 'package:mi_garaje/data/notifier/tab_update_notifier.dart';
import 'package:mi_garaje/data/services/auth_service.dart';
import 'package:mi_garaje/data/services/garage_service.dart';
import 'package:mi_garaje/data/services/user_types_service.dart';
import 'package:mi_garaje/shared/utils/family_code_generator.dart';

class AuthState {
  final User? user;

  AuthState({this.user});

  bool get isUser => user != null;
  bool get isFamily => user!.hasFamily;

  String get id => user?.family?.id ?? user!.id!;

  String get type => isFamily ? "families" : "users";

  bool get isGoogle => user?.isGoogle ?? false;
  bool get isPhotoURL => user!.photoURL != null;

  bool get isLastMember => user!.family!.members!.length == 1;

  AuthState copyWith({User? user}) {
    return AuthState(
      user: user ?? this.user,
    );
  }
}

class AuthNotifier extends AsyncNotifier<AuthState> {
  final AuthService _authService = AuthService();
  final GarageService _garageService = GarageService();
  final UserTypesService _userTypeService = UserTypesService();

  @override
  FutureOr<AuthState> build() async {
    try {
      return AuthState(user: await _authService.currentUser);
    } catch (e, stackTrace) {
      throw AsyncError(e, stackTrace);
    }
  }

  Future<void> updateUser() async {
    try {
      state = AsyncData(AuthState(user: await _authService.currentUser));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<bool> checkUser() async {
    try {
      await updateUser();
      return state.value?.isUser ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> signin(String email, String password) async {
    await _authService.signin(email, password);
    await updateUser();
  }

  Future<void> signInWithGoogle() async {
    await _authService.signInWithGoogle();
    await updateUser();
  }

  Future<void> signup(String email, String password, String name) async {
    await _authService.signup(email, password, name);
    await updateUser();
  }

  Future<void> signupAnonymously() async {
    await _authService.signUpAnonymously();
    await updateUser();
  }

  Future<void> linkWithGoogle() async {
    await _authService.linkWithGoogle();
    await updateUser();
  }

  Future<void> signout() async {
    if (state.value!.isGoogle) {
      await _authService.signOutGoogle();
    }

    await _authService.signout();
    ref.read(tabStateProvider.notifier).limpiar();
    await updateUser();
  }

  Future<void> deleteAccount() async {
    if (state.value!.isFamily) {
      await leaveFamily();
    } else {
      await _garageService.deleteVehicles(state.value!.id, state.value!.type);
    }

    if (state.value!.isGoogle) {
      await _authService.signOutGoogle();
    }

    await _authService.deleteUserAccount();
    ref.read(tabStateProvider.notifier).limpiar();
    await updateUser();
  }

  Future<void> linkAnonymousAccount(
      String email, String password, String name) async {
    await _authService.linkAnonymousAccount(email, password, name);
    await updateUser();
  }

  Future<void> updateProfile(
      String name, String? photo, bool isPhotoChanged) async {
    await _authService.updateProfile(
        name, photo, isPhotoChanged, state.value!.user!.id!);
    await updateUser();
  }

  Future<void> convertToFamily() async {
    final user = state.value!.user!;

    final family = my.Family(
      code: FamilyCodeGenerator.generate(),
      members: [user],
    );

    String idFamily = await _authService.convertToFamily(family, user.id!);
    await _garageService.convertToFamily(user.id!, idFamily);
    await _userTypeService.transformTypesToFamily(user.id!, idFamily);
    await updateUser();
  }

  Future<void> joinFamily(String familyCode) async {
    await _garageService.deleteVehicles(state.value!.user!.id!, "users");
    await _userTypeService.deleteTypeFromUser(state.value!.user!.id!);
    await _authService.joinFamily(familyCode, state.value!.user!.id!);
    await updateUser();

    // ignore: unused_result
    ref.refresh(garageProvider.notifier);
    // ignore: unused_result
    ref.refresh(activityProvider.notifier);
    ref.invalidate(tabStateProvider);
  }

  Future<void> leaveFamily() async {
    await _authService.leaveFamily(state.value!.isLastMember,
        state.value!.user!.id!, state.value!.user!.family!.id!);
    if (state.value!.isLastMember) {
      await _garageService.deleteVehicles(state.value!.id, state.value!.type);
    }
    await updateUser();

    // ignore: unused_result
    ref.refresh(garageProvider.notifier);
    // ignore: unused_result
    ref.refresh(activityProvider.notifier);
    ref.invalidate(tabStateProvider);
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
