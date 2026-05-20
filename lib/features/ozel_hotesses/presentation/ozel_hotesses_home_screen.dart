import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/hotesse_model.dart';
import '../application/ozel_hotesses_notifier.dart';

/// Ecran d'accueil Ozel Hotesses — liste des hotesses avec filtres.
/// PopScope intercepte le retour Android → accueil.
class OzelHotessesHomeScreen extends ConsumerStatefulWidget {
  const OzelHotessesHomeScreen({super.key});

  @override
  ConsumerState<OzelHotessesHomeScreen> createState() =>
      _OzelHotessesHomeScreenState();
}

class _OzelHotessesHomeScreenState
    extends ConsumerState<OzelHotessesHomeScreen> {
  static const Color _color = Color(0xFFAD1457);
  final _searchCtrl = TextEditingController();
  String _search = '';
  String _filtreLangue = 'tous';
  String _filtreTenue = 'tous';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hotesses = ref.watch(hotessesListProvider);

    final filtered = hotesses.where((h) {
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) context.go('/accueil');
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: _color,
          foregroundColor: AppColors.white,
          title: const Text(
            'Ozel Hotesses',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.list_alt_rounded),
              onPressed: () => context.push('/ozel-hotesses/reservations'),
              tooltip: 'Mes reservations',
            ),
          ],
        ),
        body: Column(
          children: [
            // ── Header rose ──────────────────────────────────────────────
            Container(
              color: _color,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                children: [
                  // Barre de recherche
                  TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _search = v),
                    decoration: InputDecoration(
                      hintText: 'Rechercher une hotesse...',
                      hintStyle: const TextStyle(
                          color: Colors.white60, fontSize: 13),
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: Colors.white60),
                      suffixIcon: _search.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded,
                                  color: Colors.white60, size: 18),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() => _search = '');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.15),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  // Filtres
                  SizedBox(
                    height: 36,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _Chip('Tous', _filtreLangue == 'tous',
                            () => setState(() => _filtreLangue = 'tous'),
                            _color),
                        const SizedBox(width: 8),
                        _Chip('FR', _filtreLangue == 'FR',
                            () => setState(() => _filtreLangue = 'FR'),
                            _color),
                        const SizedBox(width: 8),
                        _Chip('EN', _filtreLangue == 'EN',
                            () => setState(() => _filtreLangue = 'EN'),
                            _color),
                        const SizedBox(width: 8),
                        _Chip(
                            'Formelle',
                            _filtreTenue == 'Formelle',
                            () => setState(() => _filtreTenue =
                                _filtreTenue == 'Formelle'
                                    ? 'tous'
                                    : 'Formelle'),
                            _color),
                        const SizedBox(width: 8),
                        _Chip(
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
                ],
              ),
            ),

            // ── Liste hotesses ───────────────────────────────────────────
            Expanded(
              child: filtered.isEmpty
                  ? const Center(
                      child: Text('Aucune hotesse trouvee',
                          style: TextStyle(
                              color: AppColors.textSecondary)),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.65,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, i) => _HotesseCard(
                        hotesse: filtered[i],
                        color: _color,
                        onReserver: () => context.push(
                          '/ozel-hotesses/reservation',
                          extra: filtered[i],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Chip filtre ──────────────────────────────────────────────────────────────
class _Chip extends StatelessWidget {
  const _Chip(this.label, this.selected, this.onTap, this.color);
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.white : Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? color : Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

// ─── Card hotesse ─────────────────────────────────────────────────────────────
class _HotesseCard extends StatelessWidget {
  const _HotesseCard({
    required this.hotesse,
    required this.color,
    required this.onReserver,
  });
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
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar (photo protegee)
          Container(
            height: 90,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: color.withValues(alpha: 0.2),
                    child: Text(
                      hotesse.initiales,
                      style: TextStyle(
                        color: color,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Photo protegee',
                    style: TextStyle(
                        fontSize: 8, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),

          // Infos
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hotesse.prenom,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    hotesse.taille,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 10),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 12, color: Colors.amber),
                      Text(
                        ' ${hotesse.note}',
                        style: const TextStyle(
                            fontSize: 10, fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      Text(
                        '${hotesse.experience}a',
                        style: const TextStyle(
                            fontSize: 9,
                            color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Langues
                  Wrap(
                    spacing: 3,
                    runSpacing: 2,
                    children: hotesse.langues
                        .map((l) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                l,
                                style: TextStyle(
                                    color: color,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w700),
                              ),
                            ))
                        .toList(),
                  ),
                  const Spacer(),
                  Text(
                    '${Formatters.fcfa(hotesse.tarif)}/j',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    width: double.infinity,
                    height: 28,
                    child: FilledButton(
                      onPressed: onReserver,
                      style: FilledButton.styleFrom(
                        backgroundColor: color,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text(
                        'Reserver',
                        style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w700),
                      ),
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
