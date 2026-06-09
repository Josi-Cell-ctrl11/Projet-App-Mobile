// Provider navigation GPS — gestion d'état Riverpod
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/commande.dart';

/// Phase de navigation en cours
enum PhaseNavigation { versPickup, versLivraison, terminee }

/// État de la navigation GPS
class NavigationState {
  final PhaseNavigation phase;
  final bool gpsActif;
  final double? latitudeActuelle;
  final double? longitudeActuelle;

  const NavigationState({
    this.phase = PhaseNavigation.versPickup,
    this.gpsActif = false,
    this.latitudeActuelle,
    this.longitudeActuelle,
  });

  NavigationState copyWith({
    PhaseNavigation? phase,
    bool? gpsActif,
    double? latitudeActuelle,
    double? longitudeActuelle,
  }) {
    return NavigationState(
      phase: phase ?? this.phase,
      gpsActif: gpsActif ?? this.gpsActif,
      latitudeActuelle: latitudeActuelle ?? this.latitudeActuelle,
      longitudeActuelle: longitudeActuelle ?? this.longitudeActuelle,
    );
  }
}

/// Provider de la navigation (par commande)
final navigationProvider = StateNotifierProvider.family<
    NavigationNotifier, NavigationState, String>((ref, commandeId) {
  return NavigationNotifier();
});

/// Notifier gérant la progression GPS de la livraison
class NavigationNotifier extends StateNotifier<NavigationState> {
  NavigationNotifier() : super(const NavigationState(gpsActif: true));

  /// Passe à la phase "vers livraison" (après avoir atteint le pickup)
  void passerVersLivraison() {
    state = state.copyWith(phase: PhaseNavigation.versLivraison);
  }

  /// Marque la navigation comme terminée
  void terminer() {
    state = state.copyWith(phase: PhaseNavigation.terminee, gpsActif: false);
  }

  /// Met à jour la position GPS courante
  void updatePosition(double lat, double lng) {
    state = state.copyWith(latitudeActuelle: lat, longitudeActuelle: lng);
  }
}

/// Retourne l'adresse cible selon la phase de navigation
Adresse? adresseCible(NavigationState nav, Commande commande) {
  switch (nav.phase) {
    case PhaseNavigation.versPickup:
      return commande.adressePickup;
    case PhaseNavigation.versLivraison:
      return commande.adresseLivraison;
    case PhaseNavigation.terminee:
      return null;
  }
}
