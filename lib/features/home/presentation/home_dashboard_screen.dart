import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../../../core/theme/app_colors.dart";
import "../../../core/utils/formatters.dart";
import "../../../shared/models/food_order.dart";
import "../../../shared/models/food_order_status.dart";
import "../../../shared/models/service_tile_model.dart";
import "../../../shared/widgets/section_title.dart";
import "../../auth/application/auth_session.dart";
import "../../ozelfoods/application/food_orders_notifier.dart";

// ─── Données promo carousel ───────────────────────────────────────────────────
class _PromoSlide {
  const _PromoSlide({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    this.routePath,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final String? routePath;
}

const _promoSlides = [
  _PromoSlide(
    title: "Livraison rapide",
    subtitle: "OzelFoods — Commande min. 1 500 FCFA\nDélai standard 45 min",
    icon: Icons.restaurant_menu_rounded,
    gradient: [Color(0xFFFF6B35), Color(0xFFE85A28)],
    routePath: "/ozelfoods",
  ),
  _PromoSlide(
    title: "Rapid Colis",
    subtitle: "Envoi dès 1 000 FCFA\nSuivi GPS en temps réel",
    icon: Icons.local_shipping_rounded,
    gradient: [Color(0xFF1565C0), Color(0xFF0D47A1)],
    routePath: "/rapid-colis",
  ),
  _PromoSlide(
    title: "OzelWallet",
    subtitle: "Payez MoMo, Moov, Visa\n1 FCFA dépensé = 1 point Ozel",
    icon: Icons.account_balance_wallet_rounded,
    gradient: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
    routePath: "/wallet",
  ),
];

/// Tableau de bord principal — style Glovo/Jumia Food.
class HomeDashboardScreen extends ConsumerStatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  ConsumerState<HomeDashboardScreen> createState() =>
      _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends ConsumerState<HomeDashboardScreen> {
  final PageController _promoCtrl = PageController(viewportFraction: 0.92);
  int _promoIndex = 0;
  Timer? _promoTimer;

  @override
  void initState() {
    super.initState();
    _promoTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      final next = (_promoIndex + 1) % _promoSlides.length;
      _promoCtrl.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _promoTimer?.cancel();
    _promoCtrl.dispose();
    super.dispose();
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Bonjour";
    if (hour < 18) return "Bon après-midi";
    return "Bonsoir";
  }

  List<ServiceTileModel> _services() => [
        const ServiceTileModel(
          id: "food",
          title: "OzelFoods",
          icon: Icons.restaurant_menu_rounded,
          routePath: "/ozelfoods",
          enabled: true,
        ),
        const ServiceTileModel(
          id: "colis",
          title: "Rapid Colis",
          icon: Icons.local_shipping_rounded,
          routePath: "/rapid-colis",
          enabled: true,
        ),
        const ServiceTileModel(
          id: "event",
          title: "Ozel Event",
          icon: Icons.event_available_rounded,
          routePath: "/ozel-event",
          enabled: true,
        ),
        const ServiceTileModel(
          id: "tours",
          title: "Ozel Tours",
          icon: Icons.tour_rounded,
          routePath: "/ozel-tours",
          enabled: true,
        ),
        const ServiceTileModel(
          id: "securites",
          title: "Ozel Sécurités",
          icon: Icons.security_rounded,
          routePath: "/ozel-securites",
          enabled: true,
        ),
        const ServiceTileModel(
          id: "tic",
          title: "OzelTic",
          icon: Icons.devices_rounded,
          routePath: "/ozel-tic",
          enabled: true,
        ),
      ];

  Color _serviceColor(String id) {
    return switch (id) {
      "food" => AppColors.primary,
      "colis" => const Color(0xFF1565C0),
      "event" => const Color(0xFF6A1B9A),
      "hotesses" => const Color(0xFFAD1457),
      "tours" => const Color(0xFF00695C),
      "securites" => const Color(0xFF37474F),
      "tic" => const Color(0xFF1565C0),
      _ => AppColors.textSecondary,
    };
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authSessionProvider).user;
    final firstName = (user?.firstName.isNotEmpty == true)
        ? user!.firstName
        : ((user?.name.trim().isNotEmpty == true)
            ? user!.name.split(" ").first
            : "vous");

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          // ── TopBar ──────────────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            expandedHeight: 0,
            backgroundColor: AppColors.white,
            elevation: 0,
            shadowColor: Colors.black12,
            surfaceTintColor: Colors.transparent,
            title: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delivery_dining_rounded,
                    color: AppColors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  "OZELSERVICES",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: AppColors.black,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            actions: [
              Stack(
                children: [
                  IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Notifications bientôt disponibles"),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      color: AppColors.black,
                    ),
                  ),
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => context.go("/profil"),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                    backgroundImage:
                        (user?.avatarUrl?.isNotEmpty == true)
                            ? NetworkImage(user!.avatarUrl!)
                            : null,
                    child: (user?.avatarUrl?.isNotEmpty != true)
                        ? Text(
                            user?.initials ?? "?",
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
            ],
          ),

          // ── Barre de recherche ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Recherche bientôt disponible"),
                    ),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.search_rounded,
                        color: AppColors.textSecondary,
                        size: 22,
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Rechercher un service, restaurant...",
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Salutation ──────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Text(
                    "${_greeting()}, $firstName 👋",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.black,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 2, 16, 12),
                  child: Text(
                    "Que souhaitez-vous aujourd'hui ?",
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),

                // ── Carousel promo ───────────────────────────────────────────
                SizedBox(
                  height: 150,
                  child: PageView.builder(
                    controller: _promoCtrl,
                    onPageChanged: (i) => setState(() => _promoIndex = i),
                    itemCount: _promoSlides.length,
                    itemBuilder: (context, i) {
                      final slide = _promoSlides[i];
                      final isActive = i == _promoIndex;
                      return AnimatedScale(
                        scale: isActive ? 1.0 : 0.96,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: GestureDetector(
                            onTap: slide.routePath != null
                                ? () => context.go(slide.routePath!)
                                : null,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: slide.gradient,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: slide.gradient.first
                                        .withValues(alpha: 0.35),
                                    blurRadius: 18,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Stack(
                                  children: [
                                    Positioned(
                                      top: -30,
                                      right: -20,
                                      child: Container(
                                        width: 120,
                                        height: 120,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white
                                              .withValues(alpha: 0.08),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: -20,
                                      left: -10,
                                      child: Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white
                                              .withValues(alpha: 0.06),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 16,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  slide.title,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    color: AppColors.white,
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  slide.subtitle,
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: AppColors.white
                                                        .withValues(alpha: 0.88),
                                                    fontSize: 12,
                                                    height: 1.4,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.white
                                                  .withValues(alpha: 0.15),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              slide.icon,
                                              size: 32,
                                              color: AppColors.white
                                                  .withValues(alpha: 0.9),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Indicateurs carousel
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_promoSlides.length, (i) {
                    final active = i == _promoIndex;
                    return GestureDetector(
                      onTap: () => _promoCtrl.animateToPage(
                        i,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOut,
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: active ? 22 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.primary
                              : AppColors.disabled,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    );
                  }),
                ),

                // ── Grille services ──────────────────────────────────────────
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: SectionTitle("Nos services"),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.1,
                    children: _services().map((s) {
                      final disabled = !s.enabled;
                      final color = _serviceColor(s.id);
                      return _ServiceCard(
                        service: s,
                        color: color,
                        disabled: disabled,
                        onTap: () {
                          if (disabled) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "${s.title} arrive bientôt !",
                                ),
                                backgroundColor: AppColors.black,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                            return;
                          }
                          context.go(s.routePath);
                        },
                      );
                    }).toList(),
                  ),
                ),

                // ── Commandes récentes ───────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: SectionTitle(
                    "Commandes récentes",
                    action: TextButton(
                      onPressed: () => context.go("/ozelfoods/historique"),
                      child: const Text(
                        "Tout voir",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: _RecentOrdersList(),
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Service Card ─────────────────────────────────────────────────────────────
class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.service,
    required this.color,
    required this.disabled,
    required this.onTap,
  });

  final ServiceTileModel service;
  final Color color;
  final bool disabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: disabled
                  ? Colors.transparent
                  : color.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: disabled
                ? AppColors.surface
                : color.withValues(alpha: 0.15),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: disabled
                    ? AppColors.surface
                    : color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                service.icon,
                size: 26,
                color: disabled ? AppColors.disabled : color,
              ),
            ),
            Text(
              service.title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: disabled ? AppColors.disabled : AppColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Commandes récentes (données réelles) ─────────────────────────────────────
class _RecentOrdersList extends ConsumerWidget {
  const _RecentOrdersList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(foodOrdersStreamProvider);

    return ordersAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2,
          ),
        ),
      ),
      error: (_, __) => const _EmptyOrdersState(),
      data: (orders) {
        if (orders.isEmpty) return const _EmptyOrdersState();

        final recent = orders.take(3).toList();
        return Column(
          children:
              recent.map((order) => _RealOrderTile(order: order)).toList(),
        );
      },
    );
  }
}

