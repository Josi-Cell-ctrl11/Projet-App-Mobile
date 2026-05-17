// Widget carte de commande avec timer intégré
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/commande.dart';
import '../../../shared/widgets/ozel_button.dart';
import '../../../shared/widgets/ozel_card.dart';
import '../domain/timer_service.dart';

/// Carte d'une commande disponible avec timer de 30 secondes
class CommandeCard extends ConsumerWidget {
  final Commande commande;
  final VoidCallback onAccepter;
  final VoidCallback onRefuser;

  const CommandeCard({
    super.key,
    required this.commande,
    required this.onAccepter,
    required this.onRefuser,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerProvider(commande.id));
    final secondes = timerState.secondesRestantes;
    final estExpire = timerState.estExpire;

    // Couleur du timer selon urgence
    Color timerColor = AppColors.kGreen;
    if (secondes <= 10) timerColor = AppColors.kRed;
    else if (secondes <= 20) timerColor = AppColors.kYellow;

    return OzelCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête : type + timer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _TypeBadge(type: commande.type),
              // Timer compte à rebours
              if (!estExpire)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: timerColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: timerColor.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.timer, color: timerColor, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${secondes}s',
                        style: TextStyle(
                          color: timerColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.kRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Expiré',
                    style: TextStyle(color: AppColors.kRed, fontSize: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Adresses
          _AdresseRow(
            icone: Icons.store,
            couleur: AppColors.kPrimaryOrange,
            libelle: commande.adressePickup.libelle,
            label: 'Pickup',
          ),
          const SizedBox(height: 6),
          _AdresseRow(
            icone: Icons.location_on,
            couleur: AppColors.kRed,
            libelle: commande.adresseLivraison.libelle,
            label: 'Livraison',
          ),
          const SizedBox(height: 12),
          // Stats : distance, temps, gain
          Row(
            children: [
              _StatChip(
                icone: Icons.route,
                valeur: Formatters.formatDistance(commande.distanceKm),
              ),
              const SizedBox(width: 8),
              _StatChip(
                icone: Icons.access_time,
                valeur: Formatters.formatDuree(commande.tempsEstimeMinutes),
              ),
              const SizedBox(width: 8),
              _StatChip(
                icone: Icons.account_balance_wallet,
                valeur: Formatters.formatFcfa(commande.partLivreur),
                couleur: AppColors.kGreen,
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Boutons Accepter / Refuser
          if (!estExpire)
            Row(
              children: [
                Expanded(
                  child: OzelButton(
                    label: AppStrings.refuser,
                    onPressed: onRefuser,
                    variant: OzelButtonVariant.secondary,
                    height: 44,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: OzelButton(
                    label: AppStrings.accepter,
                    onPressed: onAccepter,
                    height: 44,
                    icon: Icons.check,
                  ),
                ),
              ],
            )
          else
            const Center(
              child: Text(
                'Commande expirée',
                style: TextStyle(color: AppColors.kGrey, fontSize: 13),
              ),
            ),
        ],
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final TypeCommande type;
  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final isFood = type == TypeCommande.ozelFoods;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isFood
            ? AppColors.kPrimaryOrange.withValues(alpha: 0.15)
            : AppColors.kBlue.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isFood ? Icons.restaurant : Icons.inventory_2,
            size: 14,
            color: isFood ? AppColors.kPrimaryOrange : AppColors.kBlue,
          ),
          const SizedBox(width: 4),
          Text(
            isFood ? AppStrings.ozelFoods : AppStrings.rapidColis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isFood ? AppColors.kPrimaryOrange : AppColors.kBlue,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdresseRow extends StatelessWidget {
  final IconData icone;
  final Color couleur;
  final String libelle;
  final String label;

  const _AdresseRow({
    required this.icone,
    required this.couleur,
    required this.libelle,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icone, color: couleur, size: 16),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.kTextSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                libelle,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.kTextPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icone;
  final String valeur;
  final Color couleur;

  const _StatChip({
    required this.icone,
    required this.valeur,
    this.couleur = AppColors.kTextSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.kGreyLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 12, color: couleur),
          const SizedBox(width: 4),
          Text(
            valeur,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: couleur,
            ),
          ),
        ],
      ),
    );
  }
}
