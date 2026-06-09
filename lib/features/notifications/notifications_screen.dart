// Écran des notifications livreur
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/models/commande.dart';
import '../../../shared/widgets/ozel_card.dart';

/// Modèle d'une notification in-app
class NotifItem {
  final String id;
  final String titre;
  final String corps;
  final NotifType type;
  final DateTime date;
  final bool lue;

  const NotifItem({
    required this.id,
    required this.titre,
    required this.corps,
    required this.type,
    required this.date,
    this.lue = false,
  });

  NotifItem copyWith({bool? lue}) => NotifItem(
        id: id,
        titre: titre,
        corps: corps,
        type: type,
        date: date,
        lue: lue ?? this.lue,
      );
}

enum NotifType { nouvelleCommande, livraison, gain, systeme, suspension }

/// Notifications mockées
final List<NotifItem> _mockNotifs = [
  NotifItem(
    id: 'n1',
    titre: 'Nouvelle commande disponible',
    corps: 'Une commande OzelFoods de 1 400 FCFA vous attend. Acceptez dans les 30 secondes.',
    type: NotifType.nouvelleCommande,
    date: DateTime.now().subtract(const Duration(minutes: 5)),
  ),
  NotifItem(
    id: 'n2',
    titre: 'Livraison confirmée ✓',
    corps: 'Commande #cmd_003 livrée avec succès. 1 750 FCFA crédités demain.',
    type: NotifType.livraison,
    date: DateTime.now().subtract(const Duration(hours: 1)),
    lue: true,
  ),
  NotifItem(
    id: 'n3',
    titre: 'Gain crédité',
    corps: '3 150 FCFA ont été crédités sur votre solde. Solde total : 12 600 FCFA.',
    type: NotifType.gain,
    date: DateTime.now().subtract(const Duration(hours: 2)),
    lue: true,
  ),
  NotifItem(
    id: 'n4',
    titre: 'Nouvelle commande disponible',
    corps: 'Une commande Rapid Colis de 700 FCFA vous attend près de Ganhi.',
    type: NotifType.nouvelleCommande,
    date: DateTime.now().subtract(const Duration(hours: 3)),
    lue: true,
  ),
  NotifItem(
    id: 'n5',
    titre: 'Bienvenue sur OZELSERVICES',
    corps: 'Votre compte livreur est activé. Activez votre disponibilité pour recevoir vos premières commandes.',
    type: NotifType.systeme,
    date: DateTime.now().subtract(const Duration(days: 1)),
    lue: true,
  ),
  NotifItem(
    id: 'n6',
    titre: 'Suspension temporaire',
    corps: 'Vous avez refusé 3 commandes consécutives. Suspension de 30 minutes appliquée.',
    type: NotifType.suspension,
    date: DateTime.now().subtract(const Duration(days: 2)),
    lue: true,
  ),
];

/// Provider de la liste de notifications
final notifsProvider =
    StateNotifierProvider<NotifsNotifier, List<NotifItem>>((ref) {
  return NotifsNotifier();
});

class NotifsNotifier extends StateNotifier<List<NotifItem>> {
  NotifsNotifier() : super(_mockNotifs);

  void marquerLue(String id) {
    state = state
        .map((n) => n.id == id ? n.copyWith(lue: true) : n)
        .toList();
  }

  void marquerToutesLues() {
    state = state.map((n) => n.copyWith(lue: true)).toList();
  }
}

/// Provider du compteur de notifications non lues
final notifsNonLuesProvider = Provider<int>((ref) {
  final notifs = ref.watch(notifsProvider);
  return notifs.where((n) => !n.lue).length;
});

/// Écran principal des notifications
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifs = ref.watch(notifsProvider);
    final nonLues = notifs.where((n) => !n.lue).length;

    return Scaffold(
      backgroundColor: AppColors.kBackground,
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Notifications'),
            if (nonLues > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.kRed,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$nonLues',
                  style: const TextStyle(
                    color: AppColors.kWhite,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        backgroundColor: AppColors.kPrimaryOrange,
        foregroundColor: AppColors.kWhite,
        actions: [
          if (nonLues > 0)
            TextButton(
              onPressed: () =>
                  ref.read(notifsProvider.notifier).marquerToutesLues(),
              child: const Text(
                'Tout lire',
                style: TextStyle(color: AppColors.kWhite, fontSize: 12),
              ),
            ),
        ],
      ),
      body: notifs.isEmpty
          ? const _EtatVide()
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: notifs.length,
              itemBuilder: (context, i) {
                final notif = notifs[i];
                return _NotifTile(
                  notif: notif,
                  onTap: () =>
                      ref.read(notifsProvider.notifier).marquerLue(notif.id),
                );
              },
            ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final NotifItem notif;
  final VoidCallback onTap;

  const _NotifTile({required this.notif, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final (icone, couleur) = _getStyle();

    return OzelCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icône
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: couleur.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icone, color: couleur, size: 22),
              ),
              const SizedBox(width: 12),
              // Contenu
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notif.titre,
                            style: TextStyle(
                              fontWeight: notif.lue
                                  ? FontWeight.w500
                                  : FontWeight.bold,
                              fontSize: 13,
                              color: AppColors.kTextPrimary,
                            ),
                          ),
                        ),
                        if (!notif.lue)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.kPrimaryOrange,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notif.corps,
                      style: TextStyle(
                        fontSize: 12,
                        color: notif.lue
                            ? AppColors.kTextSecondary
                            : AppColors.kTextPrimary,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(notif.date),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.kTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  (IconData, Color) _getStyle() {
    switch (notif.type) {
      case NotifType.nouvelleCommande:
        return (Icons.delivery_dining, AppColors.kPrimaryOrange);
      case NotifType.livraison:
        return (Icons.check_circle, AppColors.kGreen);
      case NotifType.gain:
        return (Icons.account_balance_wallet, AppColors.kGreen);
      case NotifType.systeme:
        return (Icons.info_outline, AppColors.kBlue);
      case NotifType.suspension:
        return (Icons.block, AppColors.kRed);
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    if (diff.inDays == 1) return 'Hier';
    return 'Il y a ${diff.inDays} jours';
  }
}

class _EtatVide extends StatelessWidget {
  const _EtatVide();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 64, color: AppColors.kGrey),
          SizedBox(height: 16),
          Text(
            'Aucune notification',
            style: TextStyle(fontSize: 16, color: AppColors.kTextSecondary),
          ),
        ],
      ),
    );
  }
}
