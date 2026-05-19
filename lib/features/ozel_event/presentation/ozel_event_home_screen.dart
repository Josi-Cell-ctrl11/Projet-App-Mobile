import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

/// Ecran d'accueil Ozel Event — evenementiel au Benin.
class OzelEventHomeScreen extends StatelessWidget {
  const OzelEventHomeScreen({super.key});

  static const Color _color = Color(0xFF6A1B9A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          // ── Header violet ────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: _color,
            foregroundColor: AppColors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6A1B9A), Color(0xFF4A148C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 40),
                      Icon(Icons.event_available_rounded,
                          size: 48, color: Colors.white70),
                      SizedBox(height: 8),
                      Text(
                        'Ozel Event',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'Organisez votre evenement au Benin',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            title: const Text('Ozel Event',
                style: TextStyle(fontWeight: FontWeight.w800)),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Types d'evenements ─────────────────────────────────────
                  const Text(
                    'Quel type d\'evenement ?',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.black),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _TypeCard(
                          emoji: '🎊',
                          label: 'Mariage',
                          color: _color,
                          onTap: () => context.push('/ozel-event/devis',
                              extra: 'mariage')),
                      const SizedBox(width: 10),
                      _TypeCard(
                          emoji: '🎂',
                          label: 'Anniversaire',
                          color: _color,
                          onTap: () => context.push('/ozel-event/devis',
                              extra: 'anniversaire')),
                      const SizedBox(width: 10),
                      _TypeCard(
                          emoji: '💼',
                          label: 'Conference',
                          color: _color,
                          onTap: () => context.push('/ozel-event/devis',
                              extra: 'conference')),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── Nos prestations ────────────────────────────────────────
                  const Text(
                    'Nos prestations',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.black),
                  ),
                  const SizedBox(height: 12),
                  _PrestationCard(
                    icon: Icons.speaker_rounded,
                    title: 'Sonorisation',
                    desc: '1 000 FCFA / personne',
                    color: _color,
                  ),
                  const SizedBox(height: 8),
                  _PrestationCard(
                    icon: Icons.restaurant_rounded,
                    title: 'Traiteur',
                    desc: '3 500 FCFA / personne',
                    color: _color,
                  ),
                  const SizedBox(height: 8),
                  _PrestationCard(
                    icon: Icons.celebration_rounded,
                    title: 'Decoration',
                    desc: '2 000 FCFA / personne',
                    color: _color,
                  ),
                  const SizedBox(height: 8),
                  _PrestationCard(
                    icon: Icons.manage_accounts_rounded,
                    title: 'Chef projet OZEL',
                    desc: 'Inclus automatiquement si >100 invites',
                    color: _color,
                  ),

                  const SizedBox(height: 24),

                  // ── Boutons ────────────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: () =>
                          context.push('/ozel-event/devis'),
                      style: FilledButton.styleFrom(
                        backgroundColor: _color,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.calculate_rounded),
                      label: const Text('Demander un devis',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          context.push('/ozel-event/reservations'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _color,
                        side: const BorderSide(color: Color(0xFF6A1B9A)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.list_alt_rounded),
                      label: const Text('Mes reservations',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeCard extends StatelessWidget {
  const _TypeCard(
      {required this.emoji,
      required this.label,
      required this.color,
      required this.onTap});
  final String emoji, label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border:
                Border.all(color: color.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                  color: color.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 6),
              Text(label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: color)),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrestationCard extends StatelessWidget {
  const _PrestationCard(
      {required this.icon,
      required this.title,
      required this.desc,
      required this.color});
  final IconData icon;
  final String title, desc;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14)),
                Text(desc,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
