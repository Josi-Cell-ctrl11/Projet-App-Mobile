import "dart:ui";

import "package:firebase_crashlytics/firebase_crashlytics.dart";
import "package:flutter/material.dart";
import "package:flutter_localizations/flutter_localizations.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "core/analytics/app_analytics.dart";
import "core/notifications/fcm_bootstrap.dart";
import "core/theme/app_theme.dart";
import "router/app_router.dart";

/// Racine Material + localisation française.
class OzelApp extends ConsumerWidget {
  const OzelApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      title: "OZELSERVICES BENIN",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: router,
      locale: const Locale("fr"),
      supportedLocales: const [Locale("fr")],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}

/// Point d'entrée : Firebase + FCM + Crashlytics + Analytics initialisés.
Future<void> bootstrapApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await initFirebaseMessaging();

    // Crashlytics
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    // Analytics — activer la collecte
    await analytics.setAnalyticsCollectionEnabled(true);
  } catch (e, st) {
    debugPrint("Firebase non disponible : $e\n$st");
  }
}
