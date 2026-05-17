// Repository des gains — implémentation mock pour MVP
import 'dart:math';
import '../../../core/constants/app_constants.dart';
import '../../../shared/models/gain.dart';
import 'mock_gains_data.dart';

/// Interface du repository des gains
abstract class IGainsRepository {
  Future<GainsData> getGains();
  Future<void> demanderRetrait(String numeroMomo, double montant);
}

/// Implémentation mock du repository des gains
class MockGainsRepository implements IGainsRepository {
  final Random _random = Random();

  Future<void> _simulerDelai() async {
    final delai = AppConstants.kDelaiMockReseau +
        _random.nextInt(
            AppConstants.kDelaiMockReseauMax - AppConstants.kDelaiMockReseau);
    await Future.delayed(Duration(milliseconds: delai));
  }

  @override
  Future<GainsData> getGains() async {
    await _simulerDelai();
    return mockGainsData;
  }

  @override
  Future<void> demanderRetrait(String numeroMomo, double montant) async {
    await _simulerDelai();
    // En production : appel API POST /gains/retrait
    // Pour le mock, on simule un succès
  }
}
