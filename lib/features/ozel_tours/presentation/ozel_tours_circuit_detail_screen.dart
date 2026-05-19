import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/circuit_model.dart';

/// Detail d'un circuit Ozel Tours.
class OzelToursCircuitDetailScreen extends StatelessWidget {
  const OzelToursCircuitDetailScreen({super.key, required this.circuit});
  final CircuitModel circuit;

  static const Color _color = Color(0xFF00695C);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: _color,
            foregroundColor: AppColors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF00695C), Color(0xFF004D40)],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Text(circuit.emoji,
                          style: const TextStyle(fontSize: 64)),
                      Text(circuit.destination,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ),
            ),
            title: Text(circuit.nom,
                style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Infos rapides
                  Row(
                    children: [
                      _InfoBadge(
                          Icons.schedule_rounded,
                          '${circuit.dureeJours} jour${circuit.dureeJours > 1 ? 's' : ''}',
                          _color),
                      const SizedBox(width: 8),
                      _InfoBadge(Icons.star_rounded,
                          '${circuit.note} (${circuit.nbAvis} avis)',
                          Colors.amber),
                      const SizedBox(width: 8),
                      if (circuit.assuranceIncluse)
                        _InfoBadge(Icons.shield_rounded,
                            'Assurance incluse', AppColors.success),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description
                  const Text('Description',
                      style: TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(circuit.description,
                      style: const TextStyle(
                          color: AppColors.textSecondary,
                          height: 1.5,
                          fontSize: 14)),
                  const SizedBox(height: 16),

                  // Programme
                  const Text('Programme',
                      style: TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(height: 8),
                  ...circuit.programme.asMap().entries.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: _color,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text('${e.key + 1}',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(e.value,
                                  style: const TextStyle(
                                      fontSize: 13, height: 1.4)),
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 16),

                  // Guide
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor:
                              _color.withValues(alpha: 0.15),
                          child: Text(circuit.guide[0],
                              style: TextStyle(
                                  color: _color,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(circuit.guide,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14)),
                              const Text('Guide certifie',
                                  style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.verified_rounded,
                                  color: Color(0xFF00695C), size: 14),
                              SizedBox(width: 4),
                              Text('Ministere',
                                  style: TextStyle(
                                      color: Color(0xFF00695C),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Prix
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Prix TTC / personne',
                                style: TextStyle(
                                    color: AppColors.textSecondary)),
                            Text(Formatters.fcfa(circuit.prix),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Commission OZEL (12%)',
                                style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12)),
                            Text(
                                Formatters.fcfa(
                                    circuit.prix * 0.12),
                                style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12)),
                          ],
                        ),
                        if (circuit.chauffeurInclus) ...[
                          const SizedBox(height: 4),
                          const Row(
                            children: [
                              Icon(Icons.directions_car_rounded,
                                  size: 14,
                                  color: AppColors.success),
                              SizedBox(width: 6),
                              Text('Chauffeur inclus',
                                  style: TextStyle(
                                      color: AppColors.success,
                                      fontSize: 12)),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: () => context.push(
                          '/ozel-tours/reservation',
                          extra: circuit),
                      style: FilledButton.styleFrom(
                        backgroundColor: _color,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.book_online_rounded),
                      label: const Text('Reserver ce circuit',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15)),
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

class _InfoBadge extends StatelessWidget {
  const _InfoBadge(this.icon, this.label, this.color);
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
