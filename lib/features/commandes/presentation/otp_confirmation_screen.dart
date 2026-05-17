// Écran de confirmation de livraison par code OTP
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/ozel_button.dart';
import '../../dashboard/domain/dashboard_provider.dart';
import '../domain/commandes_provider.dart';

/// Écran de saisie du code OTP fourni par le client pour valider la livraison
class OtpConfirmationScreen extends ConsumerStatefulWidget {
  final String commandeId;
  const OtpConfirmationScreen({super.key, required this.commandeId});

  @override
  ConsumerState<OtpConfirmationScreen> createState() =>
      _OtpConfirmationScreenState();
}

class _OtpConfirmationScreenState
    extends ConsumerState<OtpConfirmationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  String get _otpValue => _controllers.map((c) => c.text).join();

  Future<void> _confirmer() async {
    if (_otpValue.length < 6) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final commande = ref.read(activeCommandeProvider);
    if (commande == null) return;

    final succes = await ref
        .read(commandesProvider.notifier)
        .confirmerLivraison(commande.id, _otpValue);

    if (!mounted) return;

    if (succes) {
      // Mettre à jour les stats du dashboard
      ref
          .read(dashboardProvider.notifier)
          .ajouterLivraison(commande.partLivreur);

      // Afficher l'écran de succès
      _afficherSucces(commande.partLivreur);
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = AppStrings.otpLivraisonIncorrect;
        for (final c in _controllers) c.clear();
        _focusNodes[0].requestFocus();
      });
    }
  }

  void _afficherSucces(double montantGagne) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.kGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: AppColors.kWhite, size: 40),
            ),
            const SizedBox(height: 16),
            const Text(
              AppStrings.livraisonConfirmee,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.kTextPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              AppStrings.montantGagne,
              style: TextStyle(color: AppColors.kTextSecondary, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              Formatters.formatFcfa(montantGagne),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.kGreen,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Crédité J+1',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.kTextSecondary,
              ),
            ),
            const SizedBox(height: 20),
            OzelButton(
              label: 'Retour à l\'accueil',
              onPressed: () {
                Navigator.pop(ctx);
                context.go('/home/dashboard');
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final commande = ref.watch(activeCommandeProvider);

    return Scaffold(
      backgroundColor: AppColors.kBackground,
      appBar: AppBar(
        title: const Text(AppStrings.confirmationLivraison),
        backgroundColor: AppColors.kPrimaryOrange,
        foregroundColor: AppColors.kWhite,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Icône et titre
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.kPrimaryOrange.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_open,
                        color: AppColors.kPrimaryOrange,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Saisir le code OTP',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      AppStrings.entrezCodeClient,
                      style: TextStyle(
                        color: AppColors.kTextSecondary,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // 6 champs OTP
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, _buildOtpField),
              ),
              const SizedBox(height: 16),
              // Message d'erreur
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.kRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.kRed, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: AppColors.kRed),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              // Montant à gagner
              if (commande != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.kGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.kGreen.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.account_balance_wallet,
                          color: AppColors.kGreen),
                      const SizedBox(width: 8),
                      Text(
                        'Vous allez gagner ${Formatters.formatFcfa(commande.partLivreur)}',
                        style: const TextStyle(
                          color: AppColors.kGreen,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              const Spacer(),
              // Bouton confirmer
              OzelButton(
                label: 'Confirmer la livraison',
                onPressed: (_isLoading || _otpValue.length < 6)
                    ? null
                    : _confirmer,
                isLoading: _isLoading,
                icon: Icons.verified,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpField(int index) {
    return SizedBox(
      width: 46,
      height: 56,
      child: TextFormField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.kTextPrimary,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: AppColors.kWhite,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.kGrey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: AppColors.kPrimaryOrange, width: 2),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
          if (_otpValue.length == 6) _confirmer();
          setState(() {});
        },
      ),
    );
  }
}
