// Configuration du routeur GoRouter — OZELSERVICES Livreur
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Écrans Auth
import '../../features/auth/domain/auth_provider.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/otp_screen.dart';
import '../../features/auth/presentation/inscription_screen.dart';
import '../../features/notifications/notifications_screen.dart';

// Écrans principaux
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/commandes/presentation/commandes_list_screen.dart';
import '../../features/commandes/presentation/commande_detail_screen.dart';
import '../../features/commandes/presentation/otp_confirmation_screen.dart';
import '../../features/navigation/presentation/navigation_screen.dart';
import '../../features/gains/presentation/gains_screen.dart';
import '../../features/profil/presentation/profil_screen.dart';

// Widgets partagés
import '../../shared/widgets/bottom_nav_bar.dart';
import '../../features/commandes/domain/commandes_provider.dart';

/// Provider du routeur principal de l'application
final appRouterProvider = Provider<GoRouter>((ref) {
  // Clé de navigation racine
  final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

  // Écouter les changements d'auth pour notifier GoRouter
  final notifier = _AuthNotifier(ref);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: false,
    refreshListenable: notifier,

    /// Redirection globale selon l'état d'authentification
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isAuthenticated = authState.isAuthenticated;
      final isLoading = authState.isLoading;
      final location = state.uri.path;

      // Routes publiques accessibles sans connexion
      const publicRoutes = ['/', '/login', '/inscription', '/otp'];
      final isPublicRoute =
          publicRoutes.any((r) => location.startsWith(r));

      // En cours de chargement de la session → rester sur splash
      if (isLoading && location == '/') return null;

      // Non connecté → rediriger vers login sauf routes publiques
      if (!isAuthenticated && !isPublicRoute) {
        return '/login';
      }

      // Déjà connecté sur une route publique → aller au dashboard
      if (isAuthenticated && isPublicRoute && location != '/') {
        return '/home/dashboard';
      }

      return null; // Pas de redirection
    },

    routes: [
      // Splash screen — point d'entrée
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // ── Authentification ────────────────────────────────────────────────
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/inscription',
        name: 'inscription',
        builder: (context, state) => const InscriptionScreen(),
      ),
      GoRoute(
        path: '/otp',
        name: 'otp',
        builder: (context, state) {
          final phone = state.uri.queryParameters['phone'] ?? '';
          return OtpScreen(phone: phone);
        },
      ),

      // ── Shell avec BottomNavigationBar persistante ──────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/dashboard',
                name: 'dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/commandes',
                name: 'commandes',
                builder: (context, state) => const CommandesListScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    name: 'commandeDetail',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return CommandeDetailScreen(commandeId: id);
                    },
                    routes: [
                      GoRoute(
                        path: 'navigation',
                        name: 'navigationGps',
                        builder: (context, state) {
                          final id = state.pathParameters['id']!;
                          return NavigationScreen(commandeId: id);
                        },
                      ),
                      GoRoute(
                        path: 'confirmation',
                        name: 'confirmationOtp',
                        builder: (context, state) {
                          final id = state.pathParameters['id']!;
                          return OtpConfirmationScreen(commandeId: id);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/gains',
                name: 'gains',
                builder: (context, state) => const GainsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/profil',
                name: 'profil',
                builder: (context, state) => const ProfilScreen(),
              ),
            ],
          ),
        ],
      ),

      // ── Routes hors shell (plein écran) ─────────────────────────────────
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
    ],
  );
});

/// ChangeNotifier qui se déclenche lors des changements d'état d'auth
/// Permet à GoRouter de réévaluer ses redirections automatiquement
class _AuthNotifier extends ChangeNotifier {
  _AuthNotifier(Ref ref) {
    // Écouter les changements du provider auth
    ref.listen(authProvider, (_, __) => notifyListeners());
  }
}

/// Shell principal avec BottomNavigationBar persistante
class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasActiveCommande = ref.watch(activeCommandeProvider) != null;

    return Scaffold(
      body: navigationShell,
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: SafeArea(
        top: false,
        child: OzelBottomNavBar(
          currentIndex: navigationShell.currentIndex,
          hasActiveCommande: hasActiveCommande,
          onTap: (index) {
            debugPrint('[NAV] onTap index=$index currentIndex=${navigationShell.currentIndex}');
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
        ),
      ),
    );  }
}
