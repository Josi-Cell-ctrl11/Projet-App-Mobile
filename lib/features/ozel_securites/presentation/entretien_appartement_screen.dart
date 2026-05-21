import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/ozel_text_field.dart';

/// Ecran demande de devis Entretien Appartement Ozel Securites.
class EntretienAppartementScreen extends ConsumerStatefulWidget {
  const EntretienAppartementScreen({super.key});

  @override
  ConsumerState<EntretienAppartementScreen> createState() =>
      _EntretienAppartementScreenState();
}

class _EntretienAppartementScreenState
    extends ConsumerState<EntretienAppartementScreen> {
  static const Color _color = Color(0xFF37474F);
  
  final _adresse = TextEditingController();
  final _whatsapp = TextEditingController();
  final _notes = TextEditingController();
  String _typeService = 'menage';
  String _frequence = 'hebdomadaire';
  String _nbPieces = '1-2';
  bool _loading = false;

  Future<void> _demanderDevis() async {
    if (_adresse.text.trim().isEmpty || _whatsapp.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Renseignez l\'adresse et le WhatsApp')),
      );
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() => _loading = false);

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded,
                color: AppColors.success, size: 64),
            const SizedBox(height: 16),
            const Text(
              '✅ Demande envoyée !',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Notre équipe vous contactera sous 2h sur WhatsApp\nau ${_whatsapp.text} pour établir votre devis.',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/ozel-securites');
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _adresse.dispose();
    _whatsapp.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: _color,
        foregroundColor: AppColors.white,
        title: const Text('Entretien Appartement',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Type de service
          const Text('Type de service',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 10),
          _RadioOption(
            label: 'Ménage',
            subtitle: 'Nettoyage complet',
            selected: _typeService == 'menage',
            color: _color,
            onTap: () => setState(() => _typeService = 'menage'),
          ),
          const SizedBox(height: 8),
          _RadioOption(
            label: 'Repassage',
            subtitle: 'Linge repassé',
            selected: _typeService == 'repassage',
            color: _color,
            onTap: () => setState(() => _typeService = 'repassage'),
          ),
          const SizedBox(height: 8),
          _RadioOption(
            label: 'Ménage + Repassage',
            subtitle: 'Service complet',
            selected: _typeService == 'complet',
            color: _color,
            onTap: () => setState(() => _typeService = 'complet'),
          ),
          const SizedBox(height: 16),

          // Fréquence
          const Text('Fréquence',
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
                value: _frequence,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(
                      value: 'ponctuel', child: Text('Ponctuel')),
                  DropdownMenuItem(
                      value: 'hebdomadaire', child: Text('Hebdomadaire')),
                  DropdownMenuItem(
                      value: 'mensuel', child: Text('Mensuel')),
                ],
                onChanged: (v) => setState(() => _frequence = v!),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Nombre de pièces
          const Text('Nombre de pièces',
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
                value: _nbPieces,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(
                      value: '1-2', child: Text('1-2 pièces')),
                  DropdownMenuItem(
                      value: '3-4', child: Text('3-4 pièces')),
                  DropdownMenuItem(
                      value: '5+', child: Text('5+ pièces')),
                ],
                onChanged: (v) => setState(() => _nbPieces = v!),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Adresse
          const Text('Adresse',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 8),
          OzelTextField(
            controller: _adresse,
            label: 'Ex: Cadjèhoun, Cotonou',
            prefixIcon: Icons.place_rounded,
          ),
          const SizedBox(height: 16),

          // WhatsApp
          const Text('WhatsApp *',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 8),
          OzelTextField(
            controller: _whatsapp,
            label: '+229 XX XX XX XX',
            prefixIcon: Icons.chat_rounded,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),

          // Notes
          const Text('Notes / précisions',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 8),
          TextField(
            controller: _notes,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Dites-nous en plus sur vos besoins...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),

          // Bouton
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: _loading ? null : _demanderDevis,
              style: FilledButton.styleFrom(
                backgroundColor: _color,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.send_rounded),
              label: Text(_loading ? 'Envoi...' : 'Demander un devis',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            ),
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
