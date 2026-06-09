// Repository d'authentification — Firebase Phone Auth
import 'dart:async';
import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../shared/models/document.dart';
import '../../../shared/models/livreur.dart';
import 'auth_repository.dart';

const String _kLivreurIdKey = 'ozel_livreur_id';

/// Implémentation Firebase Phone Auth du repository d'authentification.
///
/// Flux :
///   1. [sendOtp]   → Firebase envoie un SMS
///   2. [verifyOtp] → valide le code, crée/récupère le profil Firestore
class FirebaseAuthRepository implements IAuthRepository {
  FirebaseAuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    FlutterSecureStorage? storage,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _db = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? const FlutterSecureStorage();

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;
  final FlutterSecureStorage _storage;

  /// verificationId conservé entre sendOtp() et verifyOtp()
  String? _verificationId;

  // ── Interface publique ───────────────────────────────────────────────

  @override
  Future<void> sendOtp(String phoneNumber) async {
    final completer = Completer<void>();

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) {
        // Auto-vérification Android (SMS Retriever API)
        developer.log('[Auth] Auto-vérification Android', name: 'FirebaseAuth');
      },
      verificationFailed: (FirebaseAuthException e) {
        developer.log('[Auth] Échec : ${e.message}', name: 'FirebaseAuth');
        if (!completer.isCompleted) {
          completer.completeError(Exception(_messageErreur(e.code)));
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        developer.log('[Auth] SMS envoyé', name: 'FirebaseAuth');
        _verificationId = verificationId;
        if (!completer.isCompleted) completer.complete();
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
        if (!completer.isCompleted) completer.complete();
      },
    );

    return completer.future;
  }

  @override
  Future<Livreur> verifyOtp(String phone, String otp) async {
    if (_verificationId == null) {
      throw Exception('Aucune vérification en cours. Renvoyez le code.');
    }

    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: otp,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user;
    if (user == null) throw Exception('Connexion Firebase échouée');

    await _storage.write(key: _kLivreurIdKey, value: user.uid);
    return _getOuCreerLivreur(user.uid, user.phoneNumber ?? phone);
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
    await _storage.delete(key: _kLivreurIdKey);
  }

  @override
  Future<Livreur?> getStoredSession() async {
    // Firebase Auth persiste la session nativement — pas besoin de token manuel
    final user = _auth.currentUser;
    if (user == null) return null;
    try {
      return await _getOuCreerLivreur(user.uid, user.phoneNumber ?? '');
    } catch (e) {
      developer.log('[Auth] Erreur lecture session : $e', name: 'FirebaseAuth');
      return null;
    }
  }

  // ── Helpers privés ───────────────────────────────────────────────────

  /// Récupère le profil Firestore ou crée un profil minimal à la première connexion.
  Future<Livreur> _getOuCreerLivreur(String uid, String phone) async {
    final doc = await _db.collection('livreurs').doc(uid).get();

    if (doc.exists && doc.data() != null) {
      return Livreur.fromJson({'id': uid, ...doc.data()!});
    }

    // Première connexion → profil vide à compléter dans l'app
    final nouveau = Livreur(
      id: uid,
      nom: '',
      prenom: '',
      telephone: phone,
      typeVehicule: TypeVehicule.moto,
      note: 5.0,
      totalLivraisons: 0,
      estEnLigne: false,
      documents: [
        const Document(type: TypeDocument.cni, statut: StatutDocument.manquant),
        const Document(
            type: TypeDocument.permis, statut: StatutDocument.manquant),
        const Document(
            type: TypeDocument.assurance, statut: StatutDocument.manquant),
      ],
    );

    await _db
        .collection('livreurs')
        .doc(uid)
        .set(_toFirestore(nouveau), SetOptions(merge: true));

    return nouveau;
  }

  Map<String, dynamic> _toFirestore(Livreur l) => {
        'nom': l.nom,
        'prenom': l.prenom,
        'telephone': l.telephone,
        'photoUrl': l.photoUrl,
        'typeVehicule': l.typeVehicule.name,
        'note': l.note,
        'totalLivraisons': l.totalLivraisons,
        'estEnLigne': l.estEnLigne,
        'documents': l.documents.map((d) => d.toJson()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  String _messageErreur(String code) {
    switch (code) {
      case 'invalid-phone-number':
        return 'Numéro de téléphone invalide';
      case 'too-many-requests':
        return 'Trop de tentatives. Réessayez dans quelques minutes.';
      case 'quota-exceeded':
        return 'Quota SMS dépassé. Contactez le support.';
      default:
        return 'Erreur envoi du code ($code)';
    }
  }
}
