import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../../../core/theme/app_colors.dart";
import "../../../shared/widgets/ozel_button.dart";
import "../application/auth_session.dart";

/// Onboarding 3 slides style Gozem/Yango — AVANT le login.
/// Slide 1 : Bienvenue sur OZELSERVICES
/// Slide 2 : Commandez, livrez, gerez
/// Slide 3 : Payez facilement → bouton "Commencer" → Login
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(authSessionProvider.notifier).setOnboardingCompleted();
    if (!mounted) return;
    context.go("/login");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Bouton "Passer" en haut a droite
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 16, top: 8),
                child: TextButton(
                  onPressed: _finish,
                  child: const Text(
                    "Passer",
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            // Slides
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _index = i),
                children: const [
                  _Slide(
                    emoji: "🇧🇯",
                    icon: Icons.apps_rounded,
                    color: AppColors.primary,
                    title: "Bienvenue sur OZELSERVICES",
                    subtitle:
                        "La super-app du Benin. Tous les services du quotidien en 1 clic.",
                    bgColor: Color(0xFFFFF3EE),
                  ),
                  _Slide(
                    emoji: "🚀",
                    icon: Icons.local_shipping_rounded,
                    color: Color(0xFF1565C0),
                    title: "Commandez, livrez, gerez",
                    subtitle:
                        "OzelFoods pour vos repas, Rapid Colis pour vos envois. Rapide, fiable, local.",
                    bgColor: Color(0xFFE8F0FE),
                  ),
                  _Slide(
                    emoji: "💳",
                    icon: Icons.account_balance_wallet_rounded,
                    color: Color(0xFF2E7D32),
                    title: "Payez facilement",
                    subtitle:
                        "MoMo MTN, Moov Money, Visa via OzelWallet. Cumulez des points a chaque depense.",
                    bgColor: Color(0xFFE8F5E9),
                  ),
                ],
              ),
            ),

            // Indicateurs
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                final active = i == _index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.all(4),
                  width: active ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active ? AppColors.primary : AppColors.disabled,
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              }),
            ),

            const SizedBox(height: 20),

            // Bouton
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: OzelPrimaryButton(
                label: _index == 2 ? "Commencer" : "Suivant",
                onPressed: () {
                  if (_index < 2) {
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOut,
                    );
                  } else {
                    _finish();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  const _Slide({
    required this.emoji,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.bgColor,
  });

  final String emoji;
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icone dans un cercle colore
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 36)),
                  const SizedBox(height: 4),
                  Icon(icon, size: 40, color: color),
                ],
              ),
            ),
          ),
          const SizedBox(height: 36),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppColors.black,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
