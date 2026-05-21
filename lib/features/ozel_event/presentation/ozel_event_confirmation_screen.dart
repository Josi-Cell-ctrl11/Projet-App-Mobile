import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/receipt_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/ozel_event_reservation.dart';
import '../application/ozel_event_notifier.dart';

/// Ecran confirmation reservation Ozel Event.
class OzelEventConfirmationScreen extends ConsumerStatefulWidget {
  const OzelEventConfirmationScreen({super.key, required this.data});
  final Map<String, dynamic> data;

  @override
  ConsumerState<OzelEventConfirmationScreen> createState() =>
      _OzelEventConfirmationScreenState();
}

class _OzelEventConfirmationScreenState
    extends ConsumerState<OzelEventConfirmationScreen>
    with SingleTickerProviderStateMixin {
  static const Color _color = Color(0xFF6A1B9A);
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late String _numReservation;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _ctrl.forward();

    // Generer numero reservation
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    _numReservation = 'OE-${id.substring(id.length - 6)}';

    // Sauvegarder la reservation
    final data = widget.data;
    final services = (data['services'] as List).cast<String>();
    final type = switch (data['type'] as String) {
      'mariage' => TypeEvenement.mariage,
      'anniversaire' => TypeEvenement.anniversaire,
      _ => TypeEvenement.conference,
    };
    ref.read(ozelEventProvider.notifier).addReservation(
          OzelEventReservation(
            id: _numReservation,
            type: type,
            dateEvenement:
                data['date'] as DateTime? ?? DateTime.now().add(const Duration(days: 30)),
            lieu: data['lieu'] as String? ?? '',
            nbInvites: data['nbInvites'] as int? ?? 0,
            servicesChoisis: services,
            montantTotal: data['total'] as double,
            acompte: data['acompte'] as double,
            soldeRestant: (data['total'] as double) - (data['acompte'] as double),
            statut: StatutReservation.confirme,
            chefProjetAssigne: data['chefProjet'] as bool? ?? false,
            createdAt: DateTime.now(),
          ),
        );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final services = (data['services'] as List).cast<String>();
    final date = data['date'] as DateTime?;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: _color,
        foregroundColor: AppColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go('/accueil'),
        ),
        title: const Text('Reservation confirmee',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 16),
          // Icone check anime
          Center(
            child: ScaleTransition(
              scale: _scale,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded,
                    color: AppColors.success, size: 56),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text('Reservation confirmee !',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.black)),
          ),
          const SizedBox(height: 8),
          Center(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '#$_numReservation',
                style: const TextStyle(
                    color: Color(0xFF6A1B9A),
                    fontWeight: FontWeight.w800,
                    fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 24),

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
                const Text('Details de votre evenement',
                    style: TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 15)),
                const SizedBox(height: 12),
                if (date != null)
                  _InfoRow(Icons.calendar_today_rounded, 'Date',
                      '${date.day}/${date.month}/${date.year}'),
                _InfoRow(Icons.place_rounded, 'Lieu',
                    data['lieu'] as String? ?? '—'),
                _InfoRow(Icons.people_rounded, 'Invites',
                    '${data['nbInvites']} personnes'),
                _InfoRow(Icons.checklist_rounded, 'Services',
                    services.join(', ')),
                if (data['chefProjet'] == true)
                  _InfoRow(Icons.manage_accounts_rounded, 'Chef projet',
                      'Assigne par OZEL'),
                const Divider(height: 20),
                _InfoRow(Icons.payments_rounded, 'Acompte paye',
                    Formatters.fcfa(data['acompte'] as double)),
                _InfoRow(Icons.account_balance_wallet_rounded,
                    'Solde restant (J-2)',
                    Formatters.fcfa((data['total'] as double) -
                        (data['acompte'] as double))),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Message
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _color.withValues(alpha: 0.2)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded,
                    color: Color(0xFF6A1B9A), size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Notre equipe vous contactera J-7 avant l\'evenement pour le check-list final.',
                    style: TextStyle(
                        color: Color(0xFF6A1B9A), fontSize: 13, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: () => context.go('/ozel-event/reservations'),
              style: FilledButton.styleFrom(
                backgroundColor: _color,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.list_alt_rounded),
              label: const Text('Voir mes evenements',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ),
          const SizedBox(height: 10),
          // Bouton recu PDF
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () {
                final d = widget.data;
                final services =
                    (d['services'] as List).cast<String>();
                ReceiptService.generateAndShowReceipt(
                  numeroCommande: _numReservation,
                  typeService: 'Ozel Event',
                  nomClient: 'Client OZELSERVICES',
                  dateCommande: DateTime.now()
                      .toString()
                      .substring(0, 16),
                  lignes: [
                    {
                      'description': 'Services : ${services.join(', ')}',
                      'montant': (d['acompte'] as double)
                          .toStringAsFixed(0),
                    },
                  ],
                  total: d['acompte'] as double,
                  modePaiement: 'MoMo / FedaPay',
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: _color,
                side: const BorderSide(color: Color(0xFF6A1B9A)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.picture_as_pdf_rounded),
              label: const Text('Telecharger le recu PDF',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: () => context.go('/accueil'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _color,
                side: const BorderSide(color: Color(0xFF6A1B9A)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Retour a l\'accueil',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.icon, this.label, this.value);
  final IconData icon;
  final String label, value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF6A1B9A)),
          const SizedBox(width: 10),
          SizedBox(
            width: 100,
            child: Text(label,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
