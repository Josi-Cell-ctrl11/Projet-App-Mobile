import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/securite_contrat.dart';
import '../../../shared/widgets/ozel_button.dart';
import '../../../shared/widgets/ozel_text_field.dart';
import '../application/ozel_securites_notifier.dart';

/// Ecran commande jardinage Ozel Securites.
class OzelSecuritesJardinageScreen extends ConsumerStatefulWidget {
  const OzelSecuritesJardinageScreen({super.key});

  @override
  ConsumerState<OzelSecuritesJardinageScreen> createState() =>
      _OzelSecuritesJardinageScreenState();
}

class _OzelSecuritesJardinageScreenState
    extends ConsumerState<OzelSecuritesJardinageScreen> {
  static const Color _color = Color(0xFF2E7D32);
  bool _abonnement = true;
  DateTime? _premierPassage;
  final _adresse = TextEditingController();
  String _superficie = '<100m²';
  bool _loading = false;

  double get _tarif => _abonnement ? 25000 : 8000;

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 3)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx)
            .copyWith(colorScheme: const ColorScheme.light(primary: _color)),
        child: child!,
      ),
    );
    if (d != null) setState(() => _premierPassage = d);
  }

  Future<void> _commander() async {
    if (_adresse.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Renseignez l\'adresse')),
      );
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() => _loading = false);

    final id = 'SC-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    ref.read(securiteContratsProvider.notifier).addContrat(
          SecuriteContrat(
            id: id,
            type: TypeContrat.jardinage,
            formule: _abonnement ? 'Abonnement mensuel' : 'One-shot',
            dateDebut: _premierPassage ?? DateTime.now().add(const Duration(days: 3)),
            dureeMois: _abonnement ? 1 : 0,
            montant: _tarif,
            statut: StatutContrat.actif,
            adresse: _adresse.text.trim(),
            prochainPassage: _premierPassage,
          ),
        );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Commande confirmee ! Notre equipe vous contactera.'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
    context.go('/ozel-securites/contrats');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: _color,
        foregroundColor: AppColors.white,
        title: const Text('Jardinage & Espaces verts',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Choix type
          const Text('Type de prestation',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 10),
          _RadioOption(
            label: 'Abonnement mensuel',
            subtitle: '25 000 FCFA/mois — 4 passages',
            selected: _abonnement,
            color: _color,
            onTap: () => setState(() => _abonnement = true),
          ),
          const SizedBox(height: 8),
          _RadioOption(
            label: 'Prestation one-shot',
            subtitle: '8 000 FCFA — passage unique',
            selected: !_abonnement,
            color: _color,
            onTap: () => setState(() => _abonnement = false),
          ),
          const SizedBox(height: 16),

          // Date premier passage
          if (_abonnement) ...[
            const Text('Date du 1er passage',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        color: Color(0xFF2E7D32), size: 20),
                    const SizedBox(width: 12),
                    Text(
                      _premierPassage == null
                          ? 'Choisir une date'
                          : '${_premierPassage!.day}/${_premierPassage!.month}/${_premierPassage!.year}',
                      style: TextStyle(
                        color: _premierPassage == null
                            ? AppColors.textSecondary
                            : AppColors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Adresse
          const Text('Adresse du jardin',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 8),
          OzelTextField(
            controller: _adresse,
            label: 'Ex: Haie Vive, Cotonou',
            prefixIcon: Icons.place_rounded,
          ),
          const SizedBox(height: 16),

          // Superficie
          const Text('Superficie estimee',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _superficie,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(
                      value: '<100m²', child: Text('Moins de 100 m²')),
                  DropdownMenuItem(
                      value: '100-300m²', child: Text('100 a 300 m²')),
                  DropdownMenuItem(
                      value: '>300m²', child: Text('Plus de 300 m²')),
                ],
                onChanged: (v) => setState(() => _superficie = v!),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Tarif
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _color.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _abonnement ? 'Abonnement mensuel' : 'Prestation one-shot',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  Formatters.fcfa(_tarif),
                  style: TextStyle(
                      color: _color,
                      fontWeight: FontWeight.w900,
                      fontSize: 18),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          OzelPrimaryButton(
            label: _loading ? 'Commande...' : 'Commander',
            enabled: !_loading,
            onPressed: _commander,
          ),
        ],
      ),
    );
  }
}

class _RadioOption extends StatelessWidget {
  const _RadioOption({
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.color,
    required this.onTap,
  });
  final String label, subtitle;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.06) : AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: selected ? color.withValues(alpha: 0.4) : AppColors.disabled),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? color : AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: selected ? color : AppColors.black)),
                  Text(subtitle,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
