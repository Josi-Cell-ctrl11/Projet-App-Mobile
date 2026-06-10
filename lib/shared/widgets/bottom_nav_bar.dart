// Barre de navigation inférieure OZELSERVICES Livreur
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

/// Index des onglets de la navigation principale
enum NavTab { accueil, commandes, gains, profil }

/// Barre de navigation inférieure avec 4 onglets et badge sur Commandes
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
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.kWhite,
        selectedItemColor: AppColors.kPrimaryOrange,
        unselectedItemColor: AppColors.kGrey,
        selectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.normal,
        ),
        elevation: 0,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: AppStrings.tableauDeBord,
          ),
          BottomNavigationBarItem(
            icon: _CommandesIcon(hasBadge: hasActiveCommande, isActive: false),
            activeIcon:
                _CommandesIcon(hasBadge: hasActiveCommande, isActive: true),
            label: AppStrings.commandes,
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: AppStrings.gains,
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: AppStrings.profil,
          ),
        ],
      ),
    );
  }
}

/// Icône Commandes avec badge de notification optionnel
class _CommandesIcon extends StatelessWidget {
  final bool hasBadge;
  final bool isActive;

  const _CommandesIcon({required this.hasBadge, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(
          isActive ? Icons.inventory_2 : Icons.inventory_2_outlined,
        ),
        if (hasBadge)
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
    );
  }
}
