import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/tour_reservation.dart';

/// E-billet QR code Ozel Tours.
class OzelToursEbilletScreen extends StatelessWidget {
  const OzelToursEbilletScreen({super.key, this.reservation});
  final TourReservation? reservation;

  static const Color _color = Color(0xFF00695C);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: _color,
        foregroundColor: AppColors.white,
        title: const Text('E-billet',
            style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Partage du billet — bientot disponible'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: reservation == null
          ? const Center(
              child: Text('Aucun billet disponible',
                  style: TextStyle(color: AppColors.textSecondary)))
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // QR Code mock
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: _color.withValues(alpha: 0.12),
                          blurRadius: 16,
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: Column(
                    children: [
                      // QR code mock avec pattern
                      Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          color: AppColors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: CustomPaint(
                          painter: _QrPainter(reservation!.qrCode),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(reservation!.qrCode,
                          style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Details
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Details du circuit',
                          style: TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 15)),
                      const SizedBox(height: 12),
                      _Row(Icons.place_rounded, 'Destination',
                          reservation!.destination),
                      _Row(Icons.calendar_today_rounded, 'Depart',
                          '${reservation!.dateDepart.day}/${reservation!.dateDepart.month}/${reservation!.dateDepart.year}'),
                      _Row(Icons.people_rounded, 'Personnes',
                          '${reservation!.nbPersonnes}'),
                      _Row(Icons.person_pin_rounded, 'Guide',
                          reservation!.guide),
                      _Row(Icons.directions_car_rounded, 'Chauffeur',
                          'Inclus'),
                      const Divider(height: 20),
                      _Row(Icons.payments_rounded, 'Montant',
                          Formatters.fcfa(reservation!.montant)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Points x2
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: Colors.amber.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    children: [
                      Text('⭐', style: TextStyle(fontSize: 20)),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Points Ozel x2 credites automatiquement apres le circuit.',
                          style: TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.w600,
                              fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () => context.go('/accueil'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _color,
                      side: const BorderSide(color: Color(0xFF00695C)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.home_rounded),
                    label: const Text('Retour a l\'accueil',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.icon, this.label, this.value);
  final IconData icon;
  final String label, value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF00695C)),
          const SizedBox(width: 10),
          SizedBox(
            width: 90,
            child: Text(label,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

/// QR code mock avec pattern visuel
class _QrPainter extends CustomPainter {
  const _QrPainter(this.data);
  final String data;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final cellSize = size.width / 10;
    // Pattern pseudo-aleatoire base sur les chars du QR code
    for (int i = 0; i < 10; i++) {
      for (int j = 0; j < 10; j++) {
        final idx = (i * 10 + j) % data.length;
        if (data.codeUnitAt(idx) % 2 == 0) {
          canvas.drawRect(
            Rect.fromLTWH(
                i * cellSize + 1, j * cellSize + 1, cellSize - 2, cellSize - 2),
            paint,
          );
        }
      }
    }
    // Coins QR
    final cornerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRect(
        Rect.fromLTWH(4, 4, cellSize * 3, cellSize * 3), cornerPaint);
    canvas.drawRect(
        Rect.fromLTWH(size.width - cellSize * 3 - 4, 4, cellSize * 3,
            cellSize * 3),
        cornerPaint);
    canvas.drawRect(
        Rect.fromLTWH(4, size.height - cellSize * 3 - 4, cellSize * 3,
            cellSize * 3),
        cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
