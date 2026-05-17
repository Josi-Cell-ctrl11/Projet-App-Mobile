// Provider du profil livreur — gestion d'état Riverpod
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/livreur.dart';
import '../data/profil_repository.dart';

/// Provider du repository du profil
final profilRepositoryProvider = Provider<IProfilRepository>((ref) {
  return MockProfilRepository();
});

/// Provider principal du profil livreur
final profilProvider =
    AsyncNotifierProvider<ProfilNotifier, Livreur>(ProfilNotifier.new);

/// Notifier gérant les données du profil livreur
class ProfilNotifier extends AsyncNotifier<Livreur> {
  @override
  Future<Livreur> build() async {
    final repo = ref.watch(profilRepositoryProvider);
    return repo.getProfil();
  }

  /// Met à jour le profil du livreur
  Future<void> updateProfil(Livreur livreur) async {
    final repo = ref.read(profilRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.updateProfil(livreur);
      return livreur;
    });
  }

  /// Met à jour le type de véhicule
  Future<void> updateVehicule(TypeVehicule vehicule) async {
    final current = state.value;
    if (current == null) return;
    await updateProfil(current.copyWith(typeVehicule: vehicule));
  }
}
