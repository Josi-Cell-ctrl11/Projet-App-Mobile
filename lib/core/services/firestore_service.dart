import "package:cloud_firestore/cloud_firestore.dart";

/// Service Firestore centralisé — collections OZELSERVICES.
/// Chaque méthode correspond à une collection dans Firestore.
class FirestoreService {
  FirestoreService._();
  static final instance = FirestoreService._();

  final _db = FirebaseFirestore.instance;

  // ── Collections ───────────────────────────────────────────────────────────
  CollectionReference<Map<String, dynamic>> get users =>
      _db.collection("users");

  CollectionReference<Map<String, dynamic>> get commandesFoods =>
      _db.collection("commandes_foods");

  CollectionReference<Map<String, dynamic>> get commandesColis =>
      _db.collection("commandes_colis");

  CollectionReference<Map<String, dynamic>> get reservationsEvent =>
      _db.collection("reservations_event");

  CollectionReference<Map<String, dynamic>> get reservationsTours =>
      _db.collection("reservations_tours");

  CollectionReference<Map<String, dynamic>> get demandesSecurites =>
      _db.collection("demandes_securites");

  CollectionReference<Map<String, dynamic>> get demandesTic =>
      _db.collection("demandes_tic");

  CollectionReference<Map<String, dynamic>> walletTransactions(String uid) =>
      _db.collection("users").doc(uid).collection("wallet_transactions");

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Sauvegarde ou met à jour le profil utilisateur.
  Future<void> saveUser(Map<String, dynamic> data, String uid) =>
      users.doc(uid).set(data, SetOptions(merge: true));

  /// Récupère le profil utilisateur.
  Future<Map<String, dynamic>?> getUser(String uid) async {
    final doc = await users.doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  /// Ajoute une transaction wallet.
  Future<void> addWalletTransaction(
      String uid, Map<String, dynamic> data) =>
      walletTransactions(uid).add(data);

  /// Stream des transactions wallet d'un utilisateur.
  Stream<QuerySnapshot<Map<String, dynamic>>> walletStream(String uid) =>
      walletTransactions(uid)
          .orderBy("createdAt", descending: true)
          .snapshots();

  /// Référence document commande food (nouveau ou existant).
  DocumentReference<Map<String, dynamic>> commandeFoodDoc([String? id]) =>
      id != null ? commandesFoods.doc(id) : commandesFoods.doc();

  /// Ajoute une commande food.
  Future<DocumentReference> addCommandeFood(
          Map<String, dynamic> data) =>
      commandesFoods.add(data);

  /// Stream des commandes food d'un utilisateur.
  Stream<QuerySnapshot<Map<String, dynamic>>> commandesFoodsStream(
          String uid) =>
      commandesFoods
          .where("userId", isEqualTo: uid)
          .orderBy("createdAt", descending: true)
          .snapshots();

  /// Ajoute une commande colis.
  Future<DocumentReference> addCommandeColis(
          Map<String, dynamic> data) =>
      commandesColis.add(data);

  /// Ajoute une réservation event.
  Future<DocumentReference> addReservationEvent(
          Map<String, dynamic> data) =>
      reservationsEvent.add(data);

  /// Stream des réservations event d'un utilisateur.
  Stream<QuerySnapshot<Map<String, dynamic>>> reservationsEventStream(
          String uid) =>
      reservationsEvent
          .where("userId", isEqualTo: uid)
          .orderBy("createdAt", descending: true)
          .snapshots();

  /// Ajoute une réservation tour.
  Future<DocumentReference> addReservationTour(
          Map<String, dynamic> data) =>
      reservationsTours.add(data);

  /// Ajoute une demande sécurités.
  Future<DocumentReference> addDemandeSecurite(
          Map<String, dynamic> data) =>
      demandesSecurites.add(data);

  /// Ajoute une demande TIC.
  Future<DocumentReference> addDemandeTic(
          Map<String, dynamic> data) =>
      demandesTic.add(data);

  /// Convertit un DateTime en Timestamp Firestore.
  static Timestamp toTimestamp(DateTime dt) => Timestamp.fromDate(dt);

  /// Convertit un Timestamp Firestore en DateTime.
  static DateTime fromTimestamp(dynamic ts) {
    if (ts is Timestamp) return ts.toDate();
    if (ts is String) return DateTime.parse(ts);
    return DateTime.now();
  }
}
