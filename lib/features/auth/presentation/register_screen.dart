import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:uuid/uuid.dart";

import "../../../core/theme/app_colors.dart";
import "../../../shared/models/app_user.dart";
import "../../../shared/widgets/ozel_button.dart";
import "../../../shared/widgets/ozel_text_field.dart";
import "../application/auth_session.dart";

/// Inscription : nom, téléphone, email (mock).
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _name = TextEditingController(text: "Koffi A.");
  final _phone = TextEditingController(text: "+229 97 00 00 01");
  final _email = TextEditingController(text: "koffi@email.com");

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final user = AppUser(
      id: Uuid().v4(),
      name: _name.text.trim(),
      phone: _phone.text.trim(),
      email: _email.text.trim(),
      walletBalanceFcfa: 5000,
      ozelPoints: 500,
    );
    await ref.read(authSessionProvider.notifier).saveUser(user);
    if (!mounted) return;
    context.go("/accueil");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Créer un compte")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            "Rejoignez OZELSERVICES",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            "Les données sont stockées localement pour ce MVP (SharedPreferences).",
            style: const TextStyle(color: AppColors.textSecondary, height: 1.35),
          ),
          const SizedBox(height: 20),
          OzelTextField(
            controller: _name,
            label: "Nom complet",
            prefixIcon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 12),
          OzelTextField(
            controller: _phone,
            label: "Téléphone",
            keyboardType: TextInputType.phone,
            prefixIcon: Icons.phone_android_rounded,
          ),
          const SizedBox(height: 12),
          OzelTextField(
            controller: _email,
            label: "Email",
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
          ),
          const SizedBox(height: 24),
          OzelPrimaryButton(label: "S'inscrire", onPressed: _submit),
        ],
      ),
    );
  }
}
