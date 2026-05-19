import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/hotesse_reservation.dart';
import '../application/ozel_hotesses_notifier.dart';

/// Liste des reservations Ozel Hotesses.
class OzelHotessesMesReservationsScreen extends ConsumerWidget {
  const OzelHotessesMesReservationsScreen({super.key});

  static const Color _color = Color(0xFFAD1457);

  Color _statutColor(StatutHotesseReservation s) => switch (s) {
        StatutHotesseReservation.enAttente => AppColors.warning,
        StatutHotesseReservation.confirmee => AppColors.success,
        StatutHotesseReservation.enCours => const Color(0xFF1565C0),
        StatutHotesseReservation.terminee => AppColors.textSecondary,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reservations = ref.watch(hotessesReservationsProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: _color,
        foregroundColor: AppColors.white,
        title: const Text('Mes reservations',
            style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => context.go('/ozel-hotesses'),
          ),
        ],
      ),
      body: reservations.isEmpty
          ? const Center(
              child: Text('Aucune reservation',
                  style: TextStyle(color: AppColors.textSecondary)))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: reservations.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final r = reservations[i];
                final sc = _statutColor(r.statut);
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2))
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: _color.withValues(alpha: 0.12),
                        child: Text(r.hotessePrenom[0],
                            style: TextStyle(
                                color: _color,
                                fontWeight: FontWeight.w800,
                                fontSize: 16)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r.hotessePrenom,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14)),
                            Text(
                                '${r.typeEvenement} • ${r.dureeHeures}h • ${r.dateDebut.day}/${r.dateDebut.month}/${r.dateDebut.year}',
                                style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12)),
                            Text(Formatters.fcfa(r.tarif),
                                style: TextStyle(
                                    color: _color,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: sc.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(r.statutLabel,
                            style: TextStyle(
                                color: sc,
                                fontSize: 10,
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
