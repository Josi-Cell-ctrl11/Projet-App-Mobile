import "package:flutter/material.dart";

import "../../../shared/widgets/coming_soon_screen.dart";

/// Ecran Ozel Event — Bientot disponible
class OzelEventScreen extends StatelessWidget {
  const OzelEventScreen({super.key});

  static const Color _color = Color(0xFF6A1B9A);

  @override
  Widget build(BuildContext context) {
    return const ComingSoonScreen(
      color: _color,
      icon: Icons.event_available_rounded,
      title: "Ozel Event",
      description:
          "Organisation d'evenements cle en main au Benin. "
          "Mariages, baptemes, conferences, soirees. "
          "Tout est pris en charge.",
    );
  }
}
