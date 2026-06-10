import "package:flutter/services.dart";

/// Formatter pour les numéros de téléphone béninois **avec +229 inclus** (Rapid Colis).
/// Limite : +229 + 8 chiffres. Pour l'auth sans +229, utiliser [PhoneBeninInputFormatter].
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

    // Limiter à 12 caractères (+229 + 8 chiffres)
    if (text.length > 12) {
      text = text.substring(0, 12);
    }

    return newValue.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
