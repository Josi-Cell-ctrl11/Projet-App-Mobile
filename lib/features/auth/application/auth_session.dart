import "dart:convert";

import "package:firebase_auth/firebase_auth.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:shared_preferences/shared_preferences.dart";

import "../../../core/services/firestore_service.dart";
import "../../../shared/models/app_user.dart";

/// Clés de persistance locale.
abstract final class PrefsKeys {
  static const onboardingDone = "ozel_onboarding_done";
  static const userJson = "ozel_user_json";
}

/// État d'authentification / onboarding.
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
      user: identical(user, _unsetUser) ? this.user : user as AppUser?,
    );
  }
}

/// Gère onboarding + session utilisateur.
/// Persistance : SharedPreferences (local) + Firestore (cloud).
class AuthSession extends Notifier<AuthSnapshot> {
  @override
  AuthSnapshot build() => AuthSnapshot.initial;

  Future<void> hydrate() async {
    final prefs = await SharedPreferences.getInstance();
    final done = prefs.getBool(PrefsKeys.onboardingDone) ?? false;

    AppUser? user;

    // 1. Essayer de récupérer depuis Firestore si Firebase Auth connecté
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      try {
        final data = await FirestoreService.instance.getUser(firebaseUser.uid);
        if (data != null) {
          user = AppUser.fromJson(data);
        }
      } catch (_) {
        // Fallback vers SharedPreferences si Firestore indisponible
      }
    }

    // 2. Fallback SharedPreferences
    if (user == null) {
      final raw = prefs.getString(PrefsKeys.userJson);
      if (raw != null && raw.isNotEmpty) {
        user = AppUser.fromJson(json.decode(raw) as Map<String, dynamic>);
      }
    }

    state = AuthSnapshot(hydrated: true, onboardingDone: done, user: user);
  }

  Future<void> setOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefsKeys.onboardingDone, true);
    state = state.copyWith(onboardingDone: true);
  }

  /// Sauvegarde le profil localement ET dans Firestore.
  Future<void> saveUser(AppUser user) async {
    // Local
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PrefsKeys.userJson, json.encode(user.toJson()));

    // Firestore
    try {
      await FirestoreService.instance.saveUser(user.toJson(), user.id);
    } catch (e) {
      // L'app continue même si Firestore est temporairement indisponible
    }

    state = state.copyWith(user: user);
  }

  Future<void> updateUser(AppUser user) => saveUser(user);

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(PrefsKeys.userJson);

    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}

    state = state.copyWith(user: null);
  }
}

final authSessionProvider = NotifierProvider<AuthSession, AuthSnapshot>(
  AuthSession.new,
);
