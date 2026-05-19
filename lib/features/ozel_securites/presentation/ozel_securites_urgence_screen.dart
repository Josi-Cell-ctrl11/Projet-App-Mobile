import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/intervention_urgence.dart';
import '../../../shared/widgets/ozel_text_field.dart';
import '../application/ozel_securites_notifier.dart';

/// Ecran intervention d'urgence Ozel Securites.
class OzelSecuritesUrgenceScreen extends ConsumerStatefulWidget {
  const OzelSecuritesUrgenceScreen({super.key});

  @override
  ConsumerState<OzelSecuritesUrgenceScreen> createState() =>
      _OzelSecuritesUrgenceScreenState();
}

class _OzelSecuritesUrgenceScreenState
    extends ConsumerState<OzelSecuritesUrgenceScreen> {
  static const Color _color = Color(0xFF37474F);
  final _adresse = TextEditingController();
  String _typeUrgence = 'Intrusion';
  bool _loading = false;
  bool _agentEnRoute = false;

  Future<void> _appelerIntervention() async {
    if (_adresse.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Renseignez votre adresse')),
      );
      return;
    }

    // Confirmation
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmer l\'intervention'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type : $_typeUrgence'),
            Text('Adresse : ${_adresse.text}'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Intervention <1h — 15 000 FCFA\nFausse alerte = facturee quand meme.',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    setState(() => _loading = false);

    final id =
        'INT-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    ref.read(interventionsProvider.notifier).addIntervention(
          InterventionUrgence(
            id: id,
            type: _typeUrgence,
            adresse: _adresse.text.trim(),
            dateHeure: DateTime.now(),
            statut: StatutIntervention.enCours,
            montant: 15000,
          ),
        );

    setState(() => _agentEnRoute = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: _color,
        foregroundColor: AppColors.white,
        title: const Text('Intervention d\'urgence',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: _agentEnRoute
          ? _AgentEnRouteView()
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Avertissement
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: Colors.red.withValues(alpha: 0.3)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning_rounded,
                              color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text('Avertissement',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14)),
                        ],
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Intervention <1h. Fausse alerte facturee quand meme (15 000 FCFA).',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Tarif
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tarif intervention',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      Text(Formatters.fcfa(15000),
                          style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w900,
                              fontSize: 20)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Adresse
                const Text('Votre adresse',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 8),
                OzelTextField(
                  controller: _adresse,
                  label: 'Ex: Haie Vive, Cotonou',
                  prefixIcon: Icons.place_rounded,
                ),
                const SizedBox(height: 16),

                // Type urgence
                const Text('Type d\'urgence',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _typeUrgence,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(
                            value: 'Intrusion',
                            child: Text('Intrusion')),
                        DropdownMenuItem(
                            value: 'Agression',
                            child: Text('Agression')),
                        DropdownMenuItem(
                            value: 'Incendie',
                            child: Text('Incendie')),
                        DropdownMenuItem(
                            value: 'Autre', child: Text('Autre')),
                      ],
                      onChanged: (v) =>
                          setState(() => _typeUrgence = v!),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Grand bouton rouge
                SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: FilledButton.icon(
                    onPressed: _loading ? null : _appelerIntervention,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.emergency_rounded, size: 28),
                    label: Text(
                      _loading
                          ? 'Envoi en cours...'
                          : 'APPELER UNE INTERVENTION',
                      style: const TextStyle(
                          fontWeight: FontWeight.w900, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _AgentEnRouteView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.directions_run_rounded,
                  size: 56, color: AppColors.success),
            ),
            const SizedBox(height: 20),
            const Text('Agent en route !',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.black)),
            const SizedBox(height: 12),
            const Text(
              'Un agent OZEL Securites est en route vers votre adresse.\nIntervention estimee : <1h.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.5),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'Montant facture : 15 000 FCFA\n(meme en cas de fausse alerte)',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w600,
                    fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
