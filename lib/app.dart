import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_localizations/flutter_localizations.dart";

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

/// Point d’entrée : Firebase/FCM initialisés si possible (sinon l’app continue).
Future<void> bootstrapApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await initFirebaseMessaging();
  } catch (e, st) {
    debugPrint("Firebase non disponible (MVP) : $e\n$st");
  }
}
