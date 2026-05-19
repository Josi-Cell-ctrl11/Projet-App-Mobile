import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

/// Ecran d'accueil Ozel Securites.
class OzelSecuritesHomeScreen extends StatelessWidget {
  const OzelSecuritesHomeScreen({super.key});

  static const Color _color = Color(0xFF37474F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    colors: [Color(0xFF37474F), Color(0xFF263238)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 30),
                      Icon(Icons.security_rounded,
                          size: 40, color: Colors.white70),
                      SizedBox(height: 6),
                      Text('Ozel Securites',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900)),
                      Text('Jardinage & Securite privee',
                          style: TextStyle(
                              color: Colors.white60, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
            title: const Text('Ozel Securites',
                style: TextStyle(fontWeight: FontWeight.w800)),
            actions: [
              IconButton(
                icon: const Icon(Icons.list_alt_rounded),
                onPressed: () =>
                    context.push('/ozel-securites/contrats'),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Nos services',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.black)),
                  const SizedBox(height: 12),

                  // Jardinage
                  _ServiceCard(
                    emoji: '🌿',
                    title: 'Jardinage & Espaces verts',
                    desc: 'Abonnement 25 000 FCFA/mois (4 passages)\nOne-shot 8 000 FCFA',
                    color: const Color(0xFF2E7D32),
                    onTap: () =>
                        context.push('/ozel-securites/jardinage'),
                  ),
                  const SizedBox(height: 12),

                  // Vigile
                  _ServiceCard(
                    emoji: '🛡️',
                    title: 'Securite privee (Vigile)',
                    desc: '12h/nuit : 90 000 FCFA/mois\n24h/24 : 150 000 FCFA/mois',
                    color: _color,
                    onTap: () =>
                        context.push('/ozel-securites/vigile'),
                  ),
                  const SizedBox(height: 12),

                  // Urgence
                  _ServiceCard(
                    emoji: '🚨',
                    title: 'Intervention d\'urgence',
                    desc: 'Intervention <1h — 15 000 FCFA\nFausse alerte facturee',
                    color: Colors.red,
                    onTap: () =>
                        context.push('/ozel-securites/urgence'),
                  ),

                  const SizedBox(height: 24),

                  // Nos engagements
                  const Text('Nos engagements',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.black)),
                  const SizedBox(height: 12),
                  _EngagementRow(
                      Icons.build_rounded, 'Materiel fourni par OZEL'),
                  _EngagementRow(
                      Icons.school_rounded, 'Agents formes et certifies'),
                  _EngagementRow(
                      Icons.gps_fixed_rounded, 'Pointage GPS a chaque passage'),
                  _EngagementRow(
                      Icons.search_rounded,
                      'Vol chez client : enquete sous 48h'),
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

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.emoji,
    required this.title,
    required this.desc,
    required this.color,
    required this.onTap,
  });
  final String emoji, title, desc;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                  child: Text(emoji,
                      style: const TextStyle(fontSize: 26))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(desc,
                      style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          height: 1.4)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: color.withValues(alpha: 0.6)),
          ],
        ),
      ),
    );
  }
}

class _EngagementRow extends StatelessWidget {
  const _EngagementRow(this.icon, this.label);
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF37474F)),
          const SizedBox(width: 10),
          Text(label,
              style: const TextStyle(fontSize: 13, color: AppColors.black)),
        ],
      ),
    );
  }
}
