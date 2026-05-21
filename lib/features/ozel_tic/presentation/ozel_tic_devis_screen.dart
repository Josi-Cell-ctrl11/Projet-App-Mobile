import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/tic_devis.dart';
import '../../../shared/widgets/ozel_button.dart';
import '../application/ozel_tic_notifier.dart';

/// Ecran devis projet OzelTic.
class OzelTicDevisScreen extends ConsumerStatefulWidget {
  const OzelTicDevisScreen({super.key});

  @override
  ConsumerState<OzelTicDevisScreen> createState() =>
      _OzelTicDevisScreenState();
}

class _OzelTicDevisScreenState extends ConsumerState<OzelTicDevisScreen> {
  static const Color _color = Color(0xFF1565C0);

  String _typeProjet = 'Site web vitrine';
  final _description = TextEditingController();
  String _delai = '1 mois';
  double _budget = 200000;
  bool _loading = false;

  static const Map<String, double> _prixIndicatifs = {
    'Site web vitrine': 150000,
    'Site e-commerce': 300000,
    'Application mobile': 500000,
    'Application web': 250000,
  };

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  Future<void> _demanderDevis() async {
    if (_description.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Decrivez votre projet')),
      );
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() => _loading = false);

    final id =
        'DEV-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    ref.read(ticDevisProvider.notifier).addDevis(
          TicDevis(
            id: id,
            typeProjet: _typeProjet,
            description: _description.text.trim(),
            budget: _budget,
            delai: _delai,
            statut: StatutDevis.enAttente,
            createdAt: DateTime.now(),
          ),
        );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Devis #$id soumis ! Reponse sous 48h.'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
    context.go('/ozel-tic');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: _color,
        foregroundColor: AppColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Devis projet',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Type projet
          const _Label('Type de projet'),
          ..._prixIndicatifs.entries.map((e) {
            final sel = e.key == _typeProjet;
            return GestureDetector(
              onTap: () => setState(() {
                _typeProjet = e.key;
                _budget = e.value;
              }),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: sel
                      ? _color.withValues(alpha: 0.06)
                      : AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: sel
                          ? _color.withValues(alpha: 0.4)
                          : AppColors.disabled),
                ),
                child: Row(
                  children: [
                    Icon(
                      sel
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: sel ? _color : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(e.key,
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: sel ? _color : AppColors.black)),
                    ),
                    Text(
                      'a partir de ${Formatters.fcfa(e.value)}',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 14),

          // Description
          const _Label('Description du projet'),
          TextField(
            controller: _description,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Decrivez votre projet en detail...',
              filled: true,
              fillColor: AppColors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Delai
          const _Label('Delai souhaite'),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _delai,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(
                      value: '2 semaines', child: Text('2 semaines')),
                  DropdownMenuItem(value: '1 mois', child: Text('1 mois')),
                  DropdownMenuItem(
                      value: '2 mois', child: Text('2 mois')),
                  DropdownMenuItem(
                      value: '3 mois', child: Text('3 mois')),
                  DropdownMenuItem(
                      value: 'Flexible', child: Text('Flexible')),
                ],
                onChanged: (v) => setState(() => _delai = v!),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Budget
          _Label(
              'Budget estime : ${Formatters.fcfa(_budget)}'),
          Slider(
            value: _budget,
            min: 50000,
            max: 2000000,
            divisions: 39,
            activeColor: _color,
            inactiveColor: _color.withValues(alpha: 0.15),
            label: Formatters.fcfa(_budget),
            onChanged: (v) => setState(() => _budget = v),
          ),
          const SizedBox(height: 24),

          OzelPrimaryButton(
            label: _loading ? 'Envoi...' : 'Demander un devis',
            enabled: !_loading,
            onPressed: _demanderDevis,
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text,
          style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: AppColors.black)),
    );
  }
}
