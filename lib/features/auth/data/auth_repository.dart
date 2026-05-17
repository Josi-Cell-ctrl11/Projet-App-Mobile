// Repository d'authentification — implémentation mock pour MVP
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/models/livreur.dart';
import 'mock_auth_data.dart';

/// Clé de stockage sécurisé pour le token de session
const String _kTokenKey = 'ozel_livreur_token';
const String _kLivreurIdKey = 'ozel_livreur_id';

/// Interface du repository d'authentification
abstract class IAuthRepository {
  Future<void> sendOtp(String phoneNumber);
  Future<Livreur> verifyOtp(String phone, String otp);
  Future<void> logout();
  Future<Livreur?> getStoredSession();
}

/// Implémentation mock du repository d'authentification
/// Simule les appels réseau avec un délai aléatoire
class MockAuthRepository implements IAuthRepository {
  final FlutterSecureStorage _storage;
  final Random _random = Random();

  MockAuthRepository({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  /// Simule un délai réseau réaliste entre 500ms et 1500ms
  Future<void> _simulerDelaiReseau() async {
    final delai = AppConstants.kDelaiMockReseau +
        _random.nextInt(
            AppConstants.kDelaiMockReseauMax - AppConstants.kDelaiMockReseau);
    await Future.delayed(Duration(milliseconds: delai));
  }

  @override
  Future<void> sendOtp(String phoneNumber) async {
    await _simulerDelaiReseau();
    // En production : appel API POST /auth/send-otp
    // Pour le mock, on accepte tout numéro valide
  }

  @override
  Future<Livreur> verifyOtp(String phone, String otp) async {
    await _simulerDelaiReseau();

    // Vérification mock : OTP fixe 123456
    if (otp != mockOtpCode) {
      throw Exception('Code OTP incorrect');
    }

    // Persister le token en stockage sécurisé
    await _storage.write(key: _kTokenKey, value: mockToken);
    await _storage.write(key: _kLivreurIdKey, value: mockLivreur.id);

    return mockLivreur;
  }

  @override
  Future<void> logout() async {
    // Supprimer le token du stockage sécurisé
    await _storage.delete(key: _kTokenKey);
    await _storage.delete(key: _kLivreurIdKey);
  }

  @override
  Future<Livreur?> getStoredSession() async {
    final token = await _storage.read(key: _kTokenKey);
    if (token == null || token.isEmpty) return null;

    // En production : valider le token avec l'API
    // Pour le mock, on retourne le livreur mocké si un token existe
    return mockLivreur.copyWith(token: token);
  }
}
