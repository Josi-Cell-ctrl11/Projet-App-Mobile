// Repository des commandes — Firestore
import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../shared/models/commande.dart';
import 'commandes_repository.dart';

/// Implémentation Firestore du repository des commandes.
///
/// Collection Firestore : `commandes`
/// Document schema :
///   id, type, clientNom, clientTelephone, adressePickup{libelle,latitude,longitude},
///   adresseLivraison{...}, descriptionArticles, distanceKm, tempsEstimeMinutes,
///   montantTotal, partLivreur, statut, otpCode, createdAt, livreurId (nullable)
class FirestoreCommandesRepository implements ICommandesRepository {
  FirestoreCommandesRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('commandes');

  String? get _uid => _auth.currentUser?.uid;

  @override
  Future<List<Commande>> getCommandesDisponibles() async {
    final snap = await _col
        .where('statut', isEqualTo: StatutCommande.disponible.name)
        .get();

    final commandes = snap.docs.map((d) => _fromFirestore(d)).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return commandes;
  }

  @override
  Future<void> accepterCommande(String commandeId) async {
    final uid = _uid;
    if (uid == null) throw Exception('Non authentifié');

    await _col.doc(commandeId).update({
      'statut': StatutCommande.acceptee.name,
      'livreurId': uid,
      'acceptedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> refuserCommande(String commandeId) async {
    // On log le refus sans changer le statut Firestore —
    // le backend décide si la commande reste disponible ou est réassignée.
    developer.log(
      '[Commandes] Refus commande $commandeId par $_uid',
      name: 'FirestoreCommandes',
    );
  }

  @override
  Future<void> updateStatutCommande(
      String commandeId, StatutCommande statut) async {
    await _col.doc(commandeId).update({
      'statut': statut.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<bool> confirmerLivraisonOtp(String commandeId, String otp) async {
    final doc = await _col.doc(commandeId).get();
    if (!doc.exists) return false;

    final data = doc.data()!;
    final otpCode = data['otpCode'] as String?;

    if (otpCode != otp) return false;

    await _col.doc(commandeId).update({
      'statut': StatutCommande.livree.name,
      'livraisonAt': FieldValue.serverTimestamp(),
    });
    return true;
  }

  // ── Helpers ──────────────────────────────────────────────────────────

  Commande _fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Commande(
      id: doc.id,
      type: TypeCommande.values.firstWhere((e) => e.name == d['type']),
      clientNom: d['clientNom'] as String,
      clientTelephone: d['clientTelephone'] as String,
      adressePickup: Adresse.fromJson(
          d['adressePickup'] as Map<String, dynamic>),
      adresseLivraison: Adresse.fromJson(
          d['adresseLivraison'] as Map<String, dynamic>),
      descriptionArticles: d['descriptionArticles'] as String,
      distanceKm: (d['distanceKm'] as num).toDouble(),
      tempsEstimeMinutes: (d['tempsEstimeMinutes'] as num).toInt(),
      montantTotal: (d['montantTotal'] as num).toDouble(),
      partLivreur: (d['partLivreur'] as num).toDouble(),
      statut: StatutCommande.values
          .firstWhere((e) => e.name == d['statut']),
      otpCode: d['otpCode'] as String?,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
