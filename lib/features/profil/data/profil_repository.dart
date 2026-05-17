// Repository du profil livreur — implémentation mock pour MVP
import 'dart:math';
import '../../../core/constants/app_constants.dart';
import '../../../shared/models/livreur.dart';
import '../../auth/data/mock_auth_data.dart';

/// Interface du repository du profil
abstract class IProfilRepository {
  Future<Livreur> getProfil();
  Future<void> updateProfil(Livreur livreur);
}

/// Implémentation mock du repository du profil
class MockProfilRepository implements IProfilRepository {
  final Random _random = Random();

  Future<void> _simulerDelai() async {
    final delai = AppConstants.kDelaiMockReseau +
        _random.nextInt(
            AppConstants.kDelaiMockReseauMax - AppConstants.kDelaiMockReseau);
    await Future.delayed(Duration(milliseconds: delai));
  }

  @override
  Future<Livreur> getProfil() async {
    await _simulerDelai();
    return mockLivreur;
  }

  @override
  Future<void> updateProfil(Livreur livreur) async {
    await _simulerDelai();
    // En production : appel API PUT /profil
  }
}
