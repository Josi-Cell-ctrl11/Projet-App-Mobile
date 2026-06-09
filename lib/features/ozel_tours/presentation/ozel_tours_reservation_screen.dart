import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/payment/fedapay_webview_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/circuit_model.dart';
import '../../../shared/models/tour_reservation.dart';
import '../application/ozel_tours_notifier.dart';

/// Formulaire reservation circuit Ozel Tours.
class OzelToursReservationScreen extends ConsumerStatefulWidget {
  const OzelToursReservationScreen({super.key, required this.circuit});
  final CircuitModel circuit;

  @override
  ConsumerState<OzelToursReservationScreen> createState() =>
      _OzelToursReservationScreenState();
}

class _OzelToursReservationScreenState
    extends ConsumerState<OzelToursReservationScreen> {
  static const Color _color = Color(0xFF00695C);

  DateTime? _dateDepart;
  double _nbPersonnes = 1;
  bool _guideEN = false;
  bool _loading = false;

  double get _total =>
      widget.circuit.prix * _nbPersonnes +
      (_guideEN ? 10000 * _nbPersonnes : 0);

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now().add(const Duration(days: 2)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx)
            .copyWith(colorScheme: const ColorScheme.light(primary: _color)),
        child: child!,
      ),
    );
    if (d != null) setState(() => _dateDepart = d);
  }

  Future<void> _payer() async {
    if (_dateDepart == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choisissez une date de depart')),
      );
      return;
    }
    setState(() => _loading = true);
    final paid = await lancerPaiementFedaPay(
      context: context,
      montant: _total,
      description: "Ozel Tours — ${widget.circuit.nom}",
      customerName: "Client Ozel",
      customerPhone: "",
      customerEmail: "",
    );
    setState(() => _loading = false);
    if (!mounted || !paid) return;

    final id =
        'TR-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    final reservation = TourReservation(
      id: id,
      circuitId: widget.circuit.id,
      circuitNom: widget.circuit.nom,
      destination: widget.circuit.destination,
      dateDepart: _dateDepart!,
      nbPersonnes: _nbPersonnes.round(),
      montant: _total,
      qrCode: 'OZEL-$id-${widget.circuit.destination.toUpperCase()}',
      statut: StatutTourReservation.confirmee,
      guide: widget.circuit.guide,
    );
    ref.read(toursReservationsProvider.notifier).addReservation(reservation);
    if (!mounted) return;
    context.pushReplacement('/ozel-tours/ebillet', extra: reservation);
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.circuit;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: _color,
        foregroundColor: AppColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Reserver — ${c.destination}',
            style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Info circuit
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
                      Text(c.emoji,
                          style: const TextStyle(fontSize: 32)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.nom,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14)),
                            Text(
                                '${c.dureeJours} jour${c.dureeJours > 1 ? 's' : ''} • Guide: ${c.guide}',
                                style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Date depart
                _Label('Date de depart'),
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
                        const Icon(Icons.flight_takeoff_rounded,
                            color: _color, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          _dateDepart == null
                              ? 'Choisir une date'
                              : '${_dateDepart!.day}/${_dateDepart!.month}/${_dateDepart!.year}',
                          style: TextStyle(
                            color: _dateDepart == null
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

                // Nb personnes
                _Label(
                    'Nombre de personnes : ${_nbPersonnes.round()}'),
                Slider(
                  value: _nbPersonnes,
                  min: 1,
                  max: 20,
                  divisions: 19,
                  activeColor: _color,
                  inactiveColor: _color.withValues(alpha: 0.15),
                  label: '${_nbPersonnes.round()} pers.',
                  onChanged: (v) => setState(() => _nbPersonnes = v),
                ),
                const SizedBox(height: 14),

                // Options
                _Label('Options'),
                SwitchListTile(
                  title: const Text('Guide anglophone (+10 000 FCFA/pers)',
                      style: TextStyle(fontSize: 14)),
                  value: _guideEN,
                  onChanged: (v) => setState(() => _guideEN = v),
                  activeColor: _color,
                ),
                if (c.assuranceIncluse)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.shield_rounded,
                            color: AppColors.success, size: 16),
                        SizedBox(width: 8),
                        Text('Assurance voyage incluse',
                            style: TextStyle(
                                color: AppColors.success,
                                fontWeight: FontWeight.w600,
                                fontSize: 13)),
                      ],
                    ),
                  ),

                // Badge Points x2
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.amber.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    children: [
                      Text('⭐', style: TextStyle(fontSize: 16)),
                      SizedBox(width: 8),
                      Text('Points Ozel x2 credites apres le circuit !',
                          style: TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.w600,
                              fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Total + bouton payer
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
                    const Text('Total',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 15)),
                    Text(Formatters.fcfa(_total),
                        style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                            color: Color(0xFF00695C))),
                  ],
                ),
                const SizedBox(height: 4),
                const Text('Paiement 100% immediat — pas d\'acompte',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 11)),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: _loading ? null : _payer,
                    style: FilledButton.styleFrom(
                      backgroundColor: _color,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.payment_rounded),
                    label: Text(
                      _loading
                          ? 'Paiement...'
                          : 'Payer ${Formatters.fcfa(_total)}',
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
