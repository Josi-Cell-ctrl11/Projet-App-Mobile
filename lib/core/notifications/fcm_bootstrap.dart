import "package:firebase_core/firebase_core.dart";
import "package:firebase_messaging/firebase_messaging.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "../../firebase_options.dart";

/// Token FCM accessible depuis l'app pour le tester.
String? fcmToken;

/// Handler FCM en tâche de fond (Android).
@pragma("vm:entry-point")
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("FCM background: ${message.messageId}");
}

/// Initialise Firebase + écoute basique des messages (token, foreground).
Future<void> initFirebaseMessaging() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  final messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(alert: true, badge: true, sound: true);

  fcmToken = await messaging.getToken();
  debugPrint("FCM token (MVP): $fcmToken");

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint("FCM foreground: ${message.notification?.title}");
  });
}

/// Affiche le token FCM dans un dialog pour le copier facilement.
/// À appeler depuis n'importe quel écran pour tester Firebase.
void showFcmTokenDialog(BuildContext context) {
  final token = fcmToken ?? "Token non disponible";
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text("Token FCM", style: TextStyle(fontWeight: FontWeight.w800)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Copie ce token et colle-le dans Firebase Console → Messaging pour tester les notifications.",
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
