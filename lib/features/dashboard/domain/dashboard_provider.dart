// Provider du dashboard livreur — gestion du statut et des stats du jour
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// État du dashboard livreur
class DashboardState {
  /// Indique si le livreur est en ligne (disponible)
  final bool estEnLigne;

  /// Nombre de commandes complétées aujourd'hui
  final int commandesDuJour;

  /// Gains du jour en FCFA
  final double gainsDuJour;

  const DashboardState({
    this.estEnLigne = false,
    this.commandesDuJour = 0,
    this.gainsDuJour = 0,
  });

  DashboardState copyWith({
    bool? estEnLigne,
    int? commandesDuJour,
    double? gainsDuJour,
  }) {
    return DashboardState(
      estEnLigne: estEnLigne ?? this.estEnLigne,
      commandesDuJour: commandesDuJour ?? this.commandesDuJour,
      gainsDuJour: gainsDuJour ?? this.gainsDuJour,
    );
  }
}

/// Provider du statut en ligne/hors ligne du livreur
final livreurStatusProvider =
    StateNotifierProvider<LivreurStatusNotifier, bool>((ref) {
  return LivreurStatusNotifier();
});

/// Notifier gérant le statut de disponibilité du livreur
class LivreurStatusNotifier extends StateNotifier<bool> {
  LivreurStatusNotifier() : super(false); // Hors ligne par défaut

  /// Bascule le statut en ligne / hors ligne
  void toggleStatut() {
    state = !state;
    // En production : notifier le backend via API
  }

  /// Définit explicitement le statut
  void setStatut(bool enLigne) {
    state = enLigne;
  }
}

/// Provider du dashboard complet
final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier(ref);
});

/// Notifier gérant les données du dashboard
class DashboardNotifier extends StateNotifier<DashboardState> {
  DashboardNotifier(Ref ref) : super(const DashboardState()) {
    _chargerStatsDuJour();
  }

  /// Charge les statistiques du jour (mockées pour MVP)
  Future<void> _chargerStatsDuJour() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Données mockées : 3 commandes, 4200 FCFA de gains aujourd'hui
    state = state.copyWith(
      commandesDuJour: 3,
      gainsDuJour: 4200,
    );
  }

  /// Met à jour les stats après une livraison confirmée
  void ajouterLivraison(double montantGagne) {
    state = state.copyWith(
      commandesDuJour: state.commandesDuJour + 1,
      gainsDuJour: state.gainsDuJour + montantGagne,
    );
  }

  /// Rafraîchit les données du dashboard
  Future<void> rafraichir() async {
    await _chargerStatsDuJour();
  }
}
