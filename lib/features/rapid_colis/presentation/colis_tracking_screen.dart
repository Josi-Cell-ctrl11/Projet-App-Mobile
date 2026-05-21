import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../core/theme/app_colors.dart";
import "../../../core/utils/formatters.dart";
import "../application/active_colis_notifier.dart";

const Color _orange = Color(0xFFFF6B35);
const Color _lightGray = Color(0xFFF8F8F8);
const Color _darkGray = Color(0xFF333333);
const Color _lightOrange = Color(0xFFFFE5DB);

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
      backgroundColor: _lightGray,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _darkGray),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Suivi livraison",
          style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black),
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
        backgroundColor: _orange,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.navigation_rounded),
        label: const Text("Simuler mouvement"),
      ),
      body: Column(
        children: [
          // ── Carte placeholder ───────────────────────────────────────────────
          Expanded(
            child: Container(
              color: Colors.grey.shade200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_on_rounded,
                        size: 64, color: Colors.grey.shade400),
                    SizedBox(height: 16),
                    Text(
                      "Carte Google Maps",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Configuration API requise",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Timeline ─────────────────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Statut de livraison",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                _TimelineStep(
                  icon: Icons.inventory_2_rounded,
                  label: "Colis pris en charge",
                  completed: true,
                ),
                _TimelineStep(
                  icon: Icons.motorcycle_rounded,
                  label: "Livreur assigné",
                  completed: true,
                ),
                _TimelineStep(
                  icon: Icons.directions_car_rounded,
                  label: "En route",
                  completed: true,
                  active: true,
                ),
                _TimelineStep(
                  icon: Icons.check_circle_rounded,
                  label: "Livré",
                  completed: false,
                ),
              ],
            ),
          ),

          // ── Info livreur ─────────────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_rounded,
                      color: Colors.grey, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Kofi Mensah",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.phone_rounded,
                              size: 14, color: _darkGray),
                          const SizedBox(width: 4),
                          Text(
                            "+229 97 00 00 00",
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _lightOrange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "4.8 ★",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _orange,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Info destinataire ───────────────────────────────────────────────
          if (shipment.destinatairePrenom.isNotEmpty ||
              shipment.destinataireNom.isNotEmpty)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Row(
                children: [
                  const Icon(Icons.person_outline_rounded,
                      size: 18, color: _darkGray),
                  const SizedBox(width: 8),
                  Text(
                    "Destinataire: ${shipment.destinatairePrenom} ${shipment.destinataireNom}",
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.icon,
    required this.label,
    required this.completed,
    this.active = false,
  });
  final IconData icon;
  final String label;
  final bool completed;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? _orange : (completed ? _darkGray : Colors.grey.shade300);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontWeight: active ? FontWeight.w700 : FontWeight.w400,
              fontSize: 13,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
