// Écran d'accueil du livreur — Dashboard OZELSERVICES
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../features/shell/main_home_screen.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/formatters.dart';
import '../../../features/auth/domain/auth_provider.dart';
import '../../../features/commandes/domain/commandes_provider.dart';
import '../../../features/notifications/notifications_screen.dart';
import '../../../shared/models/commande.dart';
import '../../../shared/widgets/ozel_button.dart';
import '../../../shared/widgets/ozel_card.dart';
import '../domain/dashboard_provider.dart';

/// Écran principal du livreur avec toggle disponibilité et stats du jour
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estEnLigne = ref.watch(livreurStatusProvider);
    final dashboard = ref.watch(dashboardProvider);
    final authState = ref.watch(authProvider);
    final livreur = authState.livreur;
    final commandeActive = ref.watch(activeCommandeProvider);

    return Scaffold(
      backgroundColor: AppColors.kBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec salutation et cloche notifications
              Row(
                children: [
                  Expanded(child: _buildHeader(livreur?.prenom ?? 'Livreur', estEnLigne)),
                  // Cloche notifications
                  Consumer(
                    builder: (context, ref, _) {
                      final nonLues = ref.watch(notifsNonLuesProvider);
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications_outlined),
                            color: AppColors.kTextPrimary,
                            onPressed: () => context.push('/notifications'),
                          ),
                          if (nonLues > 0)
                            Positioned(
                              top: 4,
                              right: 4,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: const BoxDecoration(
                                  color: AppColors.kRed,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '$nonLues',
                                    style: const TextStyle(
                                      color: AppColors.kWhite,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Bannière commande active — priorité max si une livraison est en cours
              if (commandeActive != null) ...[
                _CommandeActiveBanner(commande: commandeActive),
                const SizedBox(height: 16),
              ],

              // Toggle disponibilité — élément central
              _buildToggleDisponibilite(context, ref, estEnLigne),
              const SizedBox(height: 20),
              // Stats du jour
              _buildStatsDuJour(dashboard),
              const SizedBox(height: 20),
              // Bouton voir commandes (masqué si hors ligne ou commande active)
              if (estEnLigne && commandeActive == null) ...[
                OzelButton(
                  label: AppStrings.voirCommandesDisponibles,
                  onPressed: () => allerOnglet(ref, 1),
                  icon: Icons.delivery_dining,
                ),
                const SizedBox(height: 16),
              ],
              // Informations rapides
              _buildInfoRapides(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String prenom, bool estEnLigne) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bonjour, $prenom 👋',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.kTextPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'OZELSERVICES Livreur',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.kTextSecondary,
              ),
            ),
          ],
        ),
        // Indicateur de statut
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: estEnLigne
                ? AppColors.kGreen.withValues(alpha: 0.15)
                : AppColors.kGrey.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: estEnLigne ? AppColors.kGreen : AppColors.kGrey,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                estEnLigne ? AppStrings.enLigne : AppStrings.horsLigne,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: estEnLigne ? AppColors.kGreen : AppColors.kGrey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToggleDisponibilite(
      BuildContext context, WidgetRef ref, bool estEnLigne) {
    return OzelCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  estEnLigne ? 'Vous êtes disponible' : 'Vous êtes indisponible',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.kTextPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  estEnLigne
                      ? 'Vous recevez des commandes'
                      : 'Activez pour recevoir des commandes',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.kTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Toggle ON/OFF bien visible
          Transform.scale(
            scale: 1.3,
            child: Switch(
              value: estEnLigne,
              onChanged: (_) {
                ref.read(livreurStatusProvider.notifier).toggleStatut();
              },
              activeThumbColor: AppColors.kPrimaryOrange,
              activeTrackColor: AppColors.kPrimaryOrange.withValues(alpha: 0.3),
              inactiveThumbColor: AppColors.kGrey,
              inactiveTrackColor: AppColors.kGreyLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsDuJour(DashboardState dashboard) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            titre: AppStrings.commandesDuJour,
            valeur: '${dashboard.commandesDuJour}',
            icone: Icons.check_circle_outline,
            couleur: AppColors.kBlue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            titre: AppStrings.gainsDuJour,
            valeur: Formatters.formatFcfa(dashboard.gainsDuJour),
            icone: Icons.account_balance_wallet_outlined,
            couleur: AppColors.kGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRapides() {
    return OzelCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rappels',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.kTextPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _InfoItem(
            icone: Icons.timer_outlined,
            texte: '30 secondes pour accepter une commande',
            couleur: AppColors.kYellow,
          ),
          const SizedBox(height: 8),
          _InfoItem(
            icone: Icons.lock_outline,
            texte: 'Code OTP obligatoire pour valider la livraison',
            couleur: AppColors.kPrimaryOrange,
          ),
          const SizedBox(height: 8),
          _InfoItem(
            icone: Icons.account_balance_wallet_outlined,
            texte: 'Gains crédités J+1 après livraison confirmée',
            couleur: AppColors.kGreen,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String titre;
  final String valeur;
  final IconData icone;
  final Color couleur;

  const _StatCard({
    required this.titre,
    required this.valeur,
    required this.icone,
    required this.couleur,
  });

  @override
  Widget build(BuildContext context) {
    return OzelCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: couleur.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icone, color: couleur, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            valeur,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.kTextPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            titre,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.kTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icone;
  final String texte;
  final Color couleur;

  const _InfoItem({
    required this.icone,
    required this.texte,
    required this.couleur,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icone, color: couleur, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            texte,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.kTextSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

/// Bannière affichée quand une commande est en cours de livraison
class _CommandeActiveBanner extends StatelessWidget {
  final Commande commande;

  const _CommandeActiveBanner({required this.commande});

  @override
  Widget build(BuildContext context) {
    final (label, icone, couleur) = _phaseInfo();

    return OzelCard(
      padding: const EdgeInsets.all(14),
      border: Border.all(color: couleur.withValues(alpha: 0.4), width: 1.5),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: couleur.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icone, color: couleur, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Livraison en cours',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: couleur,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.kTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () =>
                context.push('/home/commandes/${commande.id}'),
            style: TextButton.styleFrom(
              foregroundColor: couleur,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: const Text(
              'Reprendre →',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  (String, IconData, Color) _phaseInfo() {
    switch (commande.statut) {
      case StatutCommande.acceptee:
        return (
          'Rendez-vous au point de collecte',
          Icons.store_rounded,
          AppColors.kPrimaryOrange,
        );
      case StatutCommande.auPickup:
        return (
          'Collectez la commande au pickup',
          Icons.store_rounded,
          AppColors.kYellow,
        );
      case StatutCommande.enRoute:
        return (
          'En route vers le client',
          Icons.delivery_dining_rounded,
          AppColors.kBlue,
        );
      default:
        return (
          'Commande active',
          Icons.delivery_dining_rounded,
          AppColors.kPrimaryOrange,
        );
    }
  }
}
