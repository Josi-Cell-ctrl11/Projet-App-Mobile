// Données mockées des commandes — MVP OZELSERVICES Livreur
import '../../../shared/models/commande.dart';

/// 5 commandes mockées variées (3 OzelFoods + 2 Rapid Colis)
/// Coordonnées GPS réelles de Cotonou, Bénin
final List<Commande> mockCommandes = [
  // Commande 1 — OzelFoods : Restaurant → Akpakpa
  Commande(
    id: 'cmd_001',
    type: TypeCommande.ozelFoods,
    clientNom: 'Adjoua Koffi',
    clientTelephone: '+22997223344',
    adressePickup: const Adresse(
      libelle: 'Restaurant Le Bénin, Cadjehoun, Cotonou',
      latitude: 6.3654,
      longitude: 2.4183,
    ),
    adresseLivraison: const Adresse(
      libelle: 'Quartier Akpakpa, Rue des Cocotiers, Cotonou',
      latitude: 6.3702,
      longitude: 2.4350,
    ),
    descriptionArticles:
        'Riz sauce graine x2, Poulet braisé x1, Jus de gingembre x2',
    distanceKm: 3.2,
    tempsEstimeMinutes: 15,
    montantTotal: 2000,
    partLivreur: 1400, // 70% de 2000
    statut: StatutCommande.disponible,
    otpCode: '847291',
    createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
  ),

  // Commande 2 — Rapid Colis : Dantokpa → Fidjrossè
  Commande(
    id: 'cmd_002',
    type: TypeCommande.rapidColis,
    clientNom: 'Brice Ahouansou',
    clientTelephone: '+22996334455',
    adressePickup: const Adresse(
      libelle: 'Marché Dantokpa, Cotonou',
      latitude: 6.3601,
      longitude: 2.4270,
    ),
    adresseLivraison: const Adresse(
      libelle: 'Fidjrossè Plage, Cotonou',
      latitude: 6.3480,
      longitude: 2.3890,
    ),
    descriptionArticles: 'Colis fragile — Pièces électroniques (1 carton)',
    distanceKm: 5.8,
    tempsEstimeMinutes: 22,
    montantTotal: 1500,
    partLivreur: 1050, // 70% de 1500
    statut: StatutCommande.disponible,
    otpCode: '362819',
    createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
  ),

  // Commande 3 — OzelFoods : Maquis → Agla
  Commande(
    id: 'cmd_003',
    type: TypeCommande.ozelFoods,
    clientNom: 'Fatou Diallo',
    clientTelephone: '+22997445566',
    adressePickup: const Adresse(
      libelle: 'Maquis Chez Tonton, Haie Vive, Cotonou',
      latitude: 6.3720,
      longitude: 2.4100,
    ),
    adresseLivraison: const Adresse(
      libelle: 'Quartier Agla, Cotonou',
      latitude: 6.3810,
      longitude: 2.3950,
    ),
    descriptionArticles:
        'Attiéké poisson x1, Alloco x2, Boisson fraîche x3',
    distanceKm: 2.5,
    tempsEstimeMinutes: 12,
    montantTotal: 2500,
    partLivreur: 1750, // 70% de 2500
    statut: StatutCommande.disponible,
    otpCode: '519374',
    createdAt: DateTime.now().subtract(const Duration(minutes: 1)),
  ),

  // Commande 4 — Rapid Colis : Ganhi → Cadjehoun
  Commande(
    id: 'cmd_004',
    type: TypeCommande.rapidColis,
    clientNom: 'Rodrigue Hounkpatin',
    clientTelephone: '+22995556677',
    adressePickup: const Adresse(
      libelle: 'Zone Ganhi, Cotonou',
      latitude: 6.3580,
      longitude: 2.4320,
    ),
    adresseLivraison: const Adresse(
      libelle: 'Cadjehoun, Cotonou',
      latitude: 6.3660,
      longitude: 2.4150,
    ),
    descriptionArticles:
        'Documents administratifs — Enveloppe scellée (urgent)',
    distanceKm: 1.8,
    tempsEstimeMinutes: 10,
    montantTotal: 1000,
    partLivreur: 700, // 70% de 1000
    statut: StatutCommande.disponible,
    otpCode: '728463',
    createdAt: DateTime.now().subtract(const Duration(seconds: 30)),
  ),

  // Commande 5 — OzelFoods : Fast-food → Cotonou Centre
  Commande(
    id: 'cmd_005',
    type: TypeCommande.ozelFoods,
    clientNom: 'Mariama Sow',
    clientTelephone: '+22994667788',
    adressePickup: const Adresse(
      libelle: 'Fast Food Délices, Boulevard Saint-Michel, Cotonou',
      latitude: 6.3640,
      longitude: 2.4200,
    ),
    adresseLivraison: const Adresse(
      libelle: 'Cotonou Centre, près de la Cathédrale',
      latitude: 6.3690,
      longitude: 2.4260,
    ),
    descriptionArticles:
        'Burger x2, Frites x2, Milkshake chocolat x1, Salade x1',
    distanceKm: 1.2,
    tempsEstimeMinutes: 8,
    montantTotal: 3500,
    partLivreur: 2450, // 70% de 3500
    statut: StatutCommande.disponible,
    otpCode: '193847',
    createdAt: DateTime.now(),
  ),
];
