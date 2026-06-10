import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../core/analytics/app_analytics.dart";

import "../features/auth/presentation/login_screen.dart";
import "../features/auth/presentation/onboarding_screen.dart";
import "../features/auth/presentation/otp_screen.dart";
import "../features/auth/presentation/register_screen.dart";
import "../features/auth/presentation/splash_screen.dart";
import "../features/home/presentation/home_dashboard_screen.dart";

// ── Ozel Event ────────────────────────────────────────────────────────────────
import "../features/ozel_event/presentation/ozel_event_home_screen.dart";
import "../features/ozel_event/presentation/ozel_event_devis_screen.dart";
import "../features/ozel_event/presentation/ozel_event_paiement_screen.dart";
import "../features/ozel_event/presentation/ozel_event_confirmation_screen.dart";
import "../features/ozel_event/presentation/ozel_event_reservations_screen.dart";

// ── Ozel Tours ────────────────────────────────────────────────────────────────
import "../features/ozel_tours/presentation/ozel_tours_home_screen.dart";
import "../features/ozel_tours/presentation/ozel_tours_circuit_detail_screen.dart";
import "../features/ozel_tours/presentation/ozel_tours_reservation_screen.dart";
import "../features/ozel_tours/presentation/ozel_tours_ebillet_screen.dart";

// ── Ozel Securites ────────────────────────────────────────────────────────────
import "../features/ozel_securites/presentation/ozel_securites_home_screen.dart";
import "../features/ozel_securites/presentation/ozel_securites_jardinage_screen.dart";
import "../features/ozel_securites/presentation/ozel_securites_vigile_screen.dart";
import "../features/ozel_securites/presentation/ozel_securites_urgence_screen.dart";
import "../features/ozel_securites/presentation/ozel_securites_mes_contrats_screen.dart";
import "../features/ozel_securites/presentation/nounou_screen.dart";
import "../features/ozel_securites/presentation/entretien_appartement_screen.dart";

// ── OzelTic ───────────────────────────────────────────────────────────────────
import "../features/ozel_tic/presentation/ozel_tic_home_screen.dart";
import "../features/ozel_tic/presentation/ozel_tic_depannage_screen.dart";
import "../features/ozel_tic/presentation/ozel_tic_devis_screen.dart";
import "../features/ozel_tic/presentation/ozel_tic_domaine_screen.dart";
import "../features/ozel_tic/presentation/ozel_tic_mes_tickets_screen.dart";
import "../features/ozel_tic/presentation/cameras_surveillance_screen.dart";
import "../features/ozel_tic/presentation/reseaux_screen.dart";

// ── Ozel Tours ────────────────────────────────────────────────────────────────
import "../features/ozel_tours/presentation/guest_houses_screen.dart";
import "../features/ozel_tours/presentation/inscription_tourisme_screen.dart";
import "../features/ozel_tours/presentation/ozel_tours_screen.dart";
import "../features/ozel_securites/presentation/ozel_securites_screen.dart";
import "../features/ozel_tic/presentation/ozel_tic_screen.dart";

// ── OzelFoods ─────────────────────────────────────────────────────────────────
import "../features/ozelfoods/presentation/cart_screen.dart";
import "../features/ozelfoods/presentation/checkout_screen.dart";
import "../features/ozelfoods/presentation/order_tracking_screen.dart";
import "../features/ozelfoods/presentation/restaurant_list_screen.dart";
import "../features/ozelfoods/presentation/restaurant_menu_screen.dart";

import "../features/ozelfoods/presentation/orders_history_screen.dart";
import "../features/ozelfoods/presentation/table_qrcode_screen.dart";
import "../features/profile/presentation/edit_profile_screen.dart";
import "../features/profile/presentation/profile_screen.dart";
import "../features/rapid_colis/presentation/colis_confirm_screen.dart";
import "../features/rapid_colis/presentation/colis_form_screen.dart";
import "../features/rapid_colis/presentation/colis_quote_screen.dart";
import "../features/rapid_colis/presentation/colis_tracking_screen.dart";
import "../features/shell/main_shell_screen.dart";
import "../features/wallet/presentation/wallet_screen.dart";
import "../shared/models/circuit_model.dart";
import "../shared/models/hotesse_model.dart";
import "../shared/models/tour_reservation.dart";

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: "root");

