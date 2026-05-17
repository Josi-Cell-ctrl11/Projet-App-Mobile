// Écran de navigation GPS vers le client
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/commande.dart';
import '../../../shared/widgets/ozel_button.dart';
import '../../commandes/domain/commandes_provider.dart';

/// Écran de navigation GPS avec carte Google Maps
class NavigationScreen extends ConsumerStatefulWidget {
  final String commandeId;
  const NavigationScreen({super.key, required this.commandeId});

  @override
  ConsumerState<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends ConsumerState<NavigationScreen> {
  GoogleMapController? _mapController;

  // Position mockée du livreur (Cotonou centre)
  static const LatLng _positionLivreur = LatLng(6.3654, 2.4183);

  @override
  Widget build(BuildContext context) {
    final commande = ref.watch(activeCommandeProvider);

    if (commande == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Navigation')),
        body: const Center(child: Text('Commande introuvable')),
      );
    }

    final markers = _buildMarkers(commande);
    // _getDestination utilisé dans _InfoPanel via commande.statut directement

    return Scaffold(
      body: Stack(
        children: [
          // Carte Google Maps
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _positionLivreur,
              zoom: 14,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
              // Centrer sur la position du livreur
              _mapController?.animateCamera(
                CameraUpdate.newLatLngBounds(
                  _getBounds(commande),
                  80,
                ),
              );
            },
            markers: markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),
              // Bouton retour
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            child: CircleAvatar(
              backgroundColor: AppColors.kWhite,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.kTextPrimary),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          // Panneau d'infos en bas
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _InfoPanel(
              commande: commande,
              onAppelerClient: () => _appelerClient(commande.clientTelephone),
            ),
          ),
        ],
      ),
    );
  }

  LatLng _getDestination(Commande commande) {
    // Naviguer vers pickup si pas encore au pickup, sinon vers livraison
    if (commande.statut == StatutCommande.acceptee) {
      return LatLng(
        commande.adressePickup.latitude,
        commande.adressePickup.longitude,
      );
    }
    return LatLng(
      commande.adresseLivraison.latitude,
      commande.adresseLivraison.longitude,
    );
  }

  Set<Marker> _buildMarkers(Commande commande) {
    return {
      // Position du livreur
      Marker(
        markerId: const MarkerId('livreur'),
        position: _positionLivreur,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: const InfoWindow(title: 'Votre position'),
      ),
      // Point de pickup
      Marker(
        markerId: const MarkerId('pickup'),
        position: LatLng(
          commande.adressePickup.latitude,
          commande.adressePickup.longitude,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: 'Pickup',
          snippet: commande.adressePickup.libelle,
        ),
      ),
      // Point de livraison
      Marker(
        markerId: const MarkerId('livraison'),
        position: LatLng(
          commande.adresseLivraison.latitude,
          commande.adresseLivraison.longitude,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: 'Livraison',
          snippet: commande.adresseLivraison.libelle,
        ),
      ),
    };
  }

  LatLngBounds _getBounds(Commande commande) {
    final points = [
      _positionLivreur,
      LatLng(commande.adressePickup.latitude, commande.adressePickup.longitude),
      LatLng(commande.adresseLivraison.latitude, commande.adresseLivraison.longitude),
    ];

    double minLat = points.map((p) => p.latitude).reduce((a, b) => a < b ? a : b);
    double maxLat = points.map((p) => p.latitude).reduce((a, b) => a > b ? a : b);
    double minLng = points.map((p) => p.longitude).reduce((a, b) => a < b ? a : b);
    double maxLng = points.map((p) => p.longitude).reduce((a, b) => a > b ? a : b);

    return LatLngBounds(
      southwest: LatLng(minLat - 0.005, minLng - 0.005),
      northeast: LatLng(maxLat + 0.005, maxLng + 0.005),
    );
  }

  Future<void> _appelerClient(String telephone) async {
    final uri = Uri.parse('tel:$telephone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

/// Panneau d'informations en bas de la carte
class _InfoPanel extends StatelessWidget {
  final Commande commande;
  final VoidCallback onAppelerClient;

  const _InfoPanel({
    required this.commande,
    required this.onAppelerClient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.kWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Indicateur de glissement
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.kGreyLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          // Destination actuelle
          Row(
            children: [
              const Icon(Icons.navigation, color: AppColors.kPrimaryOrange),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      commande.statut == StatutCommande.acceptee
                          ? 'Direction : Pickup'
                          : 'Direction : Livraison',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.kTextSecondary,
                      ),
                    ),
                    Text(
                      commande.statut == StatutCommande.acceptee
                          ? commande.adressePickup.libelle
                          : commande.adresseLivraison.libelle,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Distance et temps
          Row(
            children: [
              _InfoChip(
                icone: Icons.route,
                valeur: Formatters.formatDistance(commande.distanceKm),
              ),
              const SizedBox(width: 8),
              _InfoChip(
                icone: Icons.access_time,
                valeur: Formatters.formatDuree(commande.tempsEstimeMinutes),
              ),
              const Spacer(),
              // Bouton appel client
              OzelButton(
                label: AppStrings.appelerClient,
                onPressed: onAppelerClient,
                variant: OzelButtonVariant.secondary,
                icon: Icons.phone,
                width: 160,
                height: 40,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icone;
  final String valeur;

  const _InfoChip({required this.icone, required this.valeur});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.kGreyLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 14, color: AppColors.kTextSecondary),
          const SizedBox(width: 4),
          Text(
            valeur,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.kTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
