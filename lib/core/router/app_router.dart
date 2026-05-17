// Configuration du routeur GoRouter — OZELSERVICES Livreur
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Écrans Auth
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/otp_screen.dart';

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
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
    routes: [
      // Splash screen — point d'entrée
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      // Authentification
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/otp',
        name: 'otp',
        builder: (context, state) {
          final phone = state.uri.queryParameters['phone'] ?? '';
          return OtpScreen(phone: phone);
        },
      ),
      // Shell avec BottomNavigationBar persistante
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home/dashboard',
            name: 'dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/home/commandes',
            name: 'commandes',
            builder: (context, state) => const CommandesListScreen(),
          ),
          GoRoute(
            path: '/home/gains',
            name: 'gains',
            builder: (context, state) => const GainsScreen(),
          ),
          GoRoute(
            path: '/home/profil',
            name: 'profil',
            builder: (context, state) => const ProfilScreen(),
          ),
        ],
      ),
      // Routes hors shell (plein écran)
      GoRoute(
        path: '/home/commandes/:id',
        name: 'commandeDetail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return CommandeDetailScreen(commandeId: id);
        },
      ),
      GoRoute(
        path: '/home/commandes/:id/navigation',
        name: 'navigationGps',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return NavigationScreen(commandeId: id);
        },
      ),
      GoRoute(
        path: '/home/commandes/:id/confirmation',
        name: 'confirmationOtp',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return OtpConfirmationScreen(commandeId: id);
        },
      ),
    ],
  );
});

/// Shell principal avec BottomNavigationBar persistante
class MainShell extends ConsumerStatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;

  final List<String> _routes = [
    '/home/dashboard',
    '/home/commandes',
    '/home/gains',
    '/home/profil',
  ];

  @override
  Widget build(BuildContext context) {
    // Badge sur l'onglet Commandes si une commande est active
    final hasActiveCommande = ref.watch(activeCommandeProvider) != null;

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: OzelBottomNavBar(
        currentIndex: _currentIndex,
        hasActiveCommande: hasActiveCommande,
        onTap: (index) {
          setState(() => _currentIndex = index);
          context.go(_routes[index]);
        },
      ),
    );
  }
}
