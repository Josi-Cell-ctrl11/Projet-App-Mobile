import "package:intl/intl.dart";

/// Formatage monnaie XOF (FCFA) pour l’affichage UI.
abstract final class Formatters {
  static final NumberFormat _fcfa = NumberFormat.currency(
    locale: "fr_FR",
    symbol: "FCFA",
    decimalDigits: 0,
  );

  static String fcfa(num value) => _fcfa.format(value);
}
