import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../../../core/constants/app_constants.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/utils/formatters.dart";
import "../../../shared/models/restaurant_model.dart";
import "../../../shared/widgets/price_tag.dart";
import "../application/cart_notifier.dart";
import "../application/restaurant_providers.dart";

/// Menu d'un restaurant : specialite + menu du jour (max 3 plats) + timer validation.
class RestaurantMenuScreen extends ConsumerStatefulWidget {
  const RestaurantMenuScreen({super.key, required this.restaurantId});

  final String restaurantId;

  @override
  ConsumerState<RestaurantMenuScreen> createState() =>
      _RestaurantMenuScreenState();
}

class _RestaurantMenuScreenState
    extends ConsumerState<RestaurantMenuScreen> {
  // Timer de validation restaurant : 3 minutes (180s) apres commande
  Timer? _validationTimer;
  int _timerSeconds = 0;
  bool _timerRunning = false;

  @override
  void dispose() {
    _validationTimer?.cancel();
    super.dispose();
  }

  void _startValidationTimer() {
    setState(() {
      _timerSeconds = AppConstants.restaurantAcceptanceMinutes * 60;
      _timerRunning = true;
    });
    _validationTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _timerSeconds--);
      if (_timerSeconds <= 0) {
        t.cancel();
        setState(() => _timerRunning = false);
        _showAutoCancel();
      }
    });
  }

  void _showAutoCancel() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("Commande annulee"),
        content: const Text(
          "Le restaurant n'a pas repondu dans le delai imparti. "
          "Votre commande a ete annulee automatiquement.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go("/ozelfoods");
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  String get _timerDisplay {
    final m = _timerSeconds ~/ 60;
    final s = _timerSeconds % 60;
    return "${m.toString().padLeft(2, "0")}:${s.toString().padLeft(2, "0")}";
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(restaurantsProvider);
    return async.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text("Erreur : $e")),
      ),
      data: (list) {
        RestaurantModel restaurant;
        try {
          restaurant = list.firstWhere((r) => r.id == widget.restaurantId);
        } catch (_) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text("Restaurant introuvable.")),
          );
        }

        final menuDuJour = restaurant.menuDuJour;
        final cartCount = ref.watch(cartProvider).length;

        return Scaffold(
          backgroundColor: AppColors.surface,
          body: CustomScrollView(
            slivers: [
              // ── Header avec photo + infos ──────────────────────────────────
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: AppColors.white,
                surfaceTintColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      restaurant.imageUrl.isEmpty
                          ? Container(color: AppColors.surface)
                          : Image.network(
                              restaurant.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  Container(color: AppColors.surface),
                            ),
                      // Gradient
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                      ),
                      // Badge ferme
                      if (!restaurant.isOpen)
                        Positioned.fill(
                          child: Container(
                            color: Colors.black.withValues(alpha: 0.5),
                            child: const Center(
                              child: Text(
                                "FERME",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 4,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                title: Text(
                  restaurant.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.black,
                  ),
                ),
                actions: [
                  if (cartCount > 0)
                    Stack(
                      children: [
                        IconButton(
                          onPressed: () =>
                              context.push("/ozelfoods/panier"),
                          icon: const Icon(
                            Icons.shopping_cart_rounded,
                            color: AppColors.primary,
                          ),
                        ),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                "$cartCount",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),

              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Infos restaurant ──────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Specialite en evidence
                          if (restaurant.specialite.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Specialite : ${restaurant.specialite}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded,
                                  size: 16, color: Colors.amber),
                              Text(
                                " ${restaurant.rating}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(width: 16),
                              const Icon(Icons.schedule_rounded,
                                  size: 16,
                                  color: AppColors.textSecondary),
                              Text(
                                " ${restaurant.deliveryMinutes} min",
                                style: const TextStyle(
                                    color: AppColors.textSecondary),
                              ),
                              const SizedBox(width: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: restaurant.isOpen
                                      ? AppColors.success
                                          .withValues(alpha: 0.1)
                                      : AppColors.disabled
                                          .withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  restaurant.isOpen ? "Ouvert" : "Ferme",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: restaurant.isOpen
                                        ? AppColors.success
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // ── Timer validation (si actif) ───────────────────────────
                    if (_timerRunning)
                      Container(
                        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color:
                                  AppColors.warning.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.timer_rounded,
                                color: AppColors.warning, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "En attente de confirmation restaurant",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      color: AppColors.warning,
                                    ),
                                  ),
                                  Text(
                                    "Annulation auto dans $_timerDisplay",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.warning,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    // ── Info paiement ─────────────────────────────────────────
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color:
                                AppColors.primary.withValues(alpha: 0.2)),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline_rounded,
                              color: AppColors.primary, size: 16),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Le cout du repas est paye a l'avance. "
                              "Les frais de livraison sont regles a la remise.",
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Menu du jour ──────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                      child: Row(
                        children: [
                          const Text(
                            "Menu du jour",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.black,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primary
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              "${menuDuJour.length}/3 plats",
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Liste des plats du menu du jour ───────────────────────────
              menuDuJour.isEmpty
                  ? const SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.no_meals_rounded,
                                size: 48, color: AppColors.disabled),
                            SizedBox(height: 12),
                            Text(
                              "Pas de menu du jour disponible",
                              style: TextStyle(
                                  color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding:
                          const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, i) => _MenuItemCard(
                            item: menuDuJour[i],
                            restaurant: restaurant,
                            isDisabled: !restaurant.isOpen,
                          ),
                          childCount: menuDuJour.length,
                        ),
                      ),
                    ),
            ],
          ),
          // ── FAB panier ────────────────────────────────────────────────────
          floatingActionButton: cartCount > 0
              ? FloatingActionButton.extended(
                  onPressed: () => context.push("/ozelfoods/panier"),
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  icon: const Icon(Icons.shopping_cart_checkout_rounded),
                  label: Text("Panier ($cartCount)"),
                )
              : null,
        );
      },
    );
  }
}

// ─── Menu Item Card ───────────────────────────────────────────────────────────
class _MenuItemCard extends ConsumerWidget {
  const _MenuItemCard({
    required this.item,
    required this.restaurant,
    this.isDisabled = false,
  });

  final MenuItemModel item;
  final RestaurantModel restaurant;
  final bool isDisabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo plat
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 90,
                height: 90,
                child: item.imageUrl.isEmpty
                    ? Container(
                        color: AppColors.surface,
                        child: const Icon(Icons.fastfood_rounded,
                            color: AppColors.primary),
                      )
                    : Image.network(
                        item.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.surface,
                          child: const Icon(Icons.fastfood_rounded,
                              color: AppColors.primary),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      PriceTag(item.priceFcfa),
                      const Spacer(),
                      if (!isDisabled)
                        FilledButton(
                          onPressed: () {
                            ref.read(cartProvider.notifier).addItem(
                                  item: item,
                                  restaurant: restaurant,
                                );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("${item.name} ajoute au panier"),
                                backgroundColor: AppColors.success,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            "Ajouter",
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            "Indisponible",
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
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
      ),
    );
  }
}