class _EmptyOrdersState extends StatelessWidget {
  const _EmptyOrdersState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_rounded,
            size: 40,
            color: AppColors.textSecondary.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 10),
          const Text(
            "Aucune commande pour le moment",
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => context.go("/ozelfoods"),
            child: const Text(
              "Commander maintenant",
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _RealOrderTile extends StatelessWidget {
  const _RealOrderTile({required this.order});
  final FoodOrder order;

  Color get _statusColor {
    if (order.cancelled) return Colors.red;
    return switch (order.status) {
      FoodOrderStatus.delivered => AppColors.success,
      FoodOrderStatus.preparing => const Color(0xFF1565C0),
      FoodOrderStatus.riderAssigned => const Color(0xFF6A1B9A),
      FoodOrderStatus.onTheWay => AppColors.primary,
    };
  }

  String get _statusLabel {
    if (order.cancelled) return "Annulé";
    return order.status.labelFr;
  }

  IconData get _statusIcon {
    if (order.cancelled) return Icons.cancel_rounded;
    return switch (order.status) {
      FoodOrderStatus.delivered => Icons.check_circle_rounded,
      FoodOrderStatus.preparing => Icons.restaurant_menu_rounded,
      FoodOrderStatus.riderAssigned => Icons.delivery_dining_rounded,
      FoodOrderStatus.onTheWay => Icons.delivery_dining_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go("/ozelfoods/suivi/${order.id}"),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_statusIcon, color: _statusColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.restaurantName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    Formatters.fcfa(order.totalFcfa),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _statusLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _statusColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
