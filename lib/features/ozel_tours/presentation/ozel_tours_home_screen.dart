import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/circuit_model.dart';
import '../application/ozel_tours_notifier.dart';

/// Ecran d'accueil Ozel Tours.
class OzelToursHomeScreen extends ConsumerStatefulWidget {
  const OzelToursHomeScreen({super.key});

  @override
  ConsumerState<OzelToursHomeScreen> createState() =>
      _OzelToursHomeScreenState();
}

class _OzelToursHomeScreenState extends ConsumerState<OzelToursHomeScreen>
    with SingleTickerProviderStateMixin {
  static const Color _color = Color(0xFF00695C);
  late TabController _tabCtrl;
  final PageController _carouselCtrl = PageController();
  int _carouselIndex = 0;
  Timer? _carouselTimer;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 5, vsync: this);
    _carouselTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      final next = (_carouselIndex + 1) % 5;
      _carouselCtrl.animateToPage(next,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _carouselCtrl.dispose();
    _carouselTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final circuits = ref.watch(circuitsProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) context.go('/accueil');
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            pinned: true,
            backgroundColor: _color,
            foregroundColor: AppColors.white,
            expandedHeight: 160,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF00695C), Color(0xFF004D40)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 30),
                      Text('🇧🇯', style: TextStyle(fontSize: 32)),
                      SizedBox(height: 4),
                      Text('Decouvrez le Benin',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900)),
                      Text('Circuits, hotels, guides certifies',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
            title: const Text('Ozel Tours',
                style: TextStyle(fontWeight: FontWeight.w800)),
            actions: [
              IconButton(
                icon: const Icon(Icons.confirmation_num_rounded),
                onPressed: () => context.push('/ozel-tours/ebillet'),
                tooltip: 'Mes billets',
              ),
            ],
            bottom: TabBar(
              controller: _tabCtrl,
              indicatorColor: AppColors.white,
              labelColor: AppColors.white,
              unselectedLabelColor: Colors.white60,
              tabs: const [
                Tab(text: 'Circuits'),
                Tab(text: 'Guest Houses'),
                Tab(text: 'Hotels'),
                Tab(text: 'Guides'),
                Tab(text: 'Voitures'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabCtrl,
          children: [
            // Onglet Circuits
            _CircuitsTab(circuits: circuits, color: _color),
            // Onglet Guest Houses
            _ComingSoonTab(
                icon: Icons.home_work_rounded,
                label: 'Guest Houses',
                color: _color),
            // Onglet Hotels (mock)
            _ComingSoonTab(
                icon: Icons.hotel_rounded,
                label: 'Hotels',
                color: _color),
            // Onglet Guides (mock)
            _ComingSoonTab(
                icon: Icons.person_pin_rounded,
                label: 'Guides',
                color: _color),
            // Onglet Voitures (mock)
            _ComingSoonTab(
                icon: Icons.directions_car_rounded,
                label: 'Voitures',
                color: _color),
          ],
        ),
      ),
    ),
    );
  }
}

class _CircuitsTab extends StatelessWidget {
  const _CircuitsTab({required this.circuits, required this.color});
  final List<CircuitModel> circuits;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Badge Points x2
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00695C), Color(0xFF004D40)],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Row(
            children: [
              Text('⭐', style: TextStyle(fontSize: 20)),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Points Ozel x2',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14)),
                    Text('Gagnez le double de points sur tous les circuits !',
                        style: TextStyle(
                            color: Colors.white70, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text('Circuits populaires',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.black)),
        const SizedBox(height: 12),
        ...circuits.map((c) => _CircuitCard(circuit: c, color: color)),

        const SizedBox(height: 24),

        // ── Tourisme local ─────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.explore_rounded, color: color, size: 24),
                  const SizedBox(width: 10),
                  const Text(
                    'Tourisme local',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Découvrez les trésors cachés du Bénin avec nos guides locaux. Visites personnalisées, ateliers artisanaux, et expériences culturelles authentiques.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => context.push('/ozel-tours/tourisme'),
                  style: FilledButton.styleFrom(
                    backgroundColor: color,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.hiking_rounded),
                  label: const Text('S\'inscrire au tourisme local',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CircuitCard extends StatelessWidget {
  const _CircuitCard({required this.circuit, required this.color});
  final CircuitModel circuit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          context.push('/ozel-tours/circuit/${circuit.id}', extra: circuit),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: color.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 3))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header avec emoji
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(circuit.emoji,
                        style: const TextStyle(fontSize: 56)),
                  ),
                  // Badge Points x2
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('⭐ Points x2',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                    ),
                  ),
                  // Badge assurance
                  if (circuit.assuranceIncluse)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text('Assurance incluse',
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ),
                    ),
                  // Duree
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                          '${circuit.dureeJours} jour${circuit.dureeJours > 1 ? 's' : ''}',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: color)),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(circuit.nom,
                            style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                size: 14, color: Colors.amber),
                            Text(' ${circuit.note}',
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                            Text(' (${circuit.nbAvis} avis)',
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Sur devis',
                          style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w700,
                              fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComingSoonTab extends StatelessWidget {
  const _ComingSoonTab(
      {required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: color.withValues(alpha: 0.4)),
          const SizedBox(height: 12),
          Text('$label — Bientot disponible',
              style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
