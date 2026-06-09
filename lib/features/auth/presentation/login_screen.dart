import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../../../core/theme/app_colors.dart";
import "../../../core/utils/formatters.dart";
import "../../../shared/widgets/ozel_button.dart";
import "../../../shared/widgets/ozel_text_field.dart";

/// Connexion : téléphone → SMS OTP via Firebase Auth.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phone = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  Future<void> _envoyerCode() async {
    final numero = "+229${_phone.text.replaceAll(' ', '').trim()}";
    if (numero.length < 13) {
      setState(() => _error = "Numéro incomplet");
      return;
    }
    setState(() { _loading = true; _error = null; });

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: numero,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-vérification Android (SMS intercepté automatiquement)
        await FirebaseAuth.instance.signInWithCredential(credential);
        if (!mounted) return;
        context.go("/accueil");
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() {
          _loading = false;
          _error = e.message ?? "Erreur d'envoi du code";
        });
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() => _loading = false);
        context.push("/login/otp", extra: {
          "phone": numero,
          "verificationId": verificationId,
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 48),
            // Logo
            Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delivery_dining_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Center(
              child: Text(
                "OZELSERVICES",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.black,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                "Tous les services du quotidien en 1 clic",
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 48),
            const Text(
              "Votre numéro de téléphone",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            OzelTextField(
              controller: _phone,
              label: "Téléphone",
              hint: "01 97 90 90 98",
              prefixText: "+229 ",
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone_android_rounded,
              inputFormatters: [PhoneBeninInputFormatter()],
            ),
            if (_error != null) ...[
              const SizedBox(height: 6),
              Text(
                _error!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ],
            const SizedBox(height: 8),
            const Text(
              "Un code SMS à 6 chiffres vous sera envoyé",
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 28),
            OzelPrimaryButton(
              label: _loading ? "Envoi en cours..." : "Recevoir le code SMS",
              enabled: !_loading,
              onPressed: _envoyerCode,
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => context.push("/register"),
                child: const Text(
                  "Pas encore de compte ? S'inscrire",
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
