// Provider des gains — gestion d'état Riverpod
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/gain.dart';
import '../data/gains_repository.dart';

/// Provider du repository des gains
/// Mock pour le MVP — remplacer par FirestoreGainsRepository() en prod.
final gainsRepositoryProvider = Provider<IGainsRepository>((ref) {
  return MockGainsRepository();
});

/// Provider principal des gains
final gainsProvider =
    AsyncNotifierProvider<GainsNotifier, GainsData>(GainsNotifier.new);

/// Notifier gérant les données financières du livreur
class GainsNotifier extends AsyncNotifier<GainsData> {
  @override
  Future<GainsData> build() async {
    final repo = ref.watch(gainsRepositoryProvider);
    return repo.getGains();
  }

  /// Soumet une demande de retrait vers MoMo
  Future<void> demanderRetrait(String numeroMomo, double montant) async {
    final repo = ref.read(gainsRepositoryProvider);
    await repo.demanderRetrait(numeroMomo, montant);
    // Rafraîchir les données après retrait
    ref.invalidateSelf();
  }

  /// Rafraîchit les données de gains
  Future<void> rafraichir() async {
    ref.invalidateSelf();
  }
}
