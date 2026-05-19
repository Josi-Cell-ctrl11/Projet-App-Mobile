import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../features/auth/presentation/login_screen.dart";
import "../features/auth/presentation/onboarding_screen.dart";
import "../features/auth/presentation/otp_screen.dart";
import "../features/auth/presentation/register_screen.dart";
import "../features/auth/presentation/splash_screen.dart";
import "../features/home/presentation/home_dashboard_screen.dart";
import "../features/ozel_event/presentation/ozel_event_screen.dart";
import "../features/ozel_hotesses/presentation/ozel_hotesses_screen.dart";
import "../features/ozel_securites/presentation/ozel_securites_screen.dart";
import "../features/ozel_tic/presentation/ozel_tic_screen.dart";
import "../features/ozel_tours/presentation/ozel_tours_screen.dart";
import "../features/ozelfoods/presentation/cart_screen.dart";
import "../features/ozelfoods/presentation/checkout_screen.dart";
import "../features/ozelfoods/presentation/order_tracking_screen.dart";
import "../features/ozelfoods/presentation/restaurant_list_screen.dart";
import "../features/ozelfoods/presentation/restaurant_menu_screen.dart";
import "../features/profile/presentation/profile_screen.dart";
import "../features/rapid_colis/presentation/colis_confirm_screen.dart";
import "../features/rapid_colis/presentation/colis_form_screen.dart";
import "../features/rapid_colis/presentation/colis_quote_screen.dart";
import "../features/rapid_colis/presentation/colis_tracking_screen.dart";
import "../features/shell/main_shell_screen.dart";
import "../features/wallet/presentation/recharge_momo_screen.dart";
import "../features/wallet/presentation/wallet_screen.dart";

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: "root");

/// Configuration GoRouter (shell a 5 onglets + flux auth + 5 nouveaux services).
final goRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: "/splash",
    routes: [
      GoRoute(
        path: "/",
        name: "root",
        redirect: (context, state) => "/splash",
      ),
      GoRoute(
        path: "/splash",
        name: "splash",
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: "/onboarding",
        name: "onboarding",
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: "/login",
        name: "login",
        builder: (context, state) => const LoginScreen(),
        routes: [
          GoRoute(
            path: "otp",
            name: "otp",
            builder: (context, state) {
              final phone = state.extra as String? ?? "";
              return OtpScreen(phone: phone);
            },
          ),
        ],
      ),
      GoRoute(
        path: "/register",
        name: "register",
        builder: (context, state) => const RegisterScreen(),
      ),
      // ── 5 nouveaux services ────────────────────────────────────────────────
      GoRoute(
        path: "/ozel-event",
        name: "ozel-event",
        builder: (context, state) => const OzelEventScreen(),
      ),
      GoRoute(
        path: "/ozel-hotesses",
        name: "ozel-hotesses",
        builder: (context, state) => const OzelHotessesScreen(),
      ),
      GoRoute(
        path: "/ozel-tours",
        name: "ozel-tours",
        builder: (context, state) => const OzelToursScreen(),
      ),
      GoRoute(
        path: "/ozel-securites",
        name: "ozel-securites",
        builder: (context, state) => const OzelSecuritesScreen(),
      ),
      GoRoute(
        path: "/ozel-tic",
        name: "ozel-tic",
        builder: (context, state) => const OzelTicScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShellScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: "/accueil",
                name: "accueil",
                builder: (context, state) => const HomeDashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: "/ozelfoods",
                name: "ozelfoods",
                builder: (context, state) => const RestaurantListScreen(),
                routes: [
                  GoRoute(
                    path: "restaurant/:id",
                    name: "restaurant",
                    builder: (context, state) {
                      final id = state.pathParameters["id"]!;
                      return RestaurantMenuScreen(restaurantId: id);
                    },
                  ),
                  GoRoute(
                    path: "panier",
                    name: "panier",
                    builder: (context, state) => const CartScreen(),
                  ),
                  GoRoute(
                    path: "checkout",
                    name: "checkout",
                    builder: (context, state) => const CheckoutScreen(),
                  ),
                  GoRoute(
                    path: "suivi/:orderId",
                    name: "suivi-food",
                    builder: (context, state) {
                      final id = state.pathParameters["orderId"]!;
                      return OrderTrackingScreen(orderId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: "/rapid-colis",
                name: "rapid-colis",
                builder: (context, state) => const ColisFormScreen(),
                routes: [
                  GoRoute(
                    path: "devis",
                    name: "colis-devis",
                    builder: (context, state) => const ColisQuoteScreen(),
                  ),
                  GoRoute(
                    path: "confirmation",
                    name: "colis-confirm",
                    builder: (context, state) => const ColisConfirmScreen(),
                  ),
                  GoRoute(
                    path: "suivi",
                    name: "colis-suivi",
                    builder: (context, state) => const ColisTrackingScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: "/wallet",
                name: "wallet",
                builder: (context, state) => const WalletScreen(),
                routes: [
                  GoRoute(
                    path: "recharge",
                    name: "wallet-recharge",
                    builder: (context, state) => const RechargeMomoScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: "/profil",
                name: "profil",
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: "root");

/// Configuration GoRouter (shell à 5 onglets + flux auth).
final goRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: "/splash",
    routes: [
      GoRoute(
        path: "/",
        name: "root",
        redirect: (context, state) => "/splash",
      ),
      GoRoute(
        path: "/splash",
        name: "splash",
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: "/onboarding",
        name: "onboarding",
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: "/login",
        name: "login",
        builder: (context, state) => const LoginScreen(),
        routes: [
          GoRoute(
            path: "otp",
            name: "otp",
            builder: (context, state) {
              final phone = state.extra as String? ?? "";
              return OtpScreen(phone: phone);
            },
          ),
        ],
      ),
      GoRoute(
        path: "/register",
        name: "register",
        builder: (context, state) => const RegisterScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShellScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: "/accueil",
                name: "accueil",
                builder: (context, state) => const HomeDashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: "/ozelfoods",
                name: "ozelfoods",
                builder: (context, state) => const RestaurantListScreen(),
                routes: [
                  GoRoute(
                    path: "restaurant/:id",
                    name: "restaurant",
                    builder: (context, state) {
                      final id = state.pathParameters["id"]!;
                      return RestaurantMenuScreen(restaurantId: id);
                    },
                  ),
                  GoRoute(
                    path: "panier",
                    name: "panier",
                    builder: (context, state) => const CartScreen(),
                  ),
                  GoRoute(
                    path: "checkout",
                    name: "checkout",
                    builder: (context, state) => const CheckoutScreen(),
                  ),
                  GoRoute(
                    path: "suivi/:orderId",
                    name: "suivi-food",
                    builder: (context, state) {
                      final id = state.pathParameters["orderId"]!;
                      return OrderTrackingScreen(orderId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: "/rapid-colis",
                name: "rapid-colis",
                builder: (context, state) => const ColisFormScreen(),
                routes: [
                  GoRoute(
                    path: "devis",
                    name: "colis-devis",
                    builder: (context, state) => const ColisQuoteScreen(),
                  ),
                  GoRoute(
                    path: "confirmation",
                    name: "colis-confirm",
                    builder: (context, state) => const ColisConfirmScreen(),
                  ),
                  GoRoute(
                    path: "suivi",
                    name: "colis-suivi",
                    builder: (context, state) => const ColisTrackingScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: "/wallet",
                name: "wallet",
                builder: (context, state) => const WalletScreen(),
                routes: [
                  GoRoute(
                    path: "recharge",
                    name: "wallet-recharge",
                    builder: (context, state) => const RechargeMomoScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: "/profil",
                name: "profil",
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
