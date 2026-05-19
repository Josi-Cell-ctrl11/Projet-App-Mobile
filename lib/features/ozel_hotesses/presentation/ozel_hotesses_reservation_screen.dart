import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/hotesse_model.dart';
import '../../../shared/models/hotesse_reservation.dart';
import '../application/ozel_hotesses_notifier.dart';

/// Formulaire reservation hotesse.
class OzelHotessesReservationScreen extends ConsumerStatefulWidget {
  const OzelHotessesReservationScreen({super.key, required this.hotesse});
  final HotesseModel hotesse;

  @override
  ConsumerState<OzelHotessesReservationScreen> createState() =>
      _OzelHotessesReservationScreenState();
}

class _OzelHotessesReservationScreenState
    extends ConsumerState<OzelHotessesReservationScreen> {
  static const Color _color = Color(0xFFAD1457);

  DateTime? _dateDebut;
  double _dureeHeures = 8;
  String _typeEvenement = 'Conference';
  String _tenue = 'Formelle';
  String _langue = 'FR';
  double _nbInvites = 30;
  bool _nuitOuSpeciale = false;
  bool _loading = false;

  double get _tarif => calculerTarifHotesse(
        dureeHeures: _dureeHeures.round(),
        nuitOuSpeciale: _nuitOuSpeciale,
        langueEN: _langue == 'EN',
      );

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 3)),
      firstDate: DateTime.now().add(const Duration(days: 3)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx)
            .copyWith(colorScheme: const ColorScheme.light(primary: _color)),
        child: child!,
      ),
    );
    if (d != null) setState(() => _dateDebut = d);
  }

  Future<void> _confirmer() async {
    if (_dateDebut == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choisissez une date')),
      );
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() => _loading = false);

    final id = 'HR-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    ref.read(hotessesReservationsProvider.notifier).addReservation(
          HotesseReservation(
            id: id,
            hotesseId: widget.hotesse.id,
            hotessePrenom: widget.hotesse.prenom,
            dateDebut: _dateDebut!,
            dureeHeures: _dureeHeures.round(),
            tarif: _tarif,
            statut: StatutHotesseReservation.confirmee,
            typeEvenement: _typeEvenement,
          ),
        );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Reservation confirmee ! ${widget.hotesse.prenom} sera presente.'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
    context.go('/ozel-hotesses/reservations');
  }

  @override
  Widget build(BuildContext context) {
    final h = widget.hotesse;
    final deuxHotessesMin = _nbInvites > 50;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: _color,
        foregroundColor: AppColors.white,
        title: Text('Reserver ${h.prenom}',
            style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Info hotesse
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _color.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: _color.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: _color.withValues(alpha: 0.2),
                        child: Text(h.initiales,
                            style: TextStyle(
                                color: _color,
                                fontWeight: FontWeight.w800,
                                fontSize: 18)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(h.prenom,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15)),
                            Text(
                                '${h.taille} • ${h.langues.join(', ')} • ${h.experience} ans exp.',
                                style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12)),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 14, color: Colors.amber),
                          Text(' ${h.note}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Date
                _Label('Date de debut'),
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
                            color: _color, size: 20),
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
                const SizedBox(height: 14),

                // Duree
                _Label(
                    'Duree : ${_dureeHeures.round()}h (minimum 4h)'),
                Slider(
                  value: _dureeHeures,
                  min: 4,
                  max: 24,
                  divisions: 20,
                  activeColor: _color,
                  inactiveColor: _color.withValues(alpha: 0.15),
                  label: '${_dureeHeures.round()}h',
                  onChanged: (v) => setState(() => _dureeHeures = v),
                ),
                const SizedBox(height: 14),

                // Type evenement
                _Label('Type d\'evenement'),
                _Dropdown(
                  value: _typeEvenement,
                  items: const [
                    'Conference',
                    'Mariage',
                    'Anniversaire',
                    'Seminaire',
                    'Autre'
                  ],
                  onChanged: (v) => setState(() => _typeEvenement = v!),
                ),
                const SizedBox(height: 14),

                // Tenue
                _Label('Tenue souhaitee'),
                _Dropdown(
                  value: _tenue,
                  items: h.tenues,
                  onChanged: (v) => setState(() => _tenue = v!),
                ),
                const SizedBox(height: 14),

                // Langue
                _Label('Langue requise'),
                Row(
                  children: ['FR', 'EN'].map((l) {
                    final sel = l == _langue;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _langue = l),
                        child: Container(
                          margin: EdgeInsets.only(
                              right: l == 'FR' ? 8 : 0),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: sel
                                ? _color.withValues(alpha: 0.08)
                                : AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: sel
                                    ? _color.withValues(alpha: 0.4)
                                    : AppColors.disabled),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (sel)
                                Icon(Icons.check_circle_rounded,
                                    color: _color, size: 16),
                              if (sel) const SizedBox(width: 6),
                              Text(l == 'FR' ? 'Francais' : 'Anglais (+5 000 FCFA)',
                                  style: TextStyle(
                                      fontWeight: sel
                                          ? FontWeight.w700
                                          : FontWeight.w400,
                                      color: sel ? _color : AppColors.black,
                                      fontSize: 13)),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),

                // Nb invites
                _Label('Nombre d\'invites : ${_nbInvites.round()}'),
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
                if (deuxHotessesMin)
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            color: AppColors.warning, size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '2 hotesses minimum pour un evenement de plus de 50 personnes.',
                            style: TextStyle(
                                color: AppColors.warning, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Nuit/speciale
                SwitchListTile(
                  title: const Text('Nuit ou tenue speciale (+50%)',
                      style: TextStyle(fontSize: 14)),
                  value: _nuitOuSpeciale,
                  onChanged: (v) => setState(() => _nuitOuSpeciale = v),
                  activeColor: _color,
                ),
              ],
            ),
          ),

          // Recap tarif
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
                    const Text('Tarif total',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 15)),
                    Text(Formatters.fcfa(_tarif),
                        style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                            color: Color(0xFFAD1457))),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: _loading ? null : _confirmer,
                    style: FilledButton.styleFrom(
                      backgroundColor: _color,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      _loading ? 'Confirmation...' : 'Confirmer la reservation',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15),
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

class _Dropdown extends StatelessWidget {
  const _Dropdown(
      {required this.value,
      required this.items,
      required this.onChanged});
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : items.first,
          isExpanded: true,
          items: items
              .map((i) => DropdownMenuItem(value: i, child: Text(i)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
