import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../../../core/theme/app_colors.dart";
import "../../../shared/widgets/ozel_button.dart";
import "../../../shared/widgets/ozel_text_field.dart";

/// Connexion : téléphone puis OTP (mock).
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phone = TextEditingController(text: "+229 01 23 45 67");

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Connexion")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            "Bienvenue sur OZELSERVICES",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            "Entrez votre numéro de téléphone. Nous vous enverrons un code OTP (simulation MVP).",
            style: const TextStyle(color: AppColors.textSecondary, height: 1.35),
          ),
          const SizedBox(height: 24),
          OzelTextField(
            controller: _phone,
            label: "Téléphone",
            keyboardType: TextInputType.phone,
            prefixIcon: Icons.phone_android_rounded,
          ),
          const SizedBox(height: 20),
          OzelPrimaryButton(
            label: "Recevoir le code",
            onPressed: () {
              final phone = _phone.text.trim();
              context.push("/login/otp", extra: phone);
            },
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => context.push("/register"),
            child: const Text("Créer un compte"),
          ),
        ],
      ),
    );
  }
}
