import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/payment/fedapay_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';

/// Ecran paiement acompte Ozel Event.
class OzelEventPaiementScreen extends ConsumerStatefulWidget {
  const OzelEventPaiementScreen({super.key, required this.data});
  final Map<String, dynamic> data;

  @override
  ConsumerState<OzelEventPaiementScreen> createState() =>
      _OzelEventPaiementScreenState();
}

class _OzelEventPaiementScreenState
    extends ConsumerState<OzelEventPaiementScreen> {
  static const Color _color = Color(0xFF6A1B9A);
  PaymentMethod _method = PaymentMethod.mtnMomo;
  bool _loading = false;

  Future<void> _payer() async {
    setState(() => _loading = true);
    final res = await FedaPayService()
        .pay(amountFcfa: widget.data['acompte'] as double, method: _method);
    setState(() => _loading = false);
    if (!mounted || !res.success) return;
    context.pushReplacement('/ozel-event/confirmation', extra: widget.data);
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final acompte = data['acompte'] as double;
    final services = (data['services'] as List).cast<String>();
    final date = data['date'] as DateTime?;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: _color,
        foregroundColor: AppColors.white,
        title: const Text('Paiement acompte',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Recap
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Recapitulatif',
                    style: TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 15)),
                const SizedBox(height: 12),
                _Row('Type', data['type'] as String),
                if (date != null)
                  _Row('Date',
                      '${date.day}/${date.month}/${date.year}'),
                _Row('Lieu', data['lieu'] as String? ?? '—'),
                _Row('Invites', '${data['nbInvites']} personnes'),
                _Row('Services', services.join(', ')),
                const Divider(height: 20),
                _Row('Total TTC',
                    Formatters.fcfa(data['total'] as double)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Montant acompte
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6A1B9A), Color(0xFF4A148C)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text('Acompte a payer (50%)',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 6),
                Text(Formatters.fcfa(acompte),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Moyen de paiement
          const Text('Moyen de paiement',
              style: TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 10),
          ...PaymentMethod.values.map((m) {
            final sel = m == _method;
            return GestureDetector(
              onTap: () => setState(() => _method = m),
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
                    Icon(Icons.phone_android_rounded,
                        color: sel ? _color : AppColors.textSecondary),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Text(m.labelFr,
                            style: TextStyle(
                                fontWeight: sel
                                    ? FontWeight.w700
                                    : FontWeight.w400))),
                    if (sel)
                      const Icon(Icons.check_circle_rounded,
                          color: Color(0xFF6A1B9A)),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 12),

          // Message legal
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: Colors.red.withValues(alpha: 0.25)),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: Colors.red, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '0 acompte = 0 reservation. Le paiement confirme votre evenement.',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: _loading ? null : _payer,
              style: FilledButton.styleFrom(
                backgroundColor: _color,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                _loading
                    ? 'Paiement...'
                    : 'Payer l\'acompte ${Formatters.fcfa(acompte)}',
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);
  final String label, value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13)),
          ),
          Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13))),
        ],
      ),
    );
  }
}
