// Repository des gains — Firestore
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../shared/models/commande.dart';
import '../../../shared/models/gain.dart';
import 'gains_repository.dart';

/// Implémentation Firestore du repository des gains.
///
/// Collections :
///   gains/{uid}            → solde, agrégats
///   gains/{uid}/historique → liste HistoriqueLivraison
///   retraits               → demandes de retrait
class FirestoreGainsRepository implements IGainsRepository {
  FirestoreGainsRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  String get _uid {
    final u = _auth.currentUser;
    if (u == null) throw Exception('Non authentifié');
    return u.uid;
  }

  @override
  Future<GainsData> getGains() async {
    final uid = _uid;

    // Lecture du doc gains principal
    final docSnap = await _db.collection('gains').doc(uid).get();

    // Lecture de l'historique (sous-collection)
    final histSnap = await _db
        .collection('gains')
        .doc(uid)
        .collection('historique')
        .orderBy('date', descending: true)
        .limit(50)
        .get();

    // Valeurs par défaut si le doc n'existe pas encore
    final data = docSnap.data() ?? {};
    final historique = histSnap.docs.map((d) {
      final h = d.data();
      return HistoriqueLivraison(
        commandeId: h['commandeId'] as String,
        type: TypeCommande.values
            .firstWhere((e) => e.name == h['type']),
        date: (h['date'] as Timestamp).toDate(),
        montantGagne: (h['montantGagne'] as num).toDouble(),
        statutPaiement: StatutPaiement.values
            .firstWhere((e) => e.name == (h['statutPaiement'] ?? 'enAttente')),
      );
    }).toList();

    return GainsData(
      soldeDisponible: (data['soldeDisponible'] as num? ?? 0).toDouble(),
      gainsAujourdhui: (data['gainsAujourdhui'] as num? ?? 0).toDouble(),
      gainsSemaine: (data['gainsSemaine'] as num? ?? 0).toDouble(),
      gainsMois: (data['gainsMois'] as num? ?? 0).toDouble(),
      historique: historique,
    );
  }

  @override
  Future<void> demanderRetrait(String numeroMomo, double montant) async {
    final uid = _uid;

    await _db.collection('retraits').add({
      'livreurId': uid,
      'numeroMomo': numeroMomo,
      'montant': montant,
      'statut': 'en_attente',
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Déduire du solde disponible localement (le backend confirmera)
    await _db.collection('gains').doc(uid).set({
      'soldeDisponible': FieldValue.increment(-montant),
    }, SetOptions(merge: true));
  }
}
