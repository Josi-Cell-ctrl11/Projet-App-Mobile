import "package:flutter/services.dart";

/// Formatter pour les numéros de téléphone béninois (+229)
class BeninPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text;

    // Ajouter automatiquement +229 si ce n'est pas déjà là
    if (!text.startsWith('+229') && text.isNotEmpty) {
      if (text.startsWith('229')) {
        text = '+$text';
      } else if (!text.startsWith('+')) {
        text = '+229$text';
      }
    }

    // Limiter à 14 caractères (+229 + 9 chiffres)
    if (text.length > 14) {
      text = text.substring(0, 14);
    }

    return newValue.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
