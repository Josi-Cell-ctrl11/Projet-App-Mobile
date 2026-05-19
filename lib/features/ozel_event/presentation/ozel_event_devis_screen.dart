import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../application/ozel_event_notifier.dart';

/// Formulaire de devis automatique Ozel Event.
class OzelEventDevisScreen extends StatefulWidget {
  const OzelEventDevisScreen({super.key, this.typeInitial});
  final String? typeInitial;

  @override
  State<OzelEventDevisScreen> createState() => _OzelEventDevisScreenState();
}

class _OzelEventDevisScreenState extends State<OzelEventDevisScreen> {
  static const Color _color = Color(0xFF6A1B9A);

  String _type = 'mariage';
  DateTime? _date;
  final _lieu = TextEditingController();
  double _nbInvites = 50;
  bool _sono = false;
  bool _traiteur = false;
  bool _deco = false;

  bool get _chefProjetAuto => _nbInvites > 100;

  double get _total => calculerDevisEvent(
        nbInvites: _nbInvites.round(),
        sono: _sono,
        traiteur: _traiteur,
        deco: _deco,
      );

  double get _acompte => _total * 0.5;

  @override
  void initState() {
    super.initState();
    if (widget.typeInitial != null) _type = widget.typeInitial!;
  }

  @override
  void dispose() {
    _lieu.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now().add(const Duration(days: 7)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: _color),
        ),
        child: child!,
      ),
    );
    if (d != null) setState(() => _date = d);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: _color,
        foregroundColor: AppColors.white,
        title: const Text('Devis evenement',
            style: TextStyle(fontWeight: FontWeight.w800)),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Type evenement
                _Label('Type d\'evenement'),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _type,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(
                            value: 'mariage', child: Text('🎊 Mariage')),
                        DropdownMenuItem(
                            value: 'anniversaire',
                            child: Text('🎂 Anniversaire / Bapteme')),
                        DropdownMenuItem(
                            value: 'conference',
                            child: Text('💼 Conference / Seminaire')),
                      ],
                      onChanged: (v) => setState(() => _type = v!),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Date
                _Label('Date de l\'evenement'),
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded,
                            color: _color, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          _date == null
                              ? 'Choisir une date'
                              : '${_date!.day}/${_date!.month}/${_date!.year}',
                          style: TextStyle(
                            color: _date == null
                                ? AppColors.textSecondary
                                : AppColors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Lieu
                _Label('Lieu de l\'evenement'),
                TextField(
                  controller: _lieu,
                  decoration: InputDecoration(
                    hintText: 'Ex: Salle Prestige, Cotonou',
                    filled: true,
                    fillColor: AppColors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon:
                        const Icon(Icons.place_rounded, color: _color),
                  ),
                ),
                const SizedBox(height: 14),

                // Nb invites
                _Label(
                    'Nombre d\'invites : ${_nbInvites.round()}'),
                Slider(
                  value: _nbInvites,
                  min: 10,
                  max: 500,
                  divisions: 49,
                  activeColor: _color,
                  inactiveColor: _color.withValues(alpha: 0.15),
                  label: '${_nbInvites.round()} invites',
                  onChanged: (v) => setState(() => _nbInvites = v),
                ),
                if (_chefProjetAuto)
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _color.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline_rounded,
                            color: Color(0xFF6A1B9A), size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Chef projet OZEL inclus automatiquement (>100 invites)',
                            style: TextStyle(
                                color: Color(0xFF6A1B9A), fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 14),

                // Services
                _Label('Services souhaites'),
                _CheckService(
                  label: 'Sonorisation',
                  price: '1 000 FCFA/pers',
                  value: _sono,
                  color: _color,
                  onChanged: (v) => setState(() => _sono = v!),
                ),
                _CheckService(
                  label: 'Traiteur',
                  price: '3 500 FCFA/pers',
                  value: _traiteur,
                  color: _color,
                  onChanged: (v) => setState(() => _traiteur = v!),
                ),
                _CheckService(
                  label: 'Decoration',
                  price: '2 000 FCFA/pers',
                  value: _deco,
                  color: _color,
                  onChanged: (v) => setState(() => _deco = v!),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // ── Recap devis en bas ─────────────────────────────────────────────
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
                    const Text('Sous-total',
                        style: TextStyle(color: AppColors.textSecondary)),
                    Text(Formatters.fcfa(_total / 1.2)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Commission OZEL (20%)',
                        style: TextStyle(color: AppColors.textSecondary)),
                    Text(Formatters.fcfa(_total - _total / 1.2)),
                  ],
                ),
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total TTC',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 15)),
                    Text(Formatters.fcfa(_total),
                        style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            color: Color(0xFF6A1B9A))),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: _total > 0
                        ? () {
                            final services = <String>[];
                            if (_sono) services.add('Sonorisation');
                            if (_traiteur) services.add('Traiteur');
                            if (_deco) services.add('Decoration');
                            if (_chefProjetAuto)
                              services.add('Chef projet');
                            context.push('/ozel-event/paiement', extra: {
                              'type': _type,
                              'date': _date,
                              'lieu': _lieu.text,
                              'nbInvites': _nbInvites.round(),
                              'services': services,
                              'total': _total,
                              'acompte': _acompte,
                              'chefProjet': _chefProjetAuto,
                            });
                          }
                        : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: _color,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      'Confirmer et payer l\'acompte (${Formatters.fcfa(_acompte)})',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
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

class _CheckService extends StatelessWidget {
  const _CheckService(
      {required this.label,
      required this.price,
      required this.value,
      required this.color,
      required this.onChanged});
  final String label, price;
  final bool value;
  final Color color;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: value ? color.withValues(alpha: 0.06) : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: value ? color.withValues(alpha: 0.3) : AppColors.disabled),
      ),
      child: CheckboxListTile(
        value: value,
        onChanged: onChanged,
        activeColor: color,
        title: Text(label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(price,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 12)),
        controlAffinity: ListTileControlAffinity.leading,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
