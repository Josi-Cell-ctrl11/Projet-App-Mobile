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

// Shell + écrans principaux
import '../../features/shell/main_home_screen.dart';
import '../../features/commandes/presentation/commande_detail_screen.dart';
import '../../features/commandes/presentation/otp_confirmation_screen.dart';
import '../../features/navigation/presentation/navigation_screen.dart';

/// Provider du routeur principal de l'application
final appRouterProvider = Provider<GoRouter>((ref) {
  final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  final notifier = _AuthNotifier(ref);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: false,
    refreshListenable: notifier,

    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isAuthenticated = authState.isAuthenticated;
      final isLoading = authState.isLoading;
      final location = state.uri.path;

      const publicRoutes = ['/', '/login', '/inscription', '/otp'];
      final isPublicRoute =
          publicRoutes.any((r) => location.startsWith(r));

      if (isLoading && location == '/') return null;

      if (!isAuthenticated && !isPublicRoute) {
        return '/login';
      }

      if (isAuthenticated && isPublicRoute && location != '/') {
        return '/home';
      }

      // Anciennes URLs → /home
      if (location.startsWith('/home/') && location != '/home') {
        final tab = switch (location) {
          '/home/dashboard' => 0,
          '/home/commandes' => 1,
          '/home/gains' => 2,
          '/home/profil' => 3,
          _ => null,
        };
        if (tab != null) return '/home?tab=$tab';
      }

      return null;
    },

    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
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

      // Shell principal — IndexedStack + bottom nav
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) {
          final tab = int.tryParse(state.uri.queryParameters['tab'] ?? '') ?? 0;
          return MainHomeScreen(initialTabIndex: tab);
        },
      ),

      // Détail commande (plein écran, hors shell)
      GoRoute(
        path: '/home/commandes/:id',
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

      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
    ],
  );
});

class _AuthNotifier extends ChangeNotifier {
  _AuthNotifier(Ref ref) {
    ref.listen(authProvider, (_, __) => notifyListeners());
  }
}
