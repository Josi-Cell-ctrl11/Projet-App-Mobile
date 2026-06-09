import "package:flutter/services.dart";
import "package:intl/intl.dart";

/// Formatage monnaie XOF (FCFA) pour l'affichage UI.
abstract final class Formatters {
  static final NumberFormat _fcfa = NumberFormat.currency(
    locale: "fr_FR",
    symbol: "FCFA",
    decimalDigits: 0,
  );

  static String fcfa(num value) => _fcfa.format(value);
}

/// Formate automatiquement un numéro béninois au format XX XX XX XX
/// pendant la saisie. L'utilisateur tape uniquement les chiffres,
/// les espaces sont insérés automatiquement.
///
/// Exemple : "0197909098" → "01 97 90 90 98"
class PhoneBeninInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Garder uniquement les chiffres
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    // Limiter à 10 chiffres
    final limited = digits.length > 10 ? digits.substring(0, 10) : digits;

    // Insérer les espaces : XX XX XX XX
    final buffer = StringBuffer();
    for (int i = 0; i < limited.length; i++) {
      if (i == 2 || i == 4 || i == 6 || i == 8) buffer.write(' ');
      buffer.write(limited[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
