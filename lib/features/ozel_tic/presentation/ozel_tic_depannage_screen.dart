import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/tic_ticket.dart';
import '../../../shared/widgets/ozel_button.dart';
import '../../../shared/widgets/ozel_text_field.dart';
import '../application/ozel_tic_notifier.dart';

/// Ecran depannage OzelTic.
class OzelTicDepannageScreen extends ConsumerStatefulWidget {
  const OzelTicDepannageScreen({super.key});

  @override
  ConsumerState<OzelTicDepannageScreen> createState() =>
      _OzelTicDepannageScreenState();
}

class _OzelTicDepannageScreenState
    extends ConsumerState<OzelTicDepannageScreen> {
  static const Color _color = Color(0xFF1565C0);

  String _typeProbleme = 'PC ne demarre pas';
  bool _domicile = true;
  final _description = TextEditingController();
  final _adresse = TextEditingController();
  String? _photoPath;
  bool _loading = false;

  double get _tarif => _domicile ? 5000 : 3000;

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) setState(() => _photoPath = file.path);
  }

  Future<void> _ouvrirTicket() async {
    if (_description.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Decrivez votre probleme')),
      );
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() => _loading = false);

    final id =
        'TIC-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    ref.read(ticTicketsProvider.notifier).addTicket(
          TicTicket(
            id: id,
            type: _typeProbleme,
            mode: _domicile
                ? ModeIntervention.domicile
                : ModeIntervention.distance,
            description: _description.text.trim(),
            montant: _tarif,
            statut: StatutTicket.enAttente,
            createdAt: DateTime.now(),
            adresse: _domicile ? _adresse.text.trim() : null,
          ),
        );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ticket #$id ouvert ! Technicien assigne sous 2h.'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
    context.go('/ozel-tic/tickets');
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
        title: const Text('Depannage PC/Mobile',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Type probleme
                const _Label('Type de probleme'),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _typeProbleme,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(
                            value: 'PC ne demarre pas',
                            child: Text('PC ne demarre pas')),
                        DropdownMenuItem(
                            value: 'Virus/malware',
                            child: Text('Virus/malware')),
                        DropdownMenuItem(
                            value: 'Configuration reseau',
                            child: Text('Configuration reseau')),
                        DropdownMenuItem(
                            value: 'Installation logiciel',
                            child: Text('Installation logiciel')),
                        DropdownMenuItem(
                            value: 'Recuperation donnees',
                            child: Text('Recuperation donnees')),
                        DropdownMenuItem(
                            value: 'Autre', child: Text('Autre')),
                      ],
                      onChanged: (v) =>
                          setState(() => _typeProbleme = v!),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Mode intervention
                const _Label('Mode d\'intervention'),
                Row(
                  children: [
                    Expanded(
                      child: _ModeBtn(
                        label: 'A domicile',
                        price: '5 000 FCFA',
                        selected: _domicile,
                        color: _color,
                        onTap: () => setState(() => _domicile = true),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ModeBtn(
                        label: 'A distance',
                        price: '3 000 FCFA',
                        selected: !_domicile,
                        color: _color,
                        onTap: () => setState(() => _domicile = false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Description
                const _Label('Description du probleme'),
                TextField(
                  controller: _description,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Decrivez votre probleme en detail...',
                    filled: true,
                    fillColor: AppColors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Adresse si domicile
                if (_domicile) ...[
                  const _Label('Adresse'),
                  OzelTextField(
                    controller: _adresse,
                    label: 'Ex: Haie Vive, Cotonou',
                    prefixIcon: Icons.place_rounded,
                  ),
                  const SizedBox(height: 14),
                ],

                // Photo
                GestureDetector(
                  onTap: _pickPhoto,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _photoPath != null
                            ? AppColors.success
                            : AppColors.disabled,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _photoPath != null
                              ? Icons.check_circle_rounded
                              : Icons.photo_camera_outlined,
                          color: _photoPath != null
                              ? AppColors.success
                              : AppColors.textSecondary,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _photoPath == null
                              ? 'Photo du probleme (optionnel)'
                              : 'Photo ajoutee',
                          style: TextStyle(
                            color: _photoPath != null
                                ? AppColors.success
                                : AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tarif + bouton
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, -4))
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tarif',
                        style: TextStyle(fontWeight: FontWeight.w800)),
                    Text(Formatters.fcfa(_tarif),
                        style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                            color: Color(0xFF1565C0))),
                  ],
                ),
                const SizedBox(height: 12),
                OzelPrimaryButton(
                  label: _loading ? 'Ouverture...' : 'Ouvrir un ticket',
                  enabled: !_loading,
                  onPressed: _ouvrirTicket,
                ),
              ],
            ),
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

class _ModeBtn extends StatelessWidget {
  const _ModeBtn({
    required this.label,
    required this.price,
    required this.selected,
    required this.color,
    required this.onTap,
  });
  final String label, price;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.06) : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: selected
                  ? color.withValues(alpha: 0.4)
                  : AppColors.disabled),
        ),
        child: Column(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: selected ? color : AppColors.textSecondary,
              size: 18,
            ),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: selected ? color : AppColors.black,
                    fontSize: 12)),
            Text(price,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
