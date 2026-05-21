import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/tic_ticket.dart';
import '../application/ozel_tic_notifier.dart';

/// Ecran d'accueil OzelTic — services informatiques.
class OzelTicHomeScreen extends ConsumerWidget {
  const OzelTicHomeScreen({super.key});

  static const Color _color = Color(0xFF1565C0);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tickets = ref.watch(ticTicketsProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) context.go('/accueil');
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: _color,
            foregroundColor: AppColors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 30),
                      Icon(Icons.devices_rounded,
                          size: 40, color: Colors.white70),
                      SizedBox(height: 6),
                      Text('OzelTic',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900)),
                      Text('Services informatiques & numeriques',
                          style: TextStyle(
                              color: Colors.white60, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
            title: const Text('OzelTic',
                style: TextStyle(fontWeight: FontWeight.w800)),
            actions: [
              IconButton(
                icon: const Icon(Icons.list_alt_rounded),
                onPressed: () => context.push('/ozel-tic/tickets'),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Grille 6 services
                  const Text('Nos services',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.black)),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.1,
                    children: [
                      _ServiceTile(
                        emoji: '🔧',
                        title: 'Depannage',
                        subtitle: 'PC/Mobile',
                        color: _color,
                        onTap: () => context.push('/ozel-tic/depannage'),
                      ),
                      _ServiceTile(
                        emoji: '🌐',
                        title: 'Site Web',
                        subtitle: 'App Mobile',
                        color: _color,
                        onTap: () => context.push('/ozel-tic/devis'),
                      ),
                      _ServiceTile(
                        emoji: '🔠',
                        title: 'Nom de domaine',
                        subtitle: '.bj .com .net',
                        color: _color,
                        onTap: () => context.push('/ozel-tic/domaine'),
                      ),
                      _ServiceTile(
                        emoji: '📹',
                        title: 'Caméras',
                        subtitle: 'Surveillance',
                        color: _color,
                        onTap: () => context.push('/ozel-tic/cameras'),
                      ),
                      _ServiceTile(
                        emoji: '🌐',
                        title: 'Réseaux',
                        subtitle: 'WiFi, câblage',
                        color: _color,
                        onTap: () => context.push('/ozel-tic/reseaux'),
                      ),
                      _ServiceTile(
                        emoji: '💬',
                        title: 'Support Chat',
                        subtitle: 'Technicien <2h',
                        color: _color,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Support chat — bientot disponible'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Derniers tickets
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Derniers tickets',
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.black)),
                      TextButton(
                        onPressed: () =>
                            context.push('/ozel-tic/tickets'),
                        child: const Text('Voir tout',
                            style: TextStyle(color: Color(0xFF1565C0))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...tickets.take(3).map((t) => _TicketMiniCard(ticket: t)),
                  const SizedBox(height: 16),

                  // Bouton nouveau ticket
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: () =>
                          context.push('/ozel-tic/depannage'),
                      style: FilledButton.styleFrom(
                        backgroundColor: _color,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Nouveau ticket',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
  final String emoji, title, subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: color.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const Spacer(),
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 14)),
            Text(subtitle,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _TicketMiniCard extends StatelessWidget {
  const _TicketMiniCard({required this.ticket});
  final TicTicket ticket;

  static const Color _color = Color(0xFF1565C0);

  Color _statutColor(StatutTicket s) => switch (s) {
        StatutTicket.enAttente => AppColors.warning,
        StatutTicket.assigne => _color,
        StatutTicket.enCours => AppColors.primary,
        StatutTicket.resolu => AppColors.success,
      };

  @override
  Widget build(BuildContext context) {
    final sc = _statutColor(ticket.statut);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.confirmation_number_rounded,
                color: Color(0xFF1565C0), size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ticket.type,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13)),
                Text(ticket.modeLabel,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: sc.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(ticket.statutLabel,
                    style: TextStyle(
                        color: sc,
                        fontSize: 9,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
