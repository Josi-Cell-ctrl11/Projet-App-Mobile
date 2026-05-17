// Tests unitaires du calcul de la part livreur — OZELSERVICES Livreur
import 'package:flutter_test/flutter_test.dart';
import 'package:ozelservices_livreur/shared/models/commande.dart';
import 'package:ozelservices_livreur/core/constants/app_constants.dart';

void main() {
  group('Calcul partLivreur (70% du montant total)', () {
    Commande _makeCommande(double montantTotal) {
      return Commande(
        id: 'test',
        type: TypeCommande.ozelFoods,
        clientNom: 'Test',
        clientTelephone: '+22997000000',
        adressePickup: const Adresse(
            libelle: 'A', latitude: 6.36, longitude: 2.41),
        adresseLivraison: const Adresse(
            libelle: 'B', latitude: 6.37, longitude: 2.43),
        descriptionArticles: 'Test',
        distanceKm: 1.0,
        tempsEstimeMinutes: 5,
        montantTotal: montantTotal,
        partLivreur: montantTotal * AppConstants.kPartLivreur,
        statut: StatutCommande.disponible,
        createdAt: DateTime.now(),
      );
    }

    test('100 FCFA → 70 FCFA pour le livreur', () {
      final c = _makeCommande(100);
      expect(c.partLivreur, equals(70.0));
    });

    test('1000 FCFA → 700 FCFA pour le livreur', () {
      final c = _makeCommande(1000);
      expect(c.partLivreur, equals(700.0));
    });

    test('2500 FCFA → 1750 FCFA pour le livreur', () {
      final c = _makeCommande(2500);
      expect(c.partLivreur, equals(1750.0));
    });

    test('5000 FCFA → 3500 FCFA pour le livreur', () {
      final c = _makeCommande(5000);
      expect(c.partLivreur, equals(3500.0));
    });

    test('la commission OZEL est bien 30%', () {
      final c = _makeCommande(2000);
      final commission = c.montantTotal - c.partLivreur;
      expect(commission, equals(600.0)); // 30% de 2000
    });

    test('partLivreur + commission = montantTotal', () {
      for (final montant in [500.0, 1500.0, 3000.0, 7000.0]) {
        final c = _makeCommande(montant);
        final commission = c.montantTotal * AppConstants.kCommissionOzel;
        expect(c.partLivreur + commission, closeTo(c.montantTotal, 0.01));
      }
    });
  });
}
