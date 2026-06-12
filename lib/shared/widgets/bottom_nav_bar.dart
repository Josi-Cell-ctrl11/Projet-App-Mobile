// Barre de navigation inférieure OZELSERVICES Livreur
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

/// Barre de navigation inférieure avec 4 onglets et badge sur Commandes.
class OzelBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  /// Affiche un badge sur l'onglet Commandes si true
  final bool hasActiveCommande;

  const OzelBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.hasActiveCommande = false,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.kWhite,
        boxShadow: [
          BoxShadow(
            color: AppColors.kBlack.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _NavItem(
                index: 0,
                currentIndex: currentIndex,
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: AppStrings.tableauDeBord,
                onTap: onTap,
              ),
              _NavItem(
                index: 1,
                currentIndex: currentIndex,
                icon: Icons.inventory_2_outlined,
                activeIcon: Icons.inventory_2,
                label: AppStrings.commandes,
                onTap: onTap,
                showBadge: hasActiveCommande,
              ),
              _NavItem(
                index: 2,
                currentIndex: currentIndex,
                icon: Icons.account_balance_wallet_outlined,
                activeIcon: Icons.account_balance_wallet,
                label: AppStrings.gains,
                onTap: onTap,
              ),
              _NavItem(
                index: 3,
                currentIndex: currentIndex,
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: AppStrings.profil,
                onTap: onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.index,
    required this.currentIndex,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.onTap,
    this.showBadge = false,
  });

  final int index;
  final int currentIndex;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final ValueChanged<int> onTap;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    final isActive = index == currentIndex;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isActive ? activeIcon : icon,
                  size: 24,
                  color: isActive ? AppColors.kPrimaryOrange : AppColors.kGrey,
                ),
                if (showBadge)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppColors.kRed,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive ? AppColors.kPrimaryOrange : AppColors.kGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
