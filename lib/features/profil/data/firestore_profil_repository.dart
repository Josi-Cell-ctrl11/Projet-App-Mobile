// Repository du profil — Firestore
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../shared/models/livreur.dart';
import 'profil_repository.dart';

/// Implémentation Firestore du repository du profil livreur.
///
/// Collection : `livreurs/{uid}`
class FirestoreProfilRepository implements IProfilRepository {
  FirestoreProfilRepository({
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

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('livreurs');

  @override
  Future<Livreur> getProfil() async {
    final uid = _uid;
    final doc = await _col.doc(uid).get();
    if (!doc.exists || doc.data() == null) {
      return Livreur(
        id: uid,
        nom: '',
        prenom: '',
        telephone: _auth.currentUser?.phoneNumber ?? '',
        typeVehicule: TypeVehicule.moto,
        note: 5.0,
        totalLivraisons: 0,
        estEnLigne: false,
        documents: const [],
      );
    }
    return Livreur.fromJson({'id': uid, ...doc.data()!});
  }

  @override
  Future<void> updateProfil(Livreur livreur) async {
    final uid = _uid;
    await _col.doc(uid).set({
      'nom': livreur.nom,
      'prenom': livreur.prenom,
      'telephone': livreur.telephone,
      'photoUrl': livreur.photoUrl,
      'typeVehicule': livreur.typeVehicule.name,
      'note': livreur.note,
      'totalLivraisons': livreur.totalLivraisons,
      'estEnLigne': livreur.estEnLigne,
      'documents': livreur.documents.map((d) => d.toJson()).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Met à jour uniquement le statut en ligne/hors ligne.
  Future<void> updateStatutEnLigne(bool estEnLigne) async {
    await _col.doc(_uid).update({
      'estEnLigne': estEnLigne,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
