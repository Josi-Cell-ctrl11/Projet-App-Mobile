import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:uuid/uuid.dart";

import "../../../core/theme/app_colors.dart";
import "../../../shared/models/app_user.dart";
import "../../../shared/widgets/ozel_button.dart";
import "../application/auth_session.dart";

/// Vérification du code OTP reçu par SMS — Firebase Auth réel.
class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key, required this.phone});
  final String phone;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  // verificationId transmis depuis LoginScreen via GoRouter extra
  String? _verificationId;

  // 6 champs individuels
  final List<TextEditingController> _ctrl =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focus = List.generate(6, (_) => FocusNode());

  bool _loading = false;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Récupère verificationId passé en extra par LoginScreen
    final extra = GoRouterState.of(context).extra;
    if (extra is Map) {
      _verificationId = extra["verificationId"] as String?;
    }
  }

  @override
  void dispose() {
    for (final c in _ctrl) c.dispose();
    for (final f in _focus) f.dispose();
    super.dispose();
  }

  String get _otpValue => _ctrl.map((c) => c.text).join();

  Future<void> _verifier() async {
    final otp = _otpValue;
    if (otp.length != 6) {
      setState(() => _error = "Entrez les 6 chiffres du code");
      return;
    }
    if (_verificationId == null) {
      setState(() => _error = "Session expirée, recommencez");
      return;
    }

    setState(() { _loading = true; _error = null; });

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // Créer ou restaurer le profil local
      final existing = ref.read(authSessionProvider).user;
      final user = existing ??
          AppUser(
            id: userCredential.user?.uid ?? const Uuid().v4(),
            name: "Client Ozel",
            phone: widget.phone,
            email: "",
            walletBalanceFcfa: 0,
            ozelPoints: 500,
          );
      await ref.read(authSessionProvider.notifier).saveUser(user);

      if (!mounted) return;
      context.go("/accueil");
    } on FirebaseAuthException catch (e) {
      setState(() {
        _loading = false;
        _error = e.code == "invalid-verification-code"
            ? "Code incorrect, vérifiez votre SMS"
            : e.message ?? "Erreur de vérification";
      });
    }
  }

  Future<void> _renvoyerCode() async {
    // Retourner à LoginScreen pour relancer verifyPhoneNumber
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                "Vérification",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.4,
                  ),
                  children: [
                    const TextSpan(text: "Code envoyé par SMS au\n"),
                    TextSpan(
                      text: widget.phone,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // ── 6 champs OTP ──────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (i) => _OtpBox(
                  controller: _ctrl[i],
                  focusNode: _focus[i],
                  onChanged: (v) {
                    if (v.isNotEmpty && i < 5) {
                      _focus[i + 1].requestFocus();
                    }
                    if (v.isEmpty && i > 0) {
                      _focus[i - 1].requestFocus();
                    }
                    // Auto-valider quand les 6 cases sont remplies
                    if (_otpValue.length == 6) _verifier();
                  },
                )),
              ),

              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ],

              const SizedBox(height: 32),

              OzelPrimaryButton(
                label: _loading ? "Vérification..." : "Valider le code",
                enabled: !_loading,
                onPressed: _verifier,
              ),

              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: _renvoyerCode,
                  child: const Text(
                    "Renvoyer le code",
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Case OTP individuelle ─────────────────────────────────────────────────────

class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 56,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        onChanged: onChanged,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: AppColors.black,
        ),
        decoration: InputDecoration(
          counterText: "",
          filled: true,
          fillColor: AppColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ),
    );
  }
}
