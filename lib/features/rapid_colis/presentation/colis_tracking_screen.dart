import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";

import "../../../core/theme/app_colors.dart";
import "../../../core/utils/formatters.dart";
import "../application/active_colis_notifier.dart";

/// Suivi livraison GPS (position livreur mise à jour manuellement — MVP stable).
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

    final lat = shipment.driverLat ?? 6.3725;
    final lng = shipment.driverLng ?? 2.3544;
    final target = LatLng(lat, lng);

    return Scaffold(
      appBar: AppBar(title: const Text("Suivi livraison")),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final s = ref.read(activeColisProvider);
          if (s == null) return;
          final lat = s.driverLat ?? 6.3725;
          final lng = s.driverLng ?? 2.3544;
          ref.read(activeColisProvider.notifier).setShipment(
                s.copyWith(
                  driverLat: lat + 0.0012,
                  driverLng: lng + 0.0008,
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
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(target: target, zoom: 14),
              markers: {
                Marker(
                  markerId: const MarkerId("driver"),
                  position: target,
                  infoWindow: const InfoWindow(title: "Livreur Rapid Colis"),
                ),
              },
              liteModeEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
            ),
          ),
          Container(
            width: double.infinity,
            color: AppColors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${shipment.pointA} → ${shipment.pointB}",
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  "Montant : ${Formatters.fcfa(shipment.priceFcfa)}",
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Appuie sur « Simuler mouvement » pour déplacer le livreur sur la carte (MVP).",
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
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
