// Tests unitaires des validateurs — OZELSERVICES Livreur
import 'package:flutter_test/flutter_test.dart';
import 'package:ozelservices_livreur/core/utils/validators.dart';

void main() {
  group('validatePhoneBenin', () {
    test('accepte un numéro béninois valide', () {
      expect(validatePhoneBenin('+2290166272826'), isNull);
      expect(validatePhoneBenin('+2299711223300'), isNull);
      expect(validatePhoneBenin('0166272826'), isNull);
    });

    test('rejette un numéro trop court', () {
      expect(validatePhoneBenin('+2299711223'), isNotNull);
      expect(validatePhoneBenin('016627282'), isNotNull);
    });

    test('rejette un numéro trop long', () {
      expect(validatePhoneBenin('+22997112233400'), isNotNull);
      expect(validatePhoneBenin('01662728261'), isNotNull);
    });

    test('rejette un mauvais préfixe', () {
      expect(validatePhoneBenin('+33612345678'), isNotNull);
      expect(validatePhoneBenin('9711223300'), isNotNull);
      expect(validatePhoneBenin('0612345678'), isNotNull);
    });

    test('rejette des caractères non numériques', () {
      expect(validatePhoneBenin('+229971122AB'), isNotNull);
    });

    test('rejette une valeur vide ou null', () {
      expect(validatePhoneBenin(''), isNotNull);
      expect(validatePhoneBenin(null), isNotNull);
    });
  });

  group('validateOtp', () {
    test('accepte un OTP de 6 chiffres', () {
      expect(validateOtp('123456'), isNull);
      expect(validateOtp('000000'), isNull);
      expect(validateOtp('999999'), isNull);
    });

    test('rejette un OTP de 5 chiffres', () {
      expect(validateOtp('12345'), isNotNull);
    });

    test('rejette un OTP de 7 chiffres', () {
      expect(validateOtp('1234567'), isNotNull);
    });

    test('rejette un OTP avec des lettres', () {
      expect(validateOtp('12345A'), isNotNull);
      expect(validateOtp('ABCDEF'), isNotNull);
    });

    test('rejette une valeur vide ou null', () {
      expect(validateOtp(''), isNotNull);
      expect(validateOtp(null), isNotNull);
    });
  });

  group('validateMontantRetrait', () {
    const double solde = 5000;

    test('accepte un montant valide (>= 1000 et <= solde)', () {
      expect(validateMontantRetrait(1000, solde), isNull);
      expect(validateMontantRetrait(2500, solde), isNull);
      expect(validateMontantRetrait(5000, solde), isNull);
    });

    test('rejette un montant inférieur à 1000 FCFA', () {
      expect(validateMontantRetrait(999, solde), isNotNull);
      expect(validateMontantRetrait(0, solde), isNotNull);
      expect(validateMontantRetrait(500, solde), isNotNull);
    });

    test('rejette un montant supérieur au solde', () {
      expect(validateMontantRetrait(5001, solde), isNotNull);
      expect(validateMontantRetrait(10000, solde), isNotNull);
    });

    test('rejette un montant null', () {
      expect(validateMontantRetrait(null, solde), isNotNull);
    });
  });
}
