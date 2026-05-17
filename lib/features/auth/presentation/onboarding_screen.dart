import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../../../core/theme/app_colors.dart";
import "../../../shared/widgets/ozel_button.dart";
import "../application/auth_session.dart";

/// Onboarding 3 slides : présentation des services OZELSERVICES.
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
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: _finish,
            child: const Text("Passer"),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _controller,
              onPageChanged: (i) => setState(() => _index = i),
              children: const [
                _Slide(
                  icon: Icons.restaurant_menu_rounded,
                  title: "OzelFoods",
                  subtitle:
                      "Commandez vos plats préférés auprès des meilleurs restaurants du Bénin.",
                ),
                _Slide(
                  icon: Icons.local_shipping_rounded,
                  title: "Rapid Colis",
                  subtitle:
                      "Envoyez vos colis en toute confiance avec suivi et tarification transparente.",
                ),
                _Slide(
                  icon: Icons.account_balance_wallet_rounded,
                  title: "OzelWallet",
                  subtitle:
                      "Payez en MoMo, Moov, Visa ou espèces — cumulez des points Ozel à chaque dépense.",
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (i) {
              final active = i == _index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.all(4),
                width: active ? 22 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : AppColors.disabled,
                  borderRadius: BorderRadius.circular(8),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
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
    );
  }
}

class _Slide extends StatelessWidget {
  const _Slide({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 64, color: AppColors.primary),
          ),
          const SizedBox(height: 28),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              height: 1.35,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
