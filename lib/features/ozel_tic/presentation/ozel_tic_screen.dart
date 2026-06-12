import "package:flutter/material.dart";
import "../../../shared/widgets/coming_soon_screen.dart";

/// Ecran OzelTic — Bientot disponible
class OzelTicScreen extends StatelessWidget {
  const OzelTicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonScreen(
      color: Color(0xFF1565C0),
      icon: Icons.devices_rounded,
      title: "OzelTic",
      description:
          "Depannage informatique, developpement web et mobile, "
          "formation numerique a domicile.",
    );
  }
}
