import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../../../core/constants/app_constants.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/utils/formatters.dart";
import "../../../shared/models/service_tile_model.dart";
import "../../../shared/widgets/section_title.dart";
import "../../auth/application/auth_session.dart";

// ─── Données promo carousel ───────────────────────────────────────────────────
class _PromoSlide {
  const _PromoSlide({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
}

const _promoSlides = [
  _PromoSlide(
    title: "Livraison rapide 🚀",
    subtitle: "OzelFoods — Commande min. 1 500 FCFA\nDélai standard 45 min",
    icon: Icons.restaurant_menu_rounded,
    gradient: [Color(0xFFFF6B35), Color(0xFFE85A28)],
  ),
  _PromoSlide(
    title: "Rapid Colis ⚡",
    subtitle: "Envoi dès 1 000 FCFA\nSuivi GPS en temps réel",
    icon: Icons.local_shipping_rounded,
    gradient: [Color(0xFF1565C0), Color(0xFF0D47A1)],
  ),
  _PromoSlide(
    title: "OzelWallet 💳",
    subtitle: "Payez MoMo, Moov, Visa\n1 FCFA dépensé = 1 point Ozel",
    icon: Icons.account_balance_wallet_rounded,
    gradient: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
  ),
];

// ─── Commandes récentes mock ──────────────────────────────────────────────────
class _RecentOrder {
  const _RecentOrder({
    required this.label,
    required this.status,
    required this.amount,
    required this.icon,
    required this.color,
  });
  final String label;
  final String status;
  final int amount;
  final IconData icon;
  final Color color;
}

const _recentOrders = [
  _RecentOrder(
    label: "OzelFoods — Chez Maman",
    status: "Livré",
    amount: 4500,
    icon: Icons.restaurant_menu_rounded,
    color: AppColors.primary,
  ),
  _RecentOrder(
    label: "Rapid Colis — Akpakpa",
    status: "En cours",
    amount: 1850,
    icon: Icons.local_shipping_rounded,
    color: Color(0xFF1565C0),
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
  final PageController _promoCtrl = PageController();
  int _promoIndex = 0;
  Timer? _promoTimer;

  @override
  void initState() {
    super.initState();
    _promoTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final next = (_promoIndex + 1) % _promoSlides.length;
      _promoCtrl.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _promoTimer?.cancel();
    _promoCtrl.dispose();
    super.dispose();
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
          id: "hotesses",
          title: "Ozel Hôtesses",
          icon: Icons.support_agent_rounded,
          routePath: "/ozel-hotesses",
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

  // Couleurs par service
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
    final firstName = user?.name.split(" ").first ?? "vous";

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
              // Notifications avec badge
              Stack(
                children: [
                  IconButton(
                    onPressed: () {},
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
              // Avatar utilisateur
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => context.go("/profil"),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                    child: Text(
                      user != null
                          ? user.name.substring(0, 1).toUpperCase()
                          : "?",
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Salutation ──────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Text(
                    "Bonjour, $firstName 👋",
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
                  height: 160,
                  child: PageView.builder(
                    controller: _promoCtrl,
                    onPageChanged: (i) => setState(() => _promoIndex = i),
                    itemCount: _promoSlides.length,
                    itemBuilder: (context, i) {
                      final slide = _promoSlides[i];
                      return Padding(
                        padding: EdgeInsets.only(
                          left: i == 0 ? 16 : 8,
                          right: i == _promoSlides.length - 1 ? 16 : 8,
                        ),
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
                                    .withValues(alpha: 0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      slide.title,
                                      style: const TextStyle(
                                        color: AppColors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      slide.subtitle,
                                      style: TextStyle(
                                        color: AppColors.white
                                            .withValues(alpha: 0.85),
                                        fontSize: 12,
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                slide.icon,
                                size: 56,
                                color: AppColors.white.withValues(alpha: 0.3),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Indicateurs carousel
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_promoSlides.length, (i) {
                    final active = i == _promoIndex;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: active ? 20 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.primary
                            : AppColors.disabled,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    );
                  }),
                ),

                // ── OzelWallet card ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: GestureDetector(
                    onTap: () => context.go("/wallet"),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.black,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet_rounded,
                              color: AppColors.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "OzelWallet",
                                  style: TextStyle(
                                    color: Colors.white60,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  user == null
                                      ? "Non connecté"
                                      : Formatters.fcfa(
                                          user.walletBalanceFcfa),
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (user != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "${user.ozelPoints} pts",
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.white38,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Grille services ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: SectionTitle(
                    "Nos services",
                    action: TextButton(
                      onPressed: () {},
                      child: const Text(
                        "Voir tout",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
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
                      onPressed: () {},
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

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: Column(
                    children: _recentOrders
                        .map((o) => _RecentOrderTile(order: o))
                        .toList(),
                  ),
                ),
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
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
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: disabled
                              ? AppColors.disabled
                              : AppColors.black,
                        ),
                      ),
                      if (disabled)
                        const Text(
                          "Bientôt disponible",
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            // Badge "Bientôt" pour les services désactivés
            if (disabled)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.disabled, width: 1),
                  ),
                  child: const Text(
                    "Bientôt",
                    style: TextStyle(
                      fontSize: 9,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Recent Order Tile ────────────────────────────────────────────────────────
class _RecentOrderTile extends StatelessWidget {
  const _RecentOrderTile({required this.order});
  final _RecentOrder order;

  @override
  Widget build(BuildContext context) {
    final isDelivered = order.status == "Livré";
    return Container(
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
              color: order.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(order.icon, color: order.color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  Formatters.fcfa(order.amount),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isDelivered
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              order.status,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDelivered ? AppColors.success : AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
