import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../core/theme/app_colors.dart";
import "../../../core/utils/formatters.dart";
import "../application/active_colis_notifier.dart";

/// Suivi livraison GPS — carte mockee (google_maps desactive en attendant cle API).
class ColisTrackingScreen extends ConsumerWidget {
  const ColisTrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shipment = ref.watch(activeColisProvider);
    if (shipment == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Suivi colis")),
        body: const Center(child: Text("Aucune livraison active.")),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          "Suivi livraison",
          style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.black),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final s = ref.read(activeColisProvider);
          if (s == null) return;
          ref.read(activeColisProvider.notifier).setShipment(
                s.copyWith(
                  driverLat: (s.driverLat ?? 6.3725) + 0.0012,
                  driverLng: (s.driverLng ?? 2.3544) + 0.0008,
                ),
              );
        },
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.navigation_rounded),
        label: const Text("Simuler mouvement"),
      ),
      body: Column(
        children: [
          // ── Carte mockee ───────────────────────────────────────────────────
          Expanded(
            child: Container(
              color: const Color(0xFFE8F0FE),
              child: Stack(
                children: [
                  // Fond grille mock
                  CustomPaint(
                    painter: _GridPainter(),
                    child: const SizedBox.expand(),
                  ),
                  // Centre : icone livreur
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.4),
                                blurRadius: 20,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.delivery_dining_rounded,
                            color: AppColors.white,
                            size: 36,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Text(
                            "Livreur en route",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Badge GPS mock
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            "GPS actif",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Note carte mock
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        "Carte GPS disponible apres configuration de la cle Google Maps",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          textBaseline: TextBaseline.alphabetic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Infos livraison ────────────────────────────────────────────────
          Container(
            width: double.infinity,
            color: AppColors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.flag_rounded,
                        color: AppColors.success, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        shipment.pointA,
                        style: const TextStyle(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.place_rounded,
                        color: AppColors.primary, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        shipment.pointB,
                        style: const TextStyle(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Montant : ${Formatters.fcfa(shipment.priceFcfa)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "En cours",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD0E4FF)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
