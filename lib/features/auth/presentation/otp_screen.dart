import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:uuid/uuid.dart";

import "../../../core/constants/app_constants.dart";
import "../../../core/theme/app_colors.dart";
import "../../../shared/models/app_user.dart";
import "../../../shared/widgets/ozel_button.dart";
import "../../../shared/widgets/ozel_text_field.dart";
import "../application/auth_session.dart";

/// Vérification OTP (mock : tout code à 6 chiffres est accepté).
class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key, required this.phone});

  final String phone;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _code = TextEditingController(text: "123456");

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final otp = _code.text.trim();
    if (otp.length != 6 || int.tryParse(otp) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Saisissez un code OTP à 6 chiffres.")),
      );
      return;
    }
    // MVP : pas d’appel API — on restaure ou crée un utilisateur minimal.
    final existing = ref.read(authSessionProvider).user;
    final user = existing ??
        AppUser(
          id: Uuid().v4(),
          name: "Client Ozel",
          phone: widget.phone,
          email: "client@ozelservices.bj",
          walletBalanceFcfa: 15000,
          ozelPoints: 1200,
        );
    await ref.read(authSessionProvider.notifier).saveUser(user);
    if (!mounted) return;
    context.go("/accueil");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Code OTP")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            "Code envoyé au\n${widget.phone}",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            "Règle MVP : tout code à 6 chiffres fonctionne. "
            "En production, intégrer SMS / WhatsApp / Firebase Auth.",
            style: TextStyle(color: AppColors.textSecondary, height: 1.35),
          ),
          const SizedBox(height: 8),
          Text(
            "Points Ozel : 1 FCFA dépensé = 1 point (arrondi). "
            "Voir constantes : ${AppConstants.minFoodOrderFcfa} FCFA minimum commande food.",
            style: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.9)),
          ),
          const SizedBox(height: 20),
          OzelTextField(
            controller: _code,
            label: "Code à 6 chiffres",
            keyboardType: TextInputType.number,
            prefixIcon: Icons.lock_outline_rounded,
          ),
          const SizedBox(height: 20),
          OzelPrimaryButton(label: "Valider", onPressed: _verify),
        ],
      ),
    );
  }
}
