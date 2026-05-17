// Constantes métier de l'application OZELSERVICES Livreur

/// Constantes métier globales
class AppConstants {
  AppConstants._();

  /// Commission prélevée par OZELSERVICES (30%)
  static const double kCommissionOzel = 0.30;

  /// Part reversée au livreur (70%)
  static const double kPartLivreur = 0.70;

  /// Durée du timer d'acceptation d'une commande (en secondes)
  static const int kTimerAcceptationSecondes = 30;

  /// Nombre maximum de refus consécutifs avant suspension
  static const int kMaxRefusConsecutifs = 3;

  /// Durée de suspension après trop de refus (en secondes = 1 heure)
  static const int kDureeSuspensionSecondes = 3600;

  /// Montant minimum pour un retrait MoMo (en FCFA)
  static const double kMontantMinRetrait = 1000;

  /// Note minimale avant avertissement de suspension
  static const double kNoteMinimale = 3.5;

  /// Délai de paiement des gains (J+1)
  static const int kDelaiPaiementJours = 1;

  /// Durée de validité de l'OTP d'authentification (en minutes)
  static const int kOtpDureeMinutes = 5;

  /// Délai minimum simulé pour les appels réseau mock (en ms)
  static const int kDelaiMockReseau = 500;

  /// Délai maximum simulé pour les appels réseau mock (en ms)
  static const int kDelaiMockReseauMax = 1500;
}
