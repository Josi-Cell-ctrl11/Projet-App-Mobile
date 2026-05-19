import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/securite_contrat.dart';
import '../../../shared/widgets/ozel_button.dart';
import '../../../shared/widgets/ozel_text_field.dart';
import '../application/ozel_securites_notifier.dart';

/// Ecran demande vigile Ozel Securites.
class OzelSecuritesVigileScreen extends ConsumerStatefulWidget {
  const OzelSecuritesVigileScreen({super.key});

  @override
  ConsumerState<OzelSecuritesVigileScreen> createState() =>
      _OzelSecuritesVigileScreenState();
}

class _OzelSecuritesVigileScreenState
    extends ConsumerState<OzelSecuritesVigileScreen> {
  static const Color _color = Color(0xFF37474F);
  bool _formule24h = false;
  DateTime? _dateDebut;
  final _adresse = TextEditingController();
  String _typeSite = 'Domicile';
  bool _loading = false;

  static const int _dureeMoisMin = 3;
  double get _tarifMensuel => _formule24h ? 150000 : 90000;
  double get _totalContrat => _tarifMensuel * _dureeMoisMin;

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx)
            .copyWith(colorScheme: const ColorScheme.light(primary: _color)),
        child: child!,
      ),
    );
    if (d != null) setState(() => _dateDebut = d);
  }

  Future<void> _demanderContrat() async {
    if (_adresse.text.trim().isEmpty || _dateDebut == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Renseignez l\'adresse et la date de debut')),
      );
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() => _loading = false);

    final id =
        'SC-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    ref.read(securiteContratsProvider.notifier).addContrat(
          SecuriteContrat(
            id: id,
            type: TypeContrat.vigile,
            formule: _formule24h ? '24h/24' : '12h/nuit',
            dateDebut: _dateDebut!,
            dureeMois: _dureeMoisMin,
            montant: _tarifMensuel,
            statut: StatutContrat.actif,
            adresse: _adresse.text.trim(),
          ),
        );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Contrat soumis ! Notre equipe vous contactera sous 24h.'),
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
        title: const Text('Securite privee — Vigile',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Formule
          const Text('Formule',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 10),
          _RadioOpt(
            label: '12h/nuit',
            subtitle: '90 000 FCFA/mois',
            selected: !_formule24h,
            color: _color,
            onTap: () => setState(() => _formule24h = false),
          ),
          const SizedBox(height: 8),
          _RadioOpt(
            label: '24h/24',
            subtitle: '150 000 FCFA/mois',
            selected: _formule24h,
            color: _color,
            onTap: () => setState(() => _formule24h = true),
          ),
          const SizedBox(height: 16),

          // Info duree minimum
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    color: Color(0xFF37474F), size: 16),
                SizedBox(width: 8),
                Text('Contrat minimum : 3 mois',
                    style: TextStyle(
                        color: Color(0xFF37474F),
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Date debut
          const Text('Date de debut',
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
                      color: Color(0xFF37474F), size: 20),
                  const SizedBox(width: 12),
                  Text(
                    _dateDebut == null
                        ? 'Choisir une date'
                        : '${_dateDebut!.day}/${_dateDebut!.month}/${_dateDebut!.year}',
                    style: TextStyle(
                      color: _dateDebut == null
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

          // Adresse
          const Text('Adresse a securiser',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 8),
          OzelTextField(
            controller: _adresse,
            label: 'Ex: Akpakpa, Cotonou',
            prefixIcon: Icons.place_rounded,
          ),
          const SizedBox(height: 16),

          // Type site
          const Text('Type de site',
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
                value: _typeSite,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(
                      value: 'Domicile', child: Text('Domicile')),
                  DropdownMenuItem(
                      value: 'Commerce', child: Text('Commerce')),
                  DropdownMenuItem(
                      value: 'Entrepot', child: Text('Entrepot')),
                  DropdownMenuItem(
                      value: 'Evenement', child: Text('Evenement')),
                ],
                onChanged: (v) => setState(() => _typeSite = v!),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Total
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _color.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formule24h ? '24h/24' : '12h/nuit',
                        style: const TextStyle(
                            color: AppColors.textSecondary)),
                    Text(Formatters.fcfa(_tarifMensuel) + '/mois'),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total 3 mois',
                        style: TextStyle(fontWeight: FontWeight.w800)),
                    Text(
                      Formatters.fcfa(_totalContrat),
                      style: TextStyle(
                          color: _color,
                          fontWeight: FontWeight.w900,
                          fontSize: 18),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          OzelPrimaryButton(
            label: _loading ? 'Envoi...' : 'Demander un contrat',
            enabled: !_loading,
            onPressed: _demanderContrat,
          ),
        ],
      ),
    );
  }
}

class _RadioOpt extends StatelessWidget {
  const _RadioOpt({
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
              color: selected
                  ? color.withValues(alpha: 0.4)
                  : AppColors.disabled),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
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
