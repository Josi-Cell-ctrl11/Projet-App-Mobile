// Tests unitaires des formateurs — OZELSERVICES Livreur
import 'package:flutter_test/flutter_test.dart';
import 'package:ozelservices_livreur/core/utils/formatters.dart';

void main() {
  group('formatFcfa', () {
    test('formate 1400 → "1 400 FCFA"', () {
      // Le séparateur de milliers en fr_FR peut être espace ou espace insécable
      final result = Formatters.formatFcfa(1400);
      expect(result, contains('1'));
      expect(result, contains('400'));
      expect(result, contains('FCFA'));
    });

    test('formate 0 → "0 FCFA"', () {
      final result = Formatters.formatFcfa(0);
      expect(result, contains('0'));
      expect(result, contains('FCFA'));
    });

    test('formate 5000 correctement', () {
      final result = Formatters.formatFcfa(5000);
      expect(result, contains('5'));
      expect(result, contains('000'));
      expect(result, contains('FCFA'));
    });
  });

  group('formatDistance', () {
    test('formate 3.2 → contient "3" et "km"', () {
      final result = Formatters.formatDistance(3.2);
      expect(result, contains('3'));
      expect(result, contains('km'));
    });

    test('formate 1.0 → contient "1" et "km"', () {
      final result = Formatters.formatDistance(1.0);
      expect(result, contains('1'));
      expect(result, contains('km'));
    });
  });

  group('formatDuree', () {
    test('formate 15 minutes → "15 min"', () {
      expect(Formatters.formatDuree(15), equals('15 min'));
    });

    test('formate 60 minutes → "1h"', () {
      expect(Formatters.formatDuree(60), equals('1h'));
    });

    test('formate 90 minutes → "1h30"', () {
      expect(Formatters.formatDuree(90), equals('1h30'));
    });

    test('formate 0 minutes → "0 min"', () {
      expect(Formatters.formatDuree(0), equals('0 min'));
    });
  });

  group('formatDate', () {
    test('formate une date correctement', () {
      final date = DateTime(2026, 5, 14);
      final result = Formatters.formatDate(date);
      expect(result, contains('14'));
      expect(result, contains('2026'));
      expect(result, contains('mai'));
    });

    test('formate janvier correctement', () {
      final date = DateTime(2026, 1, 3);
      final result = Formatters.formatDate(date);
      expect(result, contains('3'));
      expect(result, contains('jan.'));
      expect(result, contains('2026'));
    });
  });
}
