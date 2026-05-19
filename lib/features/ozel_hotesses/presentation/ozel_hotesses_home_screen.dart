import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/hotesse_model.dart';
import '../application/ozel_hotesses_notifier.dart';

/// Ecran d'accueil Ozel Hotesses.
class OzelHotessesHomeScreen extends ConsumerStatefulWidget {
  const OzelHotessesHomeScreen({super.key});

  @override
  ConsumerState<OzelHotessesHomeScreen> createState() =>
      _OzelHotessesHomeScreenState();
}

class _OzelHotessesHomeScreenState
    extends ConsumerState<OzelHotessesHomeScreen> {
  static const Color _color = Color(0xFFAD1457);
  String _search = '';
  String _filtreLangue = 'tous';
  String _filtreTenue = 'tous';

  @override
  Widget build(BuildContext context) {
    final hotesses = ref.watch(hotessesListProvider);

    var filtered = hotesses.where((h) {
      if (_search.isNotEmpty &&
          !h.prenom.toLowerCase().contains(_search.toLowerCase())) {
        return false;
      }
      if (_filtreLangue == 'FR' && !h.langues.contains('FR')) return false;
      if (_filtreLangue == 'EN' && !h.langues.contains('EN')) return false;
      if (_filtreTenue != 'tous' && !h.tenues.contains(_filtreTenue)) {
        return false;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: _color,
            foregroundColor: AppColors.white,
            expandedHeight: 140,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFAD1457), Color(0xFF880E4F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 30),
                      Icon(Icons.support_agent_rounded,
                          size: 36, color: Colors.white70),
                      SizedBox(height: 6),
                      Text('Ozel Hotesses',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
              ),
            ),
            title: const Text('Ozel Hotesses',
                style: TextStyle(fontWeight: FontWeight.w800)),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(52),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TextField(
                  onChanged: (v) => setState(() => _search = v),
                  decoration: InputDecoration(
                    hintText: 'Rechercher une hotesse...',
                    hintStyle: const TextStyle(
                        color: Colors.white60, fontSize: 13),
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: Colors.white60),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.15),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.list_alt_rounded),
                onPressed: () =>
                    context.push('/ozel-hotesses/reservations'),
                tooltip: 'Mes reservations',
              ),
            ],
          ),

          // Filtres
          SliverToBoxAdapter(
            child: SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _FilterChip('Tous', 'tous', _filtreLangue == 'tous',
                      () => setState(() => _filtreLangue = 'tous'), _color),
                  const SizedBox(width: 8),
                  _FilterChip('Langue FR', 'FR', _filtreLangue == 'FR',
                      () => setState(() => _filtreLangue = 'FR'), _color),
                  const SizedBox(width: 8),
                  _FilterChip('Langue EN', 'EN', _filtreLangue == 'EN',
                      () => setState(() => _filtreLangue = 'EN'), _color),
                  const SizedBox(width: 8),
                  _FilterChip(
                      'Formelle',
                      'Formelle',
                      _filtreTenue == 'Formelle',
                      () => setState(() => _filtreTenue =
                          _filtreTenue == 'Formelle' ? 'tous' : 'Formelle'),
                      _color),
                  const SizedBox(width: 8),
                  _FilterChip(
                      'Traditionnelle',
                      'Traditionnelle',
                      _filtreTenue == 'Traditionnelle',
                      () => setState(() => _filtreTenue =
                          _filtreTenue == 'Traditionnelle'
                              ? 'tous'
                              : 'Traditionnelle'),
                      _color),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // Grille hotesses
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverGrid(
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) => _HotesseCard(
                  hotesse: filtered[i],
                  color: _color,
                  onReserver: () => context.push(
                      '/ozel-hotesses/reservation',
                      extra: filtered[i]),
                ),
                childCount: filtered.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip(
      this.label, this.value, this.selected, this.onTap, this.color);
  final String label, value;
  final bool selected;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? color : AppColors.disabled),
        ),
        child: Text(label,
            style: TextStyle(
                color: selected ? AppColors.white : AppColors.black,
                fontWeight: FontWeight.w600,
                fontSize: 12)),
      ),
    );
  }
}

class _HotesseCard extends StatelessWidget {
  const _HotesseCard(
      {required this.hotesse,
      required this.color,
      required this.onReserver});
  final HotesseModel hotesse;
  final Color color;
  final VoidCallback onReserver;

  @override
  Widget build(BuildContext context) {
    return Container(
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
        children: [
          // Avatar floue (protection profil)
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16)),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: color.withValues(alpha: 0.2),
                    child: Text(hotesse.initiales,
                        style: TextStyle(
                            color: color,
                            fontSize: 24,
                            fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(height: 4),
                  const Text('Photo protegee',
                      style: TextStyle(
                          fontSize: 9, color: AppColors.textSecondary)),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(hotesse.prenom,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 14)),
                  Text(hotesse.taille,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 11)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 13, color: Colors.amber),
                      Text(' ${hotesse.note}',
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                      const Spacer(),
                      Text('${hotesse.experience}ans',
                          style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    children: hotesse.langues
                        .map((l) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(l,
                                  style: TextStyle(
                                      color: color,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700)),
                            ))
                        .toList(),
                  ),
                  const Spacer(),
                  Text(Formatters.fcfa(hotesse.tarif) + '/jour',
                      style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w800,
                          fontSize: 12)),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    height: 30,
                    child: FilledButton(
                      onPressed: onReserver,
                      style: FilledButton.styleFrom(
                        backgroundColor: color,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Reserver',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
