import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../core/theme/app_colors.dart";
import "../../../core/utils/formatters.dart";
import "../../../shared/models/ozel_event_reservation.dart";
import "../data/ozel_event_mock_data.dart";

/// Écran des réservations Ozel Event
class OzelEventMesReservationsScreen extends ConsumerWidget {
  const OzelEventMesReservationsScreen({super.key});

  static const Color _color = Color(0xFF6A1B9A);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: _color,
        foregroundColor: AppColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        title: const Text(
          "Mes demandes",
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: OzelEventMockData.reservations.length,
        itemBuilder: (context, index) {
          final reservation = OzelEventMockData.reservations[index];
          return _ReservationCard(reservation: reservation);
        },
      ),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  const _ReservationCard({required this.reservation});

  final OzelEventReservation reservation;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                reservation.type,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              _StatusBadge(reservation.statut),
            ],
          ),

          const SizedBox(height: 12),

          // Détails
          _DetailRow("Date",
              "${reservation.dateEvenement.day}/${reservation.dateEvenement.month}/${reservation.dateEvenement.year}"),
          _DetailRow("Lieu", reservation.lieu),
          _DetailRow("Invités", "${reservation.nbInvites} personnes"),
          _DetailRow("Services", reservation.servicesChoisis.join(", ")),

          const SizedBox(height: 12),

          const Divider(),

          const SizedBox(height: 12),

          // WhatsApp contact info
          Row(
            children: [
              Icon(Icons.chat_rounded,
                  size: 16, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(
                "Contact WhatsApp sous 2h",
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          if (reservation.chefProjetAssigne != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person_rounded,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  "Chef projet: ${reservation.chefProjetAssigne}",
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge(this.statut);

  final EventReservationStatut statut;

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (statut) {
      case EventReservationStatut.enAttente:
        color = AppColors.warning;
        label = "En attente";
        break;
      case EventReservationStatut.confirme:
        color = AppColors.success;
        label = "Confirmé";
        break;
      case EventReservationStatut.enCours:
        color = const Color(0xFF1565C0);
        label = "En cours";
        break;
      case EventReservationStatut.termine:
        color = AppColors.textSecondary;
        label = "Terminé";
        break;
      case EventReservationStatut.annule:
        color = Colors.red;
        label = "Annulé";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
