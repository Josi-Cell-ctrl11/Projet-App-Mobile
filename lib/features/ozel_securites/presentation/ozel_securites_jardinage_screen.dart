import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/ozel_text_field.dart';

/// Ecran demande de devis Jardinage Ozel Securites.
class OzelSecuritesJardinageScreen extends ConsumerStatefulWidget {
  const OzelSecuritesJardinageScreen({super.key});

  @override
  ConsumerState<OzelSecuritesJardinageScreen> createState() =>
      _OzelSecuritesJardinageScreenState();
}

class _OzelSecuritesJardinageScreenState
    extends ConsumerState<OzelSecuritesJardinageScreen> {
  static const Color _color = Color(0xFF2E7D32);
  
  final _adresse = TextEditingController();
  final _whatsapp = TextEditingController();
  final _notes = TextEditingController();
  String _typePrestation = 'abonnement';
  DateTime? _dateSouhaitee;
  String _superficie = '<100m²';
  bool _loading = false;

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
    if (d != null) setState(() => _dateSouhaitee = d);
  }

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Jardinage & Espaces verts',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Type de prestation
          const Text('Type de prestation',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 10),
          _RadioOption(
            label: 'Abonnement mensuel',
            subtitle: '4 passages par mois',
            selected: _typePrestation == 'abonnement',
            color: _color,
            onTap: () => setState(() => _typePrestation = 'abonnement'),
          ),
          const SizedBox(height: 8),
          _RadioOption(
            label: 'Prestation one-shot',
            subtitle: 'Passage unique',
            selected: _typePrestation == 'oneshot',
            color: _color,
            onTap: () => setState(() => _typePrestation = 'oneshot'),
          ),
          const SizedBox(height: 16),

          // Date souhaitée
          const Text('Date souhaitée',
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
                    _dateSouhaitee == null
                        ? 'Choisir une date'
                        : '${_dateSouhaitee!.day}/${_dateSouhaitee!.month}/${_dateSouhaitee!.year}',
                    style: TextStyle(
                      color: _dateSouhaitee == null
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
          const Text('Adresse du jardin',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 8),
          OzelTextField(
            controller: _adresse,
            label: 'Ex: Haie Vive, Cotonou',
            prefixIcon: Icons.place_rounded,
          ),
          const SizedBox(height: 16),

          // WhatsApp
          const Text('WhatsApp *',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 8),
          OzelTextField(
            controller: _whatsapp,
            label: 'WhatsApp *',
            hint: '01 97 90 90 98',
            prefixText: '+229 ',
            prefixIcon: Icons.chat_rounded,
            keyboardType: TextInputType.phone,
            inputFormatters: [PhoneBeninInputFormatter()],
          ),
          const SizedBox(height: 16),

          // Superficie
          const Text('Superficie estimée',
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
                      value: '100-300m²', child: Text('100 à 300 m²')),
                  DropdownMenuItem(
                      value: '>300m²', child: Text('Plus de 300 m²')),
                ],
                onChanged: (v) => setState(() => _superficie = v!),
              ),
            ),
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
