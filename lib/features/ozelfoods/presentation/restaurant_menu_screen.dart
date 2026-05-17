import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../../../core/theme/app_colors.dart";
import "../../../shared/widgets/price_tag.dart";
import "../../../shared/models/restaurant_model.dart";
import "../application/cart_notifier.dart";
import "../application/restaurant_providers.dart";

/// Menu d’un restaurant : liste des plats + ajout au panier.
class RestaurantMenuScreen extends ConsumerWidget {
  const RestaurantMenuScreen({super.key, required this.restaurantId});

  final String restaurantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          restaurant = list.firstWhere((r) => r.id == restaurantId);
        } catch (_) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text("Restaurant introuvable.")),
          );
        }
        return Scaffold(
          appBar: AppBar(title: Text(restaurant.name)),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => context.push("/ozelfoods/panier"),
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            icon: const Icon(Icons.shopping_cart_checkout_rounded),
            label: const Text("Panier"),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              Text(
                "Livraison estimée : ${restaurant.deliveryMinutes} min",
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              ...restaurant.menu.map((item) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            width: 86,
                            height: 86,
                            child: item.imageUrl.isEmpty
                                ? Container(
                                    color: AppColors.surface,
                                    child: const Icon(Icons.fastfood,
                                        color: AppColors.primary),
                                  )
                                : Image.network(
                                    item.imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: AppColors.surface,
                                      child: const Icon(Icons.broken_image),
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
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.description,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  PriceTag(item.priceFcfa),
                                  const Spacer(),
                                  FilledButton(
                                    onPressed: () {
                                      ref.read(cartProvider.notifier).addItem(
                                            item: item,
                                            restaurant: restaurant,
                                          );
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text("${item.name} ajouté"),
                                        ),
                                      );
                                    },
                                    style: FilledButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: AppColors.white,
                                    ),
                                    child: const Text("Ajouter"),
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
              }),
            ],
          ),
        );
      },
    );
  }
}
