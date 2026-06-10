/// Validation centralisée pour le formulaire Rapid Colis
class ColisFormValidator {
  /// Valide les adresses de départ et livraison
  static String? validateAddresses(String pointA, String pointB) {
    if (pointA.trim().isEmpty || pointB.trim().isEmpty) {
      return "Renseignez les points A et B.";
    }
    return null;
  }

  /// Valide le nom du destinataire
  static String? validateRecipientName(String prenom, String nom) {
    if (prenom.trim().length < 2 || nom.trim().length < 2) {
      return "Le prénom et le nom doivent contenir au moins 2 caractères.";
    }
    return null;
  }

  /// Valide le numéro de téléphone du destinataire
  static String? validateRecipientPhone(String telephone) {
    if (!telephone.trim().startsWith('+229')) {
      return "Le téléphone doit commencer par +229.";
    }
    final digits = telephone.replaceAll(RegExp(r"[^\d]"), "");
    if (digits.length != 13) {
      return "Le numéro doit contenir 10 chiffres après +229";
    }
    return null;
  }

  /// Valide tous les champs du formulaire
  static Map<String, String?> validateAll({
    required String pointA,
    required String pointB,
    required String destinatairePrenom,
    required String destinataireNom,
    required String destinataireTelephone,
  }) {
    return {
      'addresses': validateAddresses(pointA, pointB),
      'recipientName': validateRecipientName(destinatairePrenom, destinataireNom),
      'recipientPhone': validateRecipientPhone(destinataireTelephone),
    };
  }
}