Widget _missingDataScreen() => const Scaffold(
      body: Center(child: Text("Données manquantes")),
    );

/// Configuration GoRouter — 7 services complets + flux auth.
final goRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: "/splash",
    observers: [analyticsObserver],
    redirect: (context, state) {
      final loggedIn = FirebaseAuth.instance.currentUser != null;
      const authRoutes = [
        "/splash",
        "/onboarding",
        "/login",
        "/register",
        "/otp",
      ];
      final location = state.matchedLocation;
      final isAuthRoute = authRoutes.any(
        (route) => location == route || location.startsWith("$route/"),
      );
      if (!loggedIn && !isAuthRoute) return "/login";
      return null;
    },
    routes: [
      GoRoute(
        path: "/",
        redirect: (_, __) => "/splash",
      ),
      GoRoute(
        path: "/splash",
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: "/onboarding",
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: "/login",
        builder: (_, __) => const LoginScreen(),
        routes: [
          GoRoute(
            path: "otp",
            builder: (_, state) {
              final extra = state.extra as Map?;
              return OtpScreen(
                phone: extra?["phone"] as String? ?? "",
                resendToken: extra?["resendToken"] as int?,
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: "/register",
        builder: (_, __) => const RegisterScreen(),
      ),

      // ── OZEL EVENT ──────────────────────────────────────────────────────────
      GoRoute(
        path: "/ozel-event",
        builder: (_, state) => const OzelEventHomeScreen(),
      ),
      GoRoute(
        path: "/ozel-event/devis",
        builder: (_, state) =>
            OzelEventDevisScreen(typeInitial: state.extra as String?),
      ),
      GoRoute(
        path: "/ozel-event/paiement",
        builder: (_, state) {
          final data = state.extra as Map<String, dynamic>?;
          if (data == null) return _missingDataScreen();
          return OzelEventPaiementScreen(data: data);
        },
      ),
      GoRoute(
        path: "/ozel-event/confirmation",
        builder: (_, state) {
          final data = state.extra as Map<String, dynamic>?;
          if (data == null) return _missingDataScreen();
          return OzelEventConfirmationScreen(data: data);
        },
      ),
      GoRoute(
        path: "/ozel-event/reservations",
        builder: (_, __) => const OzelEventReservationsScreen(),
      ),

      // ── OZEL TOURS ──────────────────────────────────────────────────────────
      GoRoute(
        path: "/ozel-tours",
        builder: (_, __) => const OzelToursHomeScreen(),
      ),
      GoRoute(
        path: "/ozel-tours/circuit/:id",
        builder: (_, state) {
          final circuit = state.extra as CircuitModel?;
          if (circuit == null) return _missingDataScreen();
          return OzelToursCircuitDetailScreen(circuit: circuit);
        },
      ),
      GoRoute(
        path: "/ozel-tours/reservation",
        builder: (_, state) {
          final circuit = state.extra as CircuitModel?;
          if (circuit == null) return _missingDataScreen();
          return OzelToursReservationScreen(circuit: circuit);
        },
      ),
      GoRoute(
        path: "/ozel-tours/guest-houses",
        builder: (_, __) => const GuestHousesScreen(),
      ),
      GoRoute(
        path: "/ozel-tours/ebillet",
        builder: (_, state) => OzelToursEbilletScreen(
            reservation: state.extra as TourReservation?),
      ),

      // ── OZEL SECURITES ──────────────────────────────────────────────────────
      GoRoute(
        path: "/ozel-securites",
        builder: (_, __) => const OzelSecuritesHomeScreen(),
      ),
      GoRoute(
        path: "/ozel-securites/jardinage",
        builder: (_, __) => const OzelSecuritesJardinageScreen(),
      ),
      GoRoute(
        path: "/ozel-securites/vigile",
        builder: (_, __) => const OzelSecuritesVigileScreen(),
      ),
      GoRoute(
        path: "/ozel-securites/urgence",
        builder: (_, __) => const OzelSecuritesUrgenceScreen(),
      ),
      GoRoute(
        path: "/ozel-securites/contrats",
        builder: (_, __) => const OzelSecuritesMesContratsScreen(),
      ),
      GoRoute(
        path: "/ozel-securites/nounou",
        builder: (_, __) => const NounouScreen(),
      ),
      GoRoute(
        path: "/ozel-securites/entretien",
        builder: (_, __) => const EntretienAppartementScreen(),
      ),

      // ── OZELTIC ─────────────────────────────────────────────────────────────
      GoRoute(
        path: "/ozel-tic",
        builder: (_, __) => const OzelTicHomeScreen(),
      ),
      GoRoute(
        path: "/ozel-tic/depannage",
        builder: (_, __) => const OzelTicDepannageScreen(),
      ),
      GoRoute(
        path: "/ozel-tic/devis",
        builder: (_, __) => const OzelTicDevisScreen(),
      ),
      GoRoute(
        path: "/ozel-tic/domaine",
        builder: (_, __) => const OzelTicDomaineScreen(),
      ),
      GoRoute(
        path: "/ozel-tic/tickets",
        builder: (_, __) => const OzelTicMesTicketsScreen(),
      ),
      GoRoute(
        path: "/ozel-tic/cameras",
        builder: (_, __) => const CamerasSurveillanceScreen(),
      ),
      GoRoute(
        path: "/ozel-tic/reseaux",
        builder: (_, __) => const ReseauxScreen(),
      ),

      // ── OZEL TOURS (suite) ───────────────────────────────────────────────
      GoRoute(
        path: "/ozel-tours/tourisme",
        builder: (_, __) => const InscriptionTourismeScreen(),
      ),
      GoRoute(
        path: "/ozel-tours/legacy",
        builder: (_, __) => const OzelToursScreen(),
      ),
      GoRoute(
        path: "/ozel-securites/legacy",
        builder: (_, __) => const OzelSecuritesScreen(),
      ),
      GoRoute(
        path: "/ozel-tic/legacy",
        builder: (_, __) => const OzelTicScreen(),
      ),

      // ── SHELL (5 onglets) ───────────────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (_, __, navigationShell) =>
            MainShellScreen(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: "/accueil",
              builder: (_, __) => const HomeDashboardScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: "/ozelfoods",
              builder: (_, __) => const RestaurantListScreen(),
              routes: [
                GoRoute(
                  path: "restaurant/:id",
                  builder: (_, state) => RestaurantMenuScreen(
                      restaurantId: state.pathParameters["id"]!),
                ),
                GoRoute(
                  path: "panier",
                  builder: (_, __) => const CartScreen(),
                ),
                GoRoute(
                  path: "checkout",
                  builder: (_, __) => const CheckoutScreen(),
                ),
                GoRoute(
                  path: "suivi/:orderId",
                  builder: (_, state) => OrderTrackingScreen(
                      orderId: state.pathParameters["orderId"]!),
                ),
                GoRoute(
                  path: "historique",
                  builder: (_, __) => const OrdersHistoryScreen(),
                ),
                GoRoute(
                  path: "qrcode",
                  builder: (_, state) {
                    final extra = state.extra as Map<String, dynamic>?;
                    return TableQrcodeScreen(
                      commandeId: extra?["commandeId"] as String? ?? "",
                      restaurantNom: extra?["restaurantNom"] as String? ?? "",
                      plats: List<String>.from(extra?["plats"] as List? ?? []),
                      heurePrevue: extra?["heurePrevue"] as String? ?? "",
                      clientNom: extra?["clientNom"] as String? ?? "",
                    );
                  },
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: "/rapid-colis",
              builder: (_, __) => const ColisFormScreen(),
              routes: [
                GoRoute(
                  path: "devis",
                  builder: (_, __) => const ColisQuoteScreen(),
                ),
                GoRoute(
                  path: "confirmation",
                  builder: (_, __) => const ColisConfirmScreen(),
                ),
                GoRoute(
                  path: "suivi",
                  builder: (_, __) => const ColisTrackingScreen(),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: "/wallet",
              builder: (_, __) => const WalletScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: "/profil",
              builder: (_, __) => const ProfileScreen(),
              routes: [
                GoRoute(
                  path: "edit",
                  builder: (_, __) => const EditProfileScreen(),
                ),
              ],
            ),
          ]),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
