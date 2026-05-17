// Données mockées des gains — MVP OZELSERVICES Livreur
import '../../../shared/models/commande.dart';
import '../../../shared/models/gain.dart';

/// Historique mocké de 10 livraisons avec agrégats cohérents
final mockGainsData = GainsData(
  soldeDisponible: 8750,
  gainsAujourdhui: 4200,
  gainsSemaine: 18900,
  gainsMois: 67200,
  historique: [
    // Aujourd'hui
    HistoriqueLivraison(
      commandeId: 'cmd_005',
      type: TypeCommande.ozelFoods,
      date: DateTime.now().subtract(const Duration(hours: 1)),
      montantGagne: 2450,
      statutPaiement: StatutPaiement.enAttente,
    ),
    HistoriqueLivraison(
      commandeId: 'cmd_004',
      type: TypeCommande.rapidColis,
      date: DateTime.now().subtract(const Duration(hours: 3)),
      montantGagne: 700,
      statutPaiement: StatutPaiement.enAttente,
    ),
    HistoriqueLivraison(
      commandeId: 'cmd_003',
      type: TypeCommande.ozelFoods,
      date: DateTime.now().subtract(const Duration(hours: 5)),
      montantGagne: 1050,
      statutPaiement: StatutPaiement.enAttente,
    ),
    // Hier
    HistoriqueLivraison(
      commandeId: 'cmd_h01',
      type: TypeCommande.ozelFoods,
      date: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      montantGagne: 1750,
      statutPaiement: StatutPaiement.credite,
    ),
    HistoriqueLivraison(
      commandeId: 'cmd_h02',
      type: TypeCommande.rapidColis,
      date: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
      montantGagne: 1400,
      statutPaiement: StatutPaiement.credite,
    ),
    HistoriqueLivraison(
      commandeId: 'cmd_h03',
      type: TypeCommande.ozelFoods,
      date: DateTime.now().subtract(const Duration(days: 1, hours: 6)),
      montantGagne: 2100,
      statutPaiement: StatutPaiement.credite,
    ),
    // Il y a 2 jours
    HistoriqueLivraison(
      commandeId: 'cmd_j02',
      type: TypeCommande.rapidColis,
      date: DateTime.now().subtract(const Duration(days: 2, hours: 1)),
      montantGagne: 700,
      statutPaiement: StatutPaiement.credite,
    ),
    HistoriqueLivraison(
      commandeId: 'cmd_j03',
      type: TypeCommande.ozelFoods,
      date: DateTime.now().subtract(const Duration(days: 2, hours: 3)),
      montantGagne: 1400,
      statutPaiement: StatutPaiement.credite,
    ),
    // Il y a 3 jours
    HistoriqueLivraison(
      commandeId: 'cmd_j04',
      type: TypeCommande.ozelFoods,
      date: DateTime.now().subtract(const Duration(days: 3, hours: 2)),
      montantGagne: 2450,
      statutPaiement: StatutPaiement.credite,
    ),
    HistoriqueLivraison(
      commandeId: 'cmd_j05',
      type: TypeCommande.rapidColis,
      date: DateTime.now().subtract(const Duration(days: 3, hours: 5)),
      montantGagne: 1050,
      statutPaiement: StatutPaiement.credite,
    ),
  ],
);
