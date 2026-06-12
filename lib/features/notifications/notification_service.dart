// Service de notifications push Firebase — OZELSERVICES Livreur
// Gère l'initialisation FCM, les permissions, et la navigation depuis les notifications
import 'dart:developer' as developer;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_colors.dart';
import '../../features/dashboard/domain/dashboard_provider.dart';

/// Clé SharedPreferences pour savoir si la permission a déjà été demandée
const String _kPermissionDemandeeKey = 'notification_permission_demandee';

/// Handler de messages en arrière-plan (doit être une fonction top-level)
/// Appelé quand l'app est terminée ou en arrière-plan
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Note : Firebase.initializeApp() doit avoir été appelé avant
  developer.log(
    '[Notifications] Message reçu en arrière-plan : ${message.messageId}',
    name: 'NotificationService',
  );
}

/// Service principal de gestion des notifications push
class NotificationService {
  NotificationService._();

  /// Initialise le service de notifications
  /// Doit être appelé après le démarrage de l'application
  static Future<void> initialize(BuildContext context, WidgetRef ref) async {
    try {
      // Enregistrer le handler de messages en arrière-plan
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Demander les permissions au premier lancement
      await _demanderPermissionsAuPremierLancement(context);

      // Configurer les handlers de messages
      _configurerHandlersForeground(context, ref);
      await _configurerHandlersBackground(context, ref);

      // Récupérer le token FCM (utile pour le backend en production)
      await _recupererToken();
    } catch (e) {
      // Gestion gracieuse des erreurs Firebase (ex : non configuré pour MVP)
      developer.log(
        '[Notifications] Erreur initialisation Firebase : $e',
        name: 'NotificationService',
        error: e,
      );
    }
  }

  /// Demande les permissions de notification au premier lancement
  /// Affiche un dialog explicatif avant la demande système
  static Future<void> _demanderPermissionsAuPremierLancement(
    BuildContext context,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dejaDemandeee = prefs.getBool(_kPermissionDemandeeKey) ?? false;

      if (dejaDemandeee) {
        // Permission déjà demandée lors d'un lancement précédent
        return;
      }

      // Marquer comme demandée avant d'afficher le dialog
      await prefs.setBool(_kPermissionDemandeeKey, true);

      // Vérifier si le contexte est encore valide
      if (!context.mounted) return;

      // Afficher le dialog explicatif avant la demande système
      final accepte = await _afficherDialogPermission(context);

      if (accepte == true) {
        // Demander la permission système
        final settings = await FirebaseMessaging.instance.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: false,
        );

        developer.log(
          '[Notifications] Statut permission : ${settings.authorizationStatus}',
          name: 'NotificationService',
        );
      }
    } catch (e) {
      developer.log(
        '[Notifications] Erreur demande permission : $e',
        name: 'NotificationService',
        error: e,
      );
    }
  }

  /// Affiche un dialog explicatif pour les notifications
  /// Retourne true si l'utilisateur accepte, false sinon
  static Future<bool?> _afficherDialogPermission(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.kPrimaryOrange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.notifications_active,
                color: AppColors.kPrimaryOrange,
                size: 24,
              ),
            ),
            const SizedBox(width: 12), 
            const Expanded(
              child: Text(
                'Activer les notifications',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: const Text(
          'Les notifications sont nécessaires pour recevoir de nouvelles commandes en temps réel.\n\n'
          'Sans notifications, vous risquez de manquer des opportunités de livraison.',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Plus tard',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.kPrimaryOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Activer'),
          ),
        ],
      ),
    );
  }

  /// Configure le handler pour les messages reçus en premier plan (app ouverte)
  static void _configurerHandlersForeground(
    BuildContext context,
    WidgetRef ref,
  ) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      developer.log(
        '[Notifications] Message reçu en premier plan : ${message.messageId}',
        name: 'NotificationService',
      );

      // Vérifier si le livreur est en ligne avant de traiter la notification
      final estEnLigne = ref.read(livreurStatusProvider);
      if (!estEnLigne) {
        developer.log(
          '[Notifications] Livreur hors ligne — notification ignorée',
          name: 'NotificationService',
        );
        return;
      }

      // Afficher une SnackBar pour les notifications en premier plan
      if (context.mounted) {
        _afficherSnackBarNotification(context, message, ref);
      }
    });
  }

  /// Configure les handlers pour les messages reçus en arrière-plan
  /// (app en arrière-plan ou terminée, puis ouverte via notification)
  static Future<void> _configurerHandlersBackground(
    BuildContext context,
    WidgetRef ref,
  ) async {
    // App ouverte depuis une notification (app était en arrière-plan)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      developer.log(
        '[Notifications] App ouverte depuis notification : ${message.messageId}',
        name: 'NotificationService',
      );
      _naviguerVersCommande(context, message);
    });

    // App ouverte depuis une notification (app était terminée)
    try {
      final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        developer.log(
          '[Notifications] App lancée depuis notification : ${initialMessage.messageId}',
          name: 'NotificationService',
        );
        // Délai pour laisser le routeur s'initialiser
        await Future.delayed(const Duration(milliseconds: 500));
        if (context.mounted) {
          _naviguerVersCommande(context, initialMessage);
        }
      }
    } catch (e) {
      developer.log(
        '[Notifications] Erreur getInitialMessage : $e',
        name: 'NotificationService',
        error: e,
      );
    }
  }

  /// Affiche une SnackBar pour une notification reçue en premier plan
  static void _afficherSnackBarNotification(
    BuildContext context,
    RemoteMessage message,
    WidgetRef ref,
  ) {
    final notification = message.notification;
    final data = message.data;

    final titre = notification?.title ?? 'Nouvelle commande';
    final corps = notification?.body ?? 'Une nouvelle commande est disponible';
    final commandeId = data['commandeId'] as String?;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.kPrimaryOrange,
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Row(
          children: [
            const Icon(
              Icons.delivery_dining,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titre,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    corps,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        action: commandeId != null
            ? SnackBarAction(
                label: 'Voir',
                textColor: Colors.white,
                onPressed: () {
                  context.push('/home/commandes/$commandeId');
                },
              )
            : null,
      ),
    );
  }

  /// Navigue vers l'écran de détail de la commande depuis une notification
  static void _naviguerVersCommande(
    BuildContext context,
    RemoteMessage message,
  ) {
    final commandeId = message.data['commandeId'] as String?;

    if (commandeId != null && commandeId.isNotEmpty) {
      developer.log(
        '[Notifications] Navigation vers commande : $commandeId',
        name: 'NotificationService',
      );
      context.push('/home/commandes/$commandeId');
    } else {
      // Pas d'ID de commande — naviguer vers la liste des commandes
      developer.log(
        '[Notifications] Pas de commandeId dans la notification — navigation vers liste',
        name: 'NotificationService',
      );
      context.go('/home?tab=1');
    }
  }

  /// Récupère et log le token FCM (utile pour le backend en production)
  static Future<void> _recupererToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      developer.log(
        '[Notifications] Token FCM : $token',
        name: 'NotificationService',
      );
      // En production : envoyer ce token au backend pour cibler ce livreur
    } catch (e) {
      developer.log(
        '[Notifications] Erreur récupération token FCM : $e',
        name: 'NotificationService',
        error: e,
      );
    }
  }
}
