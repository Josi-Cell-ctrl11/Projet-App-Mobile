// Providers des commandes — gestion d'état Riverpod
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/models/commande.dart';
import '../data/commandes_repository.dart';
import '../data/firestore_commandes_repository.dart';

/// Provider du repository des commandes
/// Utilise Firestore en production.
final commandesRepositoryProvider = Provider<ICommandesRepository>((ref) {
  return FirestoreCommandesRepository();
});

/// Provider de la liste des commandes disponibles
final commandesProvider =
    AsyncNotifierProvider<CommandesNotifier, List<Commande>>(
  CommandesNotifier.new,
);

/// Notifier gérant la liste des commandes disponibles
class CommandesNotifier extends AsyncNotifier<List<Commande>> {
  @override
  Future<List<Commande>> build() async {
    final repo = ref.watch(commandesRepositoryProvider);
    return repo.getCommandesDisponibles();
  }

  /// Accepte une commande et la définit comme commande active
  Future<void> accepterCommande(String commandeId) async {
    final repo = ref.read(commandesRepositoryProvider);
    await repo.accepterCommande(commandeId);

    // Trouver la commande acceptée
    final commandes = state.value ?? [];
    final commande = commandes.firstWhere((c) => c.id == commandeId);
    final commandeAcceptee = commande.copyWith(statut: StatutCommande.acceptee);

    // Définir comme commande active
    ref.read(activeCommandeProvider.notifier).state = commandeAcceptee;

    // Retirer de la liste disponible
    state = AsyncData(commandes.where((c) => c.id != commandeId).toList());

    // Réinitialiser le compteur de refus
    ref.read(refusCountProvider.notifier).state = 0;
  }

  /// Refuse une commande et incrémente le compteur de refus
  Future<void> refuserCommande(String commandeId) async {
    final repo = ref.read(commandesRepositoryProvider);
    await repo.refuserCommande(commandeId);

    // Retirer de la liste
    final commandes = state.value ?? [];
    state = AsyncData(commandes.where((c) => c.id != commandeId).toList());

    // Incrémenter le compteur de refus consécutifs
    final refusCount = ref.read(refusCountProvider);
    final nouveauCount = refusCount + 1;
    ref.read(refusCountProvider.notifier).state = nouveauCount;

    // Vérifier si suspension nécessaire
    if (nouveauCount >= AppConstants.kMaxRefusConsecutifs) {
      ref.read(suspensionProvider.notifier).declencher();
      ref.read(refusCountProvider.notifier).state = 0;
    }
  }

  /// Met à jour le statut de la commande active
  Future<void> updateStatut(String commandeId, StatutCommande statut) async {
    final repo = ref.read(commandesRepositoryProvider);
    await repo.updateStatutCommande(commandeId, statut);

    // Mettre à jour la commande active
    final active = ref.read(activeCommandeProvider);
    if (active?.id == commandeId) {
      ref.read(activeCommandeProvider.notifier).state =
          active!.copyWith(statut: statut);
    }
  }

  /// Confirme la livraison avec le code OTP
  Future<bool> confirmerLivraison(String commandeId, String otp) async {
    final repo = ref.read(commandesRepositoryProvider);
    final succes = await repo.confirmerLivraisonOtp(commandeId, otp);
    if (succes) {
      ref.read(activeCommandeProvider.notifier).state = null;
    }
    return succes;
  }

  /// Rafraîchit la liste des commandes
  Future<void> rafraichir() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(commandesRepositoryProvider);
      return repo.getCommandesDisponibles();
    });
  }
}

/// Provider de la commande active en cours de livraison
final activeCommandeProvider = StateProvider<Commande?>((ref) => null);

/// Provider du compteur de refus consécutifs
final refusCountProvider = StateProvider<int>((ref) => 0);

/// État de suspension du livreur
class SuspensionState {
  final bool estSuspendu;
  final int secondesRestantes;

  const SuspensionState({
    this.estSuspendu = false,
    this.secondesRestantes = 0,
  });
}

/// Provider de la suspension temporaire
final suspensionProvider =
    StateNotifierProvider<SuspensionNotifier, SuspensionState>((ref) {
  return SuspensionNotifier();
});

/// Notifier gérant la suspension temporaire du livreur
class SuspensionNotifier extends StateNotifier<SuspensionState> {
  Timer? _timer;

  SuspensionNotifier() : super(const SuspensionState());

  /// Déclenche la suspension d'1 heure
  void declencher() {
    _timer?.cancel();
    state = const SuspensionState(
      estSuspendu: true,
      secondesRestantes: AppConstants.kDureeSuspensionSecondes,
    );

    // Décompte de la suspension
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.secondesRestantes <= 1) {
        timer.cancel();
        state = const SuspensionState(estSuspendu: false, secondesRestantes: 0);
      } else {
        state = SuspensionState(
          estSuspendu: true,
          secondesRestantes: state.secondesRestantes - 1,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
