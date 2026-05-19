import "package:flutter/material.dart";
import "../../ozel_event/presentation/ozel_event_screen.dart";

/// Ecran Ozel Tours — Bientot disponible
class OzelToursScreen extends StatelessWidget {
  const OzelToursScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ComingSoonScreen(
      color: Color(0xFF00695C),
      icon: Icons.tour_rounded,
      title: "Ozel Tours",
      description:
          "Decouvrez le Benin autrement. Circuits touristiques, "
          "reservations hotels, guides locaux.",
    );
  }
}
