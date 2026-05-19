import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/securite_contrat.dart';
import '../../../shared/models/intervention_urgence.dart';
import '../application/ozel_securites_notifier.dart';

/// Liste contrats et interventions Ozel Securites.
class OzelSecuritesMesContratsScreen extends ConsumerWidget {
  const OzelSecuritesMesContratsScreen({super.key});

  static const Color _color = Color(0xFF37474F);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contrats = ref.watch(securiteContratsProvider);
    final interventions = ref.watch(interventionsProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: _color,
        foregroundColor: AppColors.white,
        title: const Text('Mes contrats',
            style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => context.go('/ozel-securites'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Contrats actifs
          const Text('Contrats actifs',
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: AppColors.black)),
          const SizedBox(height: 10),
          if (contrats.isEmpty)
            const Text('Aucun contrat actif',
                style: TextStyle(color: AppColors.textSecondary))
          else
            ...contrats.map((c) => _ContratCard(contrat: c)),

          const SizedBox(height: 20),

          // Historique interventions
          const Text('Historique interventions',
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: AppColors.black)),
          const SizedBox(height: 10),
          if (interventions.isEmpty)
            const Text('Aucune intervention',
                style: TextStyle(color: AppColors.textSecondary))
          else
            ...interventions.map((i) => _InterventionCard(intervention: i)),
        ],
      ),
    );
  }
}

class _ContratCard extends StatelessWidget {
  const _ContratCard({required this.contrat});
  final SecuriteContrat contrat;

  static const Color _color = Color(0xFF37474F);

  @override
  Widget build(BuildContext context) {
    final isJardinage = contrat.type == TypeContrat.jardinage;
    final cardColor = isJardinage
        ? const Color(0xFF2E7D32)
        : _color;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: cardColor.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(isJardinage ? '🌿' : '🛡️',
                  style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(contrat.typeLabel,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 14)),
                    Text(contrat.formule,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(contrat.statutLabel,
                    style: const TextStyle(
                        color: AppColors.success,
                        fontSize: 10,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.place_rounded,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(contrat.adresse,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
              ),
            ],
          ),
          if (contrat.prochainPassage != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.event_rounded,
                    size: 14, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  'Prochain passage : ${contrat.prochainPassage!.day}/${contrat.prochainPassage!.month}/${contrat.prochainPassage!.year}',
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
          const SizedBox(height: 6),
          Text(Formatters.fcfa(contrat.montant) + '/mois',
              style: TextStyle(
                  color: cardColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 13)),
        ],
      ),
    );
  }
}

class _InterventionCard extends StatelessWidget {
  const _InterventionCard({required this.intervention});
  final InterventionUrgence intervention;

  @override
  Widget build(BuildContext context) {
    final isResolu =
        intervention.statut == StatutIntervention.resolue;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Text('🚨', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(intervention.type,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13)),
                Text(intervention.adresse,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 11)),
                Text(
                    '${intervention.dateHeure.day}/${intervention.dateHeure.month}/${intervention.dateHeure.year}',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(Formatters.fcfa(intervention.montant),
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.red,
                      fontSize: 13)),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isResolu
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(intervention.statutLabel,
                    style: TextStyle(
                        color: isResolu
                            ? AppColors.success
                            : AppColors.warning,
                        fontSize: 10,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
