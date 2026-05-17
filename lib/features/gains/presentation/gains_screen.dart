// Écran des gains du livreur
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/commande.dart';
import '../../../shared/models/gain.dart';
import '../../../shared/widgets/ozel_button.dart';
import '../../../shared/widgets/ozel_card.dart';
import '../../../shared/widgets/ozel_loading.dart';
import '../domain/gains_provider.dart';
import 'retrait_bottom_sheet.dart';

/// Écran principal des gains avec solde, agrégats et historique
class GainsScreen extends ConsumerWidget {
  const GainsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gainsAsync = ref.watch(gainsProvider);

    return Scaffold(
      backgroundColor: AppColors.kBackground,
      appBar: AppBar(
        title: const Text(AppStrings.gains),
        backgroundColor: AppColors.kPrimaryOrange,
        foregroundColor: AppColors.kWhite,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(gainsProvider.notifier).rafraichir(),
          ),
        ],
      ),
      body: gainsAsync.when(
        loading: () => const Center(child: OzelSpinner(size: 40)),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppColors.kRed, size: 48),
              const SizedBox(height: 12),
              const Text(AppStrings.erreurReseau),
              TextButton(
                onPressed: () => ref.read(gainsProvider.notifier).rafraichir(),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
        data: (gains) => RefreshIndicator(
          color: AppColors.kPrimaryOrange,
          onRefresh: () => ref.read(gainsProvider.notifier).rafraichir(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Solde disponible
                _SoldeCard(solde: gains.soldeDisponible, context: context, ref: ref, gains: gains),
                const SizedBox(height: 16),
                // Agrégats 3 périodes
                _AgregatsSection(gains: gains),
                const SizedBox(height: 16),
                // Note J+1
                _NoteJPlus1(),
                const SizedBox(height: 16),
                // Historique
                _HistoriqueSection(historique: gains.historique),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SoldeCard extends StatelessWidget {
  final double solde;
  final BuildContext context;
  final WidgetRef ref;
  final GainsData gains;

  const _SoldeCard({
    required this.solde,
    required this.context,
    required this.ref,
    required this.gains,
  });

  @override
  Widget build(BuildContext _) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.kPrimaryOrange, AppColors.kPrimaryOrangeDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.kPrimaryOrange.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.soldeDisponible,
            style: TextStyle(color: AppColors.kWhite, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            Formatters.formatFcfa(solde),
            style: const TextStyle(
              color: AppColors.kWhite,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          OzelButton(
            label: AppStrings.demanderRetrait,
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (_) => RetraitBottomSheet(soldeDisponible: solde),
            ),
            variant: OzelButtonVariant.secondary,
            icon: Icons.account_balance_wallet,
            height: 44,
          ),
        ],
      ),
    );
  }
}

class _AgregatsSection extends StatelessWidget {
  final GainsData gains;
  const _AgregatsSection({required this.gains});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _AggregatCard(
            label: "Aujourd'hui",
            montant: gains.gainsAujourdhui,
            icone: Icons.today,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _AggregatCard(
            label: 'Cette semaine',
            montant: gains.gainsSemaine,
            icone: Icons.date_range,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _AggregatCard(
            label: 'Ce mois',
            montant: gains.gainsMois,
            icone: Icons.calendar_month,
          ),
        ),
      ],
    );
  }
}

class _AggregatCard extends StatelessWidget {
  final String label;
  final double montant;
  final IconData icone;

  const _AggregatCard({
    required this.label,
    required this.montant,
    required this.icone,
  });

  @override
  Widget build(BuildContext context) {
    return OzelCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, color: AppColors.kPrimaryOrange, size: 18),
          const SizedBox(height: 6),
          Text(
            Formatters.formatFcfa(montant),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.kTextPrimary,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.kTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteJPlus1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.kBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.kBlue.withValues(alpha: 0.2)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.kBlue, size: 16),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Les gains sont crédités J+1 après confirmation de chaque livraison.',
              style: TextStyle(fontSize: 12, color: AppColors.kBlue),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoriqueSection extends StatelessWidget {
  final List<HistoriqueLivraison> historique;
  const _HistoriqueSection({required this.historique});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.historique,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...historique.map((h) => _HistoriqueItem(livraison: h)),
      ],
    );
  }
}

class _HistoriqueItem extends StatelessWidget {
  final HistoriqueLivraison livraison;
  const _HistoriqueItem({required this.livraison});

  @override
  Widget build(BuildContext context) {
    final isFood = livraison.type == TypeCommande.ozelFoods;
    final isCredite = livraison.statutPaiement == StatutPaiement.credite;

    return OzelCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isFood
                  ? AppColors.kPrimaryOrange.withValues(alpha: 0.1)
                  : AppColors.kBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isFood ? Icons.restaurant : Icons.inventory_2,
              color: isFood ? AppColors.kPrimaryOrange : AppColors.kBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isFood ? AppStrings.ozelFoods : AppStrings.rapidColis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  Formatters.formatDate(livraison.date),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.kTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+${Formatters.formatFcfa(livraison.montantGagne)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.kGreen,
                  fontSize: 14,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isCredite
                      ? AppColors.kGreen.withValues(alpha: 0.1)
                      : AppColors.kYellow.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isCredite ? AppStrings.credite : AppStrings.enAttente,
                  style: TextStyle(
                    fontSize: 10,
                    color: isCredite ? AppColors.kGreen : AppColors.kYellow,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
