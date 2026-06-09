// Écran de connexion livreur — saisie du numéro de téléphone
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/ozel_button.dart';
import '../../../shared/widgets/ozel_text_field.dart';
import '../domain/auth_provider.dart';

/// Écran de connexion par numéro de téléphone béninois
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController(text: '+229');
  String? _phoneError;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Validation inline sans requête si format invalide
    final error = validatePhoneBenin(_phoneController.text.trim());
    if (error != null) {
      setState(() => _phoneError = error);
      return;
    }
    setState(() => _phoneError = null);

    await ref.read(authProvider.notifier).sendOtp(_phoneController.text.trim());

    if (!mounted) return;
    final authState = ref.read(authProvider);
    if (authState.status == AuthStatus.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authState.errorMessage ?? AppStrings.erreurReseau),
          backgroundColor: AppColors.kRed,
        ),
      );
    } else {
      // Naviguer vers l'écran OTP
      context.push('/otp?phone=${Uri.encodeComponent(_phoneController.text.trim())}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.kBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                // En-tête
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.kPrimaryOrange,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Center(
                          child: Text(
                            'OZ',
                            style: TextStyle(
                              color: AppColors.kWhite,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'OZELSERVICES',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.kTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Espace Livreur',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.kTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                const Text(
                  AppStrings.connexion,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.kTextPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Entrez votre numéro de téléphone pour recevoir un code de vérification.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.kTextSecondary,
                  ),
                ),
                const SizedBox(height: 32),
                // Champ téléphone
                OzelTextField(
                  label: AppStrings.numeroDeTelephone,
                  hint: AppStrings.entrezVotreNumero,
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  errorText: _phoneError,
                  prefixIcon: const Icon(
                    Icons.phone,
                    color: AppColors.kPrimaryOrange,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[+\d]')),
                  ],
                  onChanged: (_) {
                    if (_phoneError != null) {
                      setState(() => _phoneError = null);
                    }
                  },
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Format : +229 suivi de 8 chiffres',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.kTextSecondary,
                  ),
                ),
                const SizedBox(height: 32),
                // Bouton envoyer
                OzelButton(
                  label: AppStrings.envoyerCode,
                  onPressed: isLoading ? null : _submit,
                  isLoading: isLoading,
                  icon: Icons.send,
                ),
                const SizedBox(height: 24),
                // Lien inscription
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Pas encore livreur ?',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.kTextSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/inscription'),
                      child: const Text(
                        'S\'inscrire',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.kPrimaryOrange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Note MVP
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.kPrimaryOrange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.kPrimaryOrange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: AppColors.kPrimaryOrange, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'MVP : utilisez +22997112233 et le code 123456',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.kPrimaryOrange,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
