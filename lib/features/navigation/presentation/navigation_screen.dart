// Écran navigation GPS — carte mockée en attendant clé API Google Maps
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/commande.dart';
import '../../../shared/widgets/ozel_button.dart';
import '../../commandes/domain/commandes_provider.dart';
import '../domain/navigation_provider.dart';

/// Écran de navigation GPS avec carte mockée et gestion des phases pickup/livraison.
class NavigationScreen extends ConsumerWidget {
  final String commandeId;
  const NavigationScreen({super.key, required this.commandeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commande = ref.watch(activeCommandeProvider);
    final navState = ref.watch(navigationProvider(commandeId));

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

    final cible = adresseCible(navState, commande);
    final versPickup = navState.phase == PhaseNavigation.versPickup;
    final couleurPhase =
        versPickup ? AppColors.kPrimaryOrange : AppColors.kRed;
    final labelPhase = versPickup ? 'Vers le pickup' : 'Vers la livraison';

    return Scaffold(
      backgroundColor: AppColors.kBackground,
      appBar: AppBar(
        title: Text(labelPhase),
        backgroundColor: couleurPhase,
        foregroundColor: AppColors.kWhite,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          // Bouton appel client
          IconButton(
            icon: const Icon(Icons.phone),
            tooltip: 'Appeler le client',
            onPressed: () async {
              final uri = Uri.parse('tel:${commande.clientTelephone}');
              if (await canLaunchUrl(uri)) await launchUrl(uri);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Indicateur de phase ─────────────────────────────────────────
          _PhaseIndicateur(
            commande: commande,
            phase: navState.phase,
          ),
          // ── Carte mockée ────────────────────────────────────────────────
          Expanded(
            child: _CarteMockee(
              commande: commande,
              phase: navState.phase,
            ),
          ),
          // ── Panneau infos + actions ──────────────────────────────────────
          _PanneauInferieur(
            commande: commande,
            navState: navState,
            cible: cible,
            commandeId: commandeId,
          ),
        ],
      ),
    );
  }
}

// ── Indicateur de phase pickup / livraison ─────────────────────────────────

class _PhaseIndicateur extends StatelessWidget {
  final Commande commande;
  final PhaseNavigation phase;

  const _PhaseIndicateur({required this.commande, required this.phase});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.kWhite,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _PhaseBullet(
            label: 'Pickup',
            sublabel: _truncate(commande.adressePickup.libelle),
            icone: Icons.store_rounded,
            couleur: AppColors.kPrimaryOrange,
            actif: phase == PhaseNavigation.versPickup,
            fait: phase != PhaseNavigation.versPickup,
          ),
          Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: phase == PhaseNavigation.versPickup
                      ? [AppColors.kGreyLight, AppColors.kGreyLight]
                      : [AppColors.kPrimaryOrange, AppColors.kRed],
                ),
              ),
            ),
          ),
          _PhaseBullet(
            label: 'Livraison',
            sublabel: _truncate(commande.adresseLivraison.libelle),
            icone: Icons.location_on_rounded,
            couleur: AppColors.kRed,
            actif: phase == PhaseNavigation.versLivraison,
            fait: phase == PhaseNavigation.terminee,
          ),
        ],
      ),
    );
  }

  String _truncate(String s) =>
      s.length > 25 ? '${s.substring(0, 22)}...' : s;
}

class _PhaseBullet extends StatelessWidget {
  final String label;
  final String sublabel;
  final IconData icone;
  final Color couleur;
  final bool actif;
  final bool fait;

