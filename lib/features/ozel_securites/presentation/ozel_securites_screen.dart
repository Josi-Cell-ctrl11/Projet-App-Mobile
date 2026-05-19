import "package:flutter/material.dart";
import "../../ozel_event/presentation/ozel_event_screen.dart";

/// Ecran Ozel Securites — Bientot disponible
class OzelSecuritesScreen extends StatelessWidget {
  const OzelSecuritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ComingSoonScreen(
      color: Color(0xFF37474F),
      icon: Icons.security_rounded,
      title: "Ozel Securites",
      description:
          "Services de securite privee et entretien d'espaces verts "
          "pour particuliers et entreprises.",
    );
  }
}
