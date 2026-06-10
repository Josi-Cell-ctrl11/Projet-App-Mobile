import "package:firebase_auth/firebase_auth.dart";
import "package:firebase_core/firebase_core.dart";
import "package:firebase_messaging/firebase_messaging.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "../../firebase_options.dart";
import "../services/firestore_service.dart";

/// Token FCM accessible depuis l'app.
String? fcmToken;

/// Handler FCM arrière-plan (Android).
@pragma("vm:entry-point")
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("FCM background: ${message.messageId}");
}

/// Initialise Firebase + FCM + sauvegarde token dans Firestore.
Future<void> initFirebaseMessaging() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  final messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(alert: true, badge: true, sound: true);

  fcmToken = await messaging.getToken();
  debugPrint("FCM token: $fcmToken");

  // Sauvegarder le token dans Firestore pour cibler cet utilisateur
  _saveFcmToken(fcmToken);

  // Écouter les changements de token (refresh)
  messaging.onTokenRefresh.listen((newToken) {
    fcmToken = newToken;
    _saveFcmToken(newToken);
  });

  // Messages reçus en premier plan → affichage in-app
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint("FCM foreground: ${message.notification?.title}");
    _handleForegroundMessage(message);
  });

  // App ouverte depuis notification (background)
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    debugPrint("FCM opened: ${message.notification?.title}");
    _handleNotificationTap(message);
  });
}

/// Sauvegarde le token FCM dans le profil Firestore de l'utilisateur connecté.
Future<void> _saveFcmToken(String? token) async {
  if (token == null) return;
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return;
  try {
    final existing = await FirestoreService.instance.getUser(uid);
    if (existing == null) {
      debugPrint("Profil absent — token FCM non sauvegardé pour $uid");
      return;
    }
    await FirestoreService.instance.saveUser({"fcmToken": token}, uid);
  } catch (e) {
    debugPrint("Erreur sauvegarde token FCM : $e");
  }
}

/// Traite les messages reçus en premier plan.
void _handleForegroundMessage(RemoteMessage message) {
  // Les messages FCM en foreground ne s'affichent pas automatiquement
  // → ils sont gérés via le SnackBar global dans app.dart
  // Pour des notifications natives, utiliser flutter_local_notifications
}

/// Navigation suite à un tap sur une notification.
void _handleNotificationTap(RemoteMessage message) {
  final data = message.data;
  final type = data["type"] as String?;
  debugPrint("Notification tap — type: $type, data: $data");
  // La navigation est gérée par app.dart qui lit GoRouter
}

// ── Templates de notifications (référence backend) ──────────────────────────
//
// Ces payloads sont envoyés par le backend (Cloud Functions ou Laravel)
// via l'API Firebase Admin SDK. Ils sont documentés ici pour référence.
//
// 1. Commande OzelFoods confirmée
//    { "type": "food_order_status", "orderId": "...", "status": "riderAssigned" }
//
// 2. Livreur en route
//    { "type": "food_order_status", "orderId": "...", "status": "onTheWay" }
//
// 3. Livraison effectuée
//    { "type": "food_order_status", "orderId": "...", "status": "delivered" }
//
// 4. Réservation Event confirmée
//    { "type": "event_confirmed", "reservationId": "..." }
//
// 5. Retrait wallet effectué
//    { "type": "wallet_credit", "amount": "5000" }
//
// 6. Nouvelle commande disponible (livreur)
//    { "type": "new_order", "commandeId": "..." }

/// Templates de notification pour l'affichage in-app.
class NotificationTemplates {
  static Map<String, String> foodOrderStatus(String status) {
    switch (status) {
      case "riderAssigned":
        return {
          "title": "🛵 Livreur assigné",
          "body": "Un livreur est en route vers le restaurant",
        };
      case "onTheWay":
        return {
          "title": "🚀 En route vers vous",
          "body": "Votre commande arrive bientôt !",
        };
      case "delivered":
        return {
          "title": "✅ Commande livrée",
          "body": "Bon appétit ! Merci d'utiliser OzelFoods.",
        };
      default:
        return {
          "title": "📦 Mise à jour commande",
          "body": "Le statut de votre commande a changé",
        };
    }
  }

  static Map<String, String> walletCredit(double amount) => {
        "title": "💰 Crédit reçu",
        "body":
            "${amount.toInt()} FCFA ajoutés à votre OzelWallet",
      };

  static Map<String, String> eventConfirmed() => {
        "title": "🎉 Réservation confirmée",
        "body": "Votre réservation Ozel Event est confirmée",
      };

  static Map<String, String> colisEnRoute() => {
        "title": "📦 Colis en route",
        "body": "Votre colis Rapid Colis est en livraison",
      };
}

/// Affiche le token FCM dans un dialog — utile en développement.
void showFcmTokenDialog(BuildContext context) {
  final token = fcmToken ?? "Token non disponible";
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text("Token FCM",
          style: TextStyle(fontWeight: FontWeight.w800)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Copie ce token dans Firebase Console → Messaging pour tester.",
            style: TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              token,
              style: const TextStyle(fontSize: 11, fontFamily: "monospace"),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: token));
            Navigator.pop(ctx);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Token copié !")),
            );
          },
          child: const Text("Copier"),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text("Fermer"),
        ),
      ],
    ),
  );
}
