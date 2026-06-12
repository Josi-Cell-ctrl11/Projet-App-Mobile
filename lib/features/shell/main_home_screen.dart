// Coque principale avec onglets — IndexedStack (navigation fiable)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/commandes/domain/commandes_provider.dart';
import '../../features/commandes/presentation/commandes_list_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/gains/presentation/gains_screen.dart';
import '../../features/profil/presentation/profil_screen.dart';
import '../../shared/widgets/bottom_nav_bar.dart';

/// Index de l'onglet actif (0 = accueil, 1 = commandes, 2 = gains, 3 = profil).
final mainTabIndexProvider = StateProvider<int>((ref) => 0);

/// Écran principal avec barre de navigation et 4 onglets.
class MainHomeScreen extends ConsumerStatefulWidget {
  const MainHomeScreen({super.key, this.initialTabIndex = 0});

  final int initialTabIndex;

  @override
  ConsumerState<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends ConsumerState<MainHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mainTabIndexProvider.notifier).state =
          widget.initialTabIndex.clamp(0, 3);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tabIndex = ref.watch(mainTabIndexProvider);
    final hasActiveCommande = ref.watch(activeCommandeProvider) != null;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (ref.read(mainTabIndexProvider) != 0) {
          ref.read(mainTabIndexProvider.notifier).state = 0;
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: tabIndex,
          children: const [
            DashboardScreen(),
            CommandesListScreen(),
            GainsScreen(),
            ProfilScreen(),
          ],
        ),
        bottomNavigationBar: OzelBottomNavBar(
          currentIndex: tabIndex,
          hasActiveCommande: hasActiveCommande,
          onTap: (index) {
            ref.read(mainTabIndexProvider.notifier).state = index;
          },
        ),
      ),
    );
  }
}

/// Change l'onglet actif depuis n'importe quel écran enfant.
void allerOnglet(WidgetRef ref, int index) {
  ref.read(mainTabIndexProvider.notifier).state = index.clamp(0, 3);
}
