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

/// Extrait les 10 chiffres locaux d'un numéro E.164 béninois.
String phoneLocalFromE164(String e164) {
  final digits = e164.replaceAll(RegExp(r"\D"), "");
  if (digits.startsWith("229") && digits.length > 3) {
    return digits.substring(3, digits.length.clamp(3, 13));
  }
  return digits.length > 10 ? digits.substring(0, 10) : digits;
}

/// Convertit une saisie locale (avec ou sans espaces) en E.164 : `+2290166272826`.
String phoneToE164(String input) {
  final digits = input.replaceAll(RegExp(r"\D"), "");
  if (digits.startsWith("229") && digits.length >= 13) {
    return "+${digits.substring(0, 13)}";
  }
  if (digits.length == 10) {
    return "+229$digits";
  }
  return "+229$digits";
}

/// Affiche un numéro E.164 : `+229 01 66 27 28 26`.
String formatPhoneDisplay(String e164) {
  final local = phoneLocalFromE164(e164);
  if (local.isEmpty) return "+229";
  return "+229 ${formatLocalPhone(local)}";
}

/// Formate 10 chiffres locaux avec espaces : `01 66 27 28 26`.
String formatLocalPhone(String digits) {
  final limited =
      digits.length > 10 ? digits.substring(0, 10) : digits;
  final buffer = StringBuffer();
  for (var i = 0; i < limited.length; i++) {
    if (i == 2 || i == 4 || i == 6 || i == 8) buffer.write(" ");
    buffer.write(limited[i]);
  }
  return buffer.toString();
}

/// Formate un numéro béninois **sans préfixe +229** (auth, profil).
/// Format : `XX XX XX XX XX` — à utiliser avec `prefixText: "+229 "` dans les champs login/inscription.
///
/// Exemple : "0166272826" → "01 66 27 28 26"
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
