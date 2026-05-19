import "package:flutter/material.dart";
import "../../ozel_event/presentation/ozel_event_screen.dart";

/// Ecran Ozel Hotesses — Bientot disponible
class OzelHotessesScreen extends StatelessWidget {
  const OzelHotessesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ComingSoonScreen(
      color: Color(0xFFAD1457),
      icon: Icons.support_agent_rounded,
      title: "Ozel Hotesses",
      description:
          "Reservation d'hotesses et agents d'accueil pour vos evenements "
          "professionnels et prives.",
    );
  }
}
