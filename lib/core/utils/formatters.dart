// Formateurs d'affichage pour l'application OZELSERVICES Livreur
import 'package:intl/intl.dart';

/// Noms des mois en français (sans dépendance locale intl).
const _moisFr = [
  '', 'jan.', 'fév.', 'mar.', 'avr.', 'mai', 'juin',
  'juil.', 'août', 'sep.', 'oct.', 'nov.', 'déc.',
];

/// Fonctions de formatage pour l'affichage
class Formatters {
  Formatters._();

  /// Formate un montant en FCFA avec séparateur de milliers.
  /// Exemple : formatFcfa(1400) → "1 400 FCFA"
  static String formatFcfa(double montant) {
    final formatter = NumberFormat('#,##0', 'fr_FR');
    return '${formatter.format(montant.round())} FCFA';
  }

  /// Formate une distance en kilomètres.
  /// Exemple : formatDistance(3.2) → "3,2 km"
  static String formatDistance(double distanceKm) {
    final formatter = NumberFormat('#,##0.#', 'fr_FR');
    return '${formatter.format(distanceKm)} km';
  }

  /// Formate une durée en minutes.
  /// Exemple : formatDuree(15) → "15 min"
  static String formatDuree(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    }
    final heures = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) {
      return '${heures}h';
    }
    return '${heures}h${mins.toString().padLeft(2, '0')}';
  }

  /// Formate une date en français sans dépendance locale intl.
  /// Exemple : formatDate(DateTime(2026, 5, 14)) → "14 mai 2026"
  static String formatDate(DateTime date) {
    final mois = _moisFr[date.month];
    return '${date.day} $mois ${date.year}';
  }

  /// Formate une date et heure en français sans dépendance locale intl.
  /// Exemple : formatDateTime(DateTime(2026,5,14,14,30)) → "14 mai 2026 à 14:30"
  static String formatDateTime(DateTime date) {
    final mois = _moisFr[date.month];
    final hh = date.hour.toString().padLeft(2, '0');
    final mm = date.minute.toString().padLeft(2, '0');
    return '${date.day} $mois ${date.year} à $hh:$mm';
  }
}
