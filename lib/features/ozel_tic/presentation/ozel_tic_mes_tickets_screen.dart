import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/tic_ticket.dart';
import '../../../shared/models/tic_devis.dart';
import '../application/ozel_tic_notifier.dart';

/// Liste tickets et devis OzelTic.
class OzelTicMesTicketsScreen extends ConsumerStatefulWidget {
  const OzelTicMesTicketsScreen({super.key});

  @override
  ConsumerState<OzelTicMesTicketsScreen> createState() =>
      _OzelTicMesTicketsScreenState();
}

class _OzelTicMesTicketsScreenState
    extends ConsumerState<OzelTicMesTicketsScreen>
    with SingleTickerProviderStateMixin {
  static const Color _color = Color(0xFF1565C0);
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Color _statutTicketColor(StatutTicket s) => switch (s) {
        StatutTicket.enAttente => AppColors.warning,
        StatutTicket.assigne => _color,
        StatutTicket.enCours => AppColors.primary,
        StatutTicket.resolu => AppColors.success,
      };

  Color _statutDevisColor(StatutDevis s) => switch (s) {
        StatutDevis.enAttente => AppColors.warning,
        StatutDevis.enEtude => _color,
        StatutDevis.accepte => AppColors.success,
        StatutDevis.refuse => Colors.red,
      };

  @override
  Widget build(BuildContext context) {
    final tickets = ref.watch(ticTicketsProvider);
    final devis = ref.watch(ticDevisProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: _color,
        foregroundColor: AppColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Mes tickets',
            style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => context.push('/ozel-tic/depannage'),
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: AppColors.white,
          labelColor: AppColors.white,
          unselectedLabelColor: Colors.white60,
          tabs: [
            Tab(text: 'Tickets (${tickets.length})'),
            Tab(text: 'Devis (${devis.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          // Onglet Tickets
          tickets.isEmpty
              ? const Center(
                  child: Text('Aucun ticket',
                      style: TextStyle(color: AppColors.textSecondary)))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: tickets.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final t = tickets[i];
                    final sc = _statutTicketColor(t.statut);
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2))
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(t.type,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: sc.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(t.statutLabel,
                                    style: TextStyle(
                                        color: sc,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(t.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _Chip(Icons.phone_android_rounded,
                                  t.modeLabel),
                              const SizedBox(width: 12),
                              if (t.technicien != null)
                                _Chip(Icons.person_rounded,
                                    t.technicien!),
                              const Spacer(),
                              Text(Formatters.fcfa(t.montant),
                                  style: TextStyle(
                                      color: _color,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13)),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),

          // Onglet Devis
          devis.isEmpty
              ? const Center(
                  child: Text('Aucun devis',
                      style: TextStyle(color: AppColors.textSecondary)))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: devis.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final d = devis[i];
                    final sc = _statutDevisColor(d.statut);
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(d.typeProjet,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: sc.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(d.statutLabel,
                                    style: TextStyle(
                                        color: sc,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(d.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _Chip(Icons.schedule_rounded, d.delai),
                              const Spacer(),
                              Text(
                                  'Budget : ${Formatters.fcfa(d.budget)}',
                                  style: TextStyle(
                                      color: _color,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.icon, this.label);
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 11)),
      ],
    );
  }
}
