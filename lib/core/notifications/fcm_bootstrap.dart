import "package:firebase_core/firebase_core.dart";
import "package:firebase_messaging/firebase_messaging.dart";
import "package:flutter/foundation.dart";

import "../../firebase_options.dart";

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

  final token = await messaging.getToken();
  debugPrint("FCM token (MVP): $token");

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint("FCM foreground: ${message.notification?.title}");
  });
}
