// Ecran navigation GPS — carte mockee en attendant cle API Google Maps
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../commandes/domain/commandes_provider.dart';

/// Ecran de navigation GPS avec carte mockee.
class NavigationScreen extends ConsumerWidget {
  final String commandeId;
  const NavigationScreen({super.key, required this.commandeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commande = ref.watch(activeCommandeProvider);

    if (commande == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Navigation'),
          backgroundColor: AppColors.kPrimaryOrange,
          foregroundColor: AppColors.kWhite,
        ),
        body: const Center(child: Text('Commande introuvable')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigation GPS'),
        backgroundColor: AppColors.kPrimaryOrange,
        foregroundColor: AppColors.kWhite,
        actions: [
          IconButton(
            icon: const Icon(Icons.phone),
            tooltip: AppStrings.appelerClient,
            onPressed: () async {
              final uri = Uri.parse('tel:${commande.clientTelephone}');
              if (await canLaunchUrl(uri)) await launchUrl(uri);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Carte mockee ─────────────────────────────────────────────────
          Expanded(
            child: Container(
              color: const Color(0xFFE8F0FE),
              child: Stack(
                children: [
                  // Grille de rues mockee
                  CustomPaint(
                    painter: _GridPainter(),
                    child: const SizedBox.expand(),
                  ),
                  // Icone livreur au centre
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.kPrimaryOrange,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.kPrimaryOrange
                                    .withValues(alpha: 0.4),
                                blurRadius: 20,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.delivery_dining_rounded,
                            color: AppColors.kWhite,
                            size: 36,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.kWhite,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Text(
                            'Vous etes ici',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: AppColors.kPrimaryOrange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Marqueur pickup
                  Positioned(
                    top: 60,
                    left: 40,
                    child: _MapMarker(
                      label: 'Pickup',
                      color: AppColors.kPrimaryOrange,
                      icon: Icons.store_rounded,
                    ),
                  ),
                  // Marqueur livraison
                  Positioned(
                    bottom: 80,
                    right: 40,
                    child: _MapMarker(
                      label: 'Livraison',
                      color: Colors.red,
                      icon: Icons.location_on_rounded,
                    ),
                  ),
                  // Badge GPS
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.kWhite,
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
                              color: AppColors.kGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'GPS actif',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.kGreen,
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
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Carte GPS disponible apres configuration de la cle Google Maps',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Infos trajet ──────────────────────────────────────────────────
          Container(
            color: AppColors.kWhite,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.store_rounded,
                        color: AppColors.kPrimaryOrange, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        commande.adressePickup.libelle,
                        style: const TextStyle(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded,
                        color: Colors.red, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        commande.adresseLivraison.libelle,
                        style: const TextStyle(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.route_rounded,
                        color: AppColors.kTextSecondary, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      '${commande.distanceKm.toStringAsFixed(1)} km  •  '
                      '${commande.tempsEstimeMinutes} min',
                      style: const TextStyle(
                        color: AppColors.kTextSecondary,
                        fontSize: 12,
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

class _MapMarker extends StatelessWidget {
  const _MapMarker({
    required this.label,
    required this.color,
    required this.icon,
  });
  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 8,
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
              ),
            ],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
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
