// Validateurs de l'application OZELSERVICES Livreur
import '../constants/app_strings.dart';

/// Valide un numéro de téléphone béninois (+229 suivi de 8 chiffres)
/// Retourne null si valide, un message d'erreur sinon.
String? validatePhoneBenin(String? value) {
  if (value == null || value.trim().isEmpty) {
    return AppStrings.numeroInvalide;
  }
  // Accepte +229 suivi de exactement 8 chiffres (ex: +22997112233)
  final regex = RegExp(r'^\+229\d{8}$');
  if (!regex.hasMatch(value.trim())) {
    return AppStrings.numeroInvalide;
  }
  return null;
}

/// Valide un code OTP (6 chiffres)
/// Retourne null si valide, un message d'erreur sinon.
String? validateOtp(String? value) {
  if (value == null || value.trim().isEmpty) {
    return AppStrings.codeIncorrect;
  }
  final regex = RegExp(r'^\d{6}$');
  if (!regex.hasMatch(value.trim())) {
    return AppStrings.codeIncorrect;
  }
  return null;
}

/// Valide un montant de retrait MoMo
/// [montant] : montant saisi, [solde] : solde disponible
/// Retourne null si valide, un message d'erreur sinon.
String? validateMontantRetrait(double? montant, double solde) {
  if (montant == null) {
    return AppStrings.montantMinimum;
  }
  if (montant < 1000) {
    return AppStrings.montantMinimum;
  }
  if (montant > solde) {
    return AppStrings.soldeInsuffisant;
  }
  return null;
}
