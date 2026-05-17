// Provider d'authentification — gestion d'état Riverpod
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/livreur.dart';
import '../data/auth_repository.dart';

/// États possibles de l'authentification
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

/// État complet de l'authentification
class AuthState {
  final AuthStatus status;
  final Livreur? livreur;
  final String? errorMessage;

  const AuthState({
    required this.status,
    this.livreur,
    this.errorMessage,
  });

  const AuthState.initial()
      : status = AuthStatus.initial,
        livreur = null,
        errorMessage = null;

  AuthState copyWith({
    AuthStatus? status,
    Livreur? livreur,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      livreur: livreur ?? this.livreur,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
}

/// Provider du repository d'authentification
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return MockAuthRepository();
});

/// Provider principal de l'authentification
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

/// Notifier gérant la logique d'authentification
class AuthNotifier extends StateNotifier<AuthState> {
  final IAuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState.initial()) {
    // Vérifier la session au démarrage
    _checkSession();
  }

  /// Vérifie si une session active existe en stockage local
  Future<void> _checkSession() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final livreur = await _repository.getStoredSession();
      if (livreur != null) {
        state = AuthState(
          status: AuthStatus.authenticated,
          livreur: livreur,
        );
      } else {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    } catch (_) {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  /// Envoie un OTP au numéro de téléphone fourni
  Future<void> sendOtp(String phoneNumber) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      await _repository.sendOtp(phoneNumber);
      // Retour à unauthenticated pour afficher l'écran OTP
      state = const AuthState(status: AuthStatus.unauthenticated);
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Vérifie le code OTP et crée la session
  Future<void> verifyOtp(String phone, String otp) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final livreur = await _repository.verifyOtp(phone, otp);
      state = AuthState(
        status: AuthStatus.authenticated,
        livreur: livreur,
      );
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: 'Code incorrect, veuillez réessayer',
      );
    }
  }

  /// Déconnecte le livreur et supprime la session locale
  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Réinitialise l'état d'erreur
  void clearError() {
    if (state.status == AuthStatus.error) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }
}