  const _PhaseBullet({
    required this.label,
    required this.sublabel,
    required this.icone,
    required this.couleur,
    required this.actif,
    required this.fait,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveCouleur =
        actif ? couleur : (fait ? couleur : AppColors.kGrey);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: (actif || fait)
                ? effectiveCouleur
                : AppColors.kGreyLight,
            shape: BoxShape.circle,
          ),
          child: Icon(
            fait ? Icons.check : icone,
            color: (actif || fait) ? AppColors.kWhite : AppColors.kGrey,
            size: 18,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: actif ? FontWeight.bold : FontWeight.normal,
            color: effectiveCouleur,
          ),
        ),
        SizedBox(
          width: 100,
          child: Text(
            sublabel,
            style: const TextStyle(fontSize: 9, color: AppColors.kTextSecondary),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ── Carte mockée ─────────────────────────────────────────────────────────────

class _CarteMockee extends StatelessWidget {
  final Commande commande;
  final PhaseNavigation phase;

  const _CarteMockee({required this.commande, required this.phase});

  @override
  Widget build(BuildContext context) {
    final versPickup = phase == PhaseNavigation.versPickup;

    return Container(
      color: const Color(0xFFE8F0FE),
      child: Stack(
        children: [
          // Grille de rues
          CustomPaint(painter: _GridPainter(), child: const SizedBox.expand()),
          // Icône livreur central
          Center(
            child: _LivreurIcon(couleur: AppColors.kPrimaryOrange),
          ),
          // Marqueur pickup
          if (versPickup)
            Positioned(
              top: 60,
              left: 48,
              child: _MapMarker(
                label: 'Pickup',
                color: AppColors.kPrimaryOrange,
                icon: Icons.store_rounded,
                pulse: true,
              ),
            ),
          // Marqueur livraison
          Positioned(
            bottom: 70,
            right: 48,
            child: _MapMarker(
              label: 'Livraison',
              color: AppColors.kRed,
              icon: Icons.location_on_rounded,
              pulse: !versPickup,
            ),
          ),
          // Badge GPS actif
          Positioned(
            top: 12,
            right: 12,
            child: _GpsBadge(),
          ),
          // Infos distance / temps
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.kWhite,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.route_rounded,
                      color: AppColors.kPrimaryOrange, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${Formatters.formatDistance(commande.distanceKm)} '
                    '· ${Formatters.formatDuree(commande.tempsEstimeMinutes)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.kTextPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Note carte mock
          Positioned(
            bottom: 8,
            left: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Carte GPS disponible après configuration de la clé Google Maps',
                style: TextStyle(color: Colors.white70, fontSize: 10),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LivreurIcon extends StatelessWidget {
  final Color couleur;
  const _LivreurIcon({required this.couleur});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: couleur,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: couleur.withValues(alpha: 0.4),
                blurRadius: 20,
                spreadRadius: 4,
              ),
            ],
          ),
          child: const Icon(
            Icons.delivery_dining_rounded,
            color: AppColors.kWhite,
            size: 30,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.kWhite,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 6,
              ),
            ],
          ),
          child: Text(
            'Vous êtes ici',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 11,
              color: couleur,
            ),
          ),
        ),
      ],
    );
  }
}

class _MapMarker extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final bool pulse;

  const _MapMarker({
    required this.label,
    required this.color,
    required this.icon,
    this.pulse = false,
  });

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
            boxShadow: pulse
                ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 12, spreadRadius: 3)]
                : [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 6)],
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(height: 3),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
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
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class _GpsBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.kWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: AppColors.kGreen,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
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
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFCCDDFF)
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

// ── Panneau inférieur avec itinéraire + actions ───────────────────────────

class _PanneauInferieur extends ConsumerWidget {
  final Commande commande;
  final NavigationState navState;
  final Adresse? cible;
  final String commandeId;

  const _PanneauInferieur({
    required this.commande,
    required this.navState,
    required this.cible,
    required this.commandeId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final versPickup = navState.phase == PhaseNavigation.versPickup;
    final couleurPhase =
        versPickup ? AppColors.kPrimaryOrange : AppColors.kRed;

    return Container(
      color: AppColors.kWhite,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Adresse cible
          if (cible != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  versPickup ? Icons.store_rounded : Icons.location_on_rounded,
                  color: couleurPhase,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        versPickup ? 'Point de collecte' : 'Adresse de livraison',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.kTextSecondary,
                        ),
                      ),
                      Text(
                        cible!.libelle,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.kTextPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          // Bouton navigation externe
          OzelButton(
            label: 'Ouvrir dans Maps',
            onPressed: cible != null
                ? () => _lancerMapsExterne(cible!)
                : null,
            variant: OzelButtonVariant.secondary,
            icon: Icons.open_in_new,
            height: 44,
          ),
          const SizedBox(height: 10),
          // Bouton progression
          if (versPickup)
            OzelButton(
              label: 'J\'ai récupéré la commande',
              onPressed: () {
                ref
                    .read(navigationProvider(commandeId).notifier)
                    .passerVersLivraison();
                // Mettre aussi à jour le statut global de la commande
                ref
                    .read(commandesProvider.notifier)
                    .updateStatut(commande.id, StatutCommande.enRoute);
              },
              icon: Icons.check_circle_outline,
              height: 48,
            )
          else
            OzelButton(
              label: 'Confirmer la livraison (OTP)',
              onPressed: () {
                context.push('/home/commandes/${commande.id}/confirmation');
              },
              icon: Icons.lock_open,
              height: 48,
            ),
        ],
      ),
    );
  }

  Future<void> _lancerMapsExterne(Adresse adresse) async {
    // iOS : maps://?daddr=lat,lng
    // Android : google.navigation:q=lat,lng&mode=d
    final uriAndroid = Uri.parse(
      'google.navigation:q=${adresse.latitude},${adresse.longitude}&mode=d',
    );
    final uriIos = Uri.parse(
      'maps://?daddr=${adresse.latitude},${adresse.longitude}',
    );
    final uriFallback = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${adresse.latitude},${adresse.longitude}&travelmode=driving',
    );

    if (await canLaunchUrl(uriAndroid)) {
      await launchUrl(uriAndroid);
    } else if (await canLaunchUrl(uriIos)) {
      await launchUrl(uriIos);
    } else {
      await launchUrl(uriFallback, mode: LaunchMode.externalApplication);
    }
  }
}
