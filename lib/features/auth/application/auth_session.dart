import "dart:convert";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:shared_preferences/shared_preferences.dart";

import "../../../shared/models/app_user.dart";

/// Clés de persistance locale (MVP).
abstract final class PrefsKeys {
  static const onboardingDone = "ozel_onboarding_done";
  static const userJson = "ozel_user_json";
}

/// État d’authentification / onboarding hydraté depuis [SharedPreferences].
class AuthSnapshot {
  const AuthSnapshot({
    required this.hydrated,
    required this.onboardingDone,
    this.user,
  });

  final bool hydrated;
  final bool onboardingDone;
  final AppUser? user;

  bool get isLoggedIn => user != null;

  static const initial = AuthSnapshot(hydrated: false, onboardingDone: false);

  static const Object _unsetUser = Object();

  AuthSnapshot copyWith({
    bool? hydrated,
    bool? onboardingDone,
    Object? user = _unsetUser,
  }) {
    return AuthSnapshot(
      hydrated: hydrated ?? this.hydrated,
      onboardingDone: onboardingDone ?? this.onboardingDone,
      user: identical(user, _unsetUser)
          ? this.user
          : user as AppUser?,
    );
  }
}

/// Gère onboarding + session utilisateur (mock).
class AuthSession extends Notifier<AuthSnapshot> {
  @override
  AuthSnapshot build() => AuthSnapshot.initial;

  Future<void> hydrate() async {
    final prefs = await SharedPreferences.getInstance();
    final done = prefs.getBool(PrefsKeys.onboardingDone) ?? false;
    final raw = prefs.getString(PrefsKeys.userJson);
    AppUser? user;
    if (raw != null && raw.isNotEmpty) {
      user = AppUser.fromJson(json.decode(raw) as Map<String, dynamic>);
    }
    state = AuthSnapshot(hydrated: true, onboardingDone: done, user: user);
  }

  Future<void> setOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefsKeys.onboardingDone, true);
    state = state.copyWith(onboardingDone: true);
  }

  Future<void> saveUser(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PrefsKeys.userJson, json.encode(user.toJson()));
    state = state.copyWith(user: user);
  }

  Future<void> updateUser(AppUser user) => saveUser(user);

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(PrefsKeys.userJson);
    state = state.copyWith(user: null);
  }
}

final authSessionProvider = NotifierProvider<AuthSession, AuthSnapshot>(
  AuthSession.new,
);
