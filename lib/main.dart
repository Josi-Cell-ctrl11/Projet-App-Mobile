// Point d'entrée de l'application OZELSERVICES Livreur
import 'dart:developer' as developer;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/notifications/notification_service.dart';

/// Handler de messages en arrière-plan (top-level, requis par Firebase)
/// Doit être enregistré avant runApp()
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase est déjà initialisé à ce stade
  await firebaseMessagingBackgroundHandler(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser Firebase (avec gestion gracieuse des erreurs pour le MVP)
  try {
    await Firebase.initializeApp();
    // Enregistrer le handler de messages en arrière-plan
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {
    // Firebase non configuré pour le MVP — l'app fonctionne sans notifications
    developer.log(
      '[Main] Firebase non initialisé (MVP) : $e',
      name: 'Main',
    );
  }

  runApp(
    const ProviderScope(
      child: OzelServicesLivreurApp(),
    ),
  );
}

/// Application principale OZELSERVICES Livreur
class OzelServicesLivreurApp extends ConsumerWidget {
  const OzelServicesLivreurApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'OZELSERVICES Livreur',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
      builder: (context, child) {
        // Initialiser les notifications après le premier rendu
        return _NotificationInitializer(child: child ?? const SizedBox.shrink());
      },
    );
  }
}

/// Widget qui initialise le service de notifications après le premier rendu
/// Utilise un ConsumerStatefulWidget pour accéder à WidgetRef
class _NotificationInitializer extends ConsumerStatefulWidget {
  final Widget child;

  const _NotificationInitializer({required this.child});

  @override
  ConsumerState<_NotificationInitializer> createState() =>
      _NotificationInitializerState();
}

class _NotificationInitializerState
    extends ConsumerState<_NotificationInitializer> {
  bool _initialise = false;

  @override
  void initState() {
    super.initState();
    // Initialiser après le premier frame pour avoir un contexte valide
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialiserNotifications();
    });
  }

  Future<void> _initialiserNotifications() async {
    if (_initialise) return;
    _initialise = true;

    if (!mounted) return;

    try {
      await NotificationService.initialize(context, ref);
    } catch (e) {
      developer.log(
        '[Main] Erreur initialisation notifications : $e',
        name: 'Main',
        error: e,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
