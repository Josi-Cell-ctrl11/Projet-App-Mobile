// Écran liste des commandes disponibles
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/ozel_loading.dart';
import '../domain/commandes_provider.dart';
import 'commande_card_widget.dart';

/// Écran affichant la liste des commandes disponibles
class CommandesListScreen extends ConsumerWidget {
  const CommandesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commandesAsync = ref.watch(commandesProvider);
    final suspension = ref.watch(suspensionProvider);

    return Scaffold(
      backgroundColor: AppColors.kBackground,
      appBar: AppBar(
        title: const Text(AppStrings.commandes),
        backgroundColor: AppColors.kPrimaryOrange,
        foregroundColor: AppColors.kWhite,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(commandesProvider.notifier).rafraichir(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Dialog de suspension
          if (suspension.estSuspendu)
            _SuspensionBanner(secondes: suspension.secondesRestantes),

          commandesAsync.when(
            loading: () => const Center(
              child: OzelSpinner(size: 40),
            ),
            error: (err, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      color: AppColors.kRed, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    AppStrings.erreurReseau,
                    style: const TextStyle(color: AppColors.kTextSecondary),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () =>
                        ref.read(commandesProvider.notifier).rafraichir(),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
            data: (commandes) {
              if (commandes.isEmpty) {
                return _EmptyState(
                  onRefresh: () =>
                      ref.read(commandesProvider.notifier).rafraichir(),
                );
              }
              return RefreshIndicator(
                color: AppColors.kPrimaryOrange,
                onRefresh: () =>
                    ref.read(commandesProvider.notifier).rafraichir(),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: commandes.length,
                  itemBuilder: (context, index) {
                    final commande = commandes[index];
                    return CommandeCard(
                      commande: commande,
                      onAccepter: suspension.estSuspendu
                          ? () {}
                          : () async {
                              await ref
                                  .read(commandesProvider.notifier)
                                  .accepterCommande(commande.id);
                              if (context.mounted) {
                                context.push('/home/commandes/${commande.id}');
                              }
                            },
                      onRefuser: suspension.estSuspendu
                          ? () {}
                          : () => ref
                              .read(commandesProvider.notifier)
                              .refuserCommande(commande.id),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Bannière de suspension affichée en haut de l'écran
class _SuspensionBanner extends StatelessWidget {
  final int secondes;
  const _SuspensionBanner({required this.secondes});

  String get _duree {
    final min = secondes ~/ 60;
    final sec = secondes % 60;
    return '${min}min ${sec}s';
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(12),
        color: AppColors.kRed,
        child: SafeArea(
          bottom: false,
          child: Row(
            children: [
              const Icon(Icons.block, color: AppColors.kWhite, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${AppStrings.suspensionMessage} Reprise dans $_duree',
                  style: const TextStyle(
                    color: AppColors.kWhite,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// État vide — aucune commande disponible
class _EmptyState extends StatelessWidget {
  final VoidCallback onRefresh;
  const _EmptyState({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.inbox_outlined,
            size: 64,
            color: AppColors.kGrey,
          ),
          const SizedBox(height: 16),
          const Text(
            AppStrings.aucuneCommande,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.kTextSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh, color: AppColors.kPrimaryOrange),
            label: const Text(
              'Actualiser',
              style: TextStyle(color: AppColors.kPrimaryOrange),
            ),
          ),
        ],
      ),
    );
  }
}
