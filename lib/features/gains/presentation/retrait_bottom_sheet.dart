// Bottom sheet de retrait vers MoMo
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/phone_formatter.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/ozel_button.dart';
import '../../../shared/widgets/ozel_text_field.dart';
import '../domain/gains_provider.dart';

/// Bottom sheet pour demander un retrait vers MoMo
class RetraitBottomSheet extends ConsumerStatefulWidget {
  final double soldeDisponible;
  const RetraitBottomSheet({super.key, required this.soldeDisponible});

  @override
  ConsumerState<RetraitBottomSheet> createState() =>
      _RetraitBottomSheetState();
}

class _RetraitBottomSheetState extends ConsumerState<RetraitBottomSheet> {
  final _momoController = TextEditingController();
  final _montantController = TextEditingController();
  String? _momoError;
  String? _montantError;
  bool _isLoading = false;

  @override
  void dispose() {
    _momoController.dispose();
    _montantController.dispose();
    super.dispose();
  }

  double? get _montantSaisi {
    return double.tryParse(_montantController.text.replaceAll(' ', ''));
  }

  void _valider() {
    // Validation numéro MoMo
    final momoPhone = phoneToE164(_momoController.text.trim());
    final momoError = validatePhoneBenin(momoPhone);
    // Validation montant
    final montantError =
        validateMontantRetrait(_montantSaisi, widget.soldeDisponible);

    setState(() {
      _momoError = momoError;
      _montantError = montantError;
    });

    if (momoError != null || montantError != null) return;
    _soumettre();
  }

  Future<void> _soumettre() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(gainsProvider.notifier).demanderRetrait(
            phoneToE164(_momoController.text.trim()),
            _montantSaisi!,
          );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.retraitEnvoye),
          backgroundColor: AppColors.kGreen,
        ),
      );
    } catch (_) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.erreurReseau),
          backgroundColor: AppColors.kRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.kWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poignée
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.kGreyLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Retrait vers MoMo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Solde disponible : ${Formatters.formatFcfa(widget.soldeDisponible)}',
              style: const TextStyle(
                color: AppColors.kTextSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),
            // Numéro MoMo
            OzelTextField(
              label: AppStrings.numeromomo,
              hint: '0166272826',
              controller: _momoController,
              keyboardType: TextInputType.phone,
              errorText: _momoError,
              prefixText: '+229 ',
              prefixIcon: const Icon(Icons.phone_android,
                  color: AppColors.kPrimaryOrange),
              inputFormatters: [PhoneBeninInputFormatter()],
              onChanged: (_) => setState(() => _momoError = null),
            ),
            const SizedBox(height: 16),
            // Montant
            OzelTextField(
              label: AppStrings.montantRetrait,
              hint: 'Ex: 5000',
              controller: _montantController,
              keyboardType: TextInputType.number,
              errorText: _montantError,
              prefixIcon: const Icon(Icons.account_balance_wallet,
                  color: AppColors.kPrimaryOrange),
              suffixIcon: const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'FCFA',
                  style: TextStyle(
                    color: AppColors.kTextSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => setState(() => _montantError = null),
            ),
            const SizedBox(height: 8),
            Text(
              '${AppStrings.montantMinimum} • Max : ${Formatters.formatFcfa(widget.soldeDisponible)}',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.kTextSecondary,
              ),
            ),
            const SizedBox(height: 20),
            OzelButton(
              label: 'Confirmer le retrait',
              onPressed: _isLoading ? null : _valider,
              isLoading: _isLoading,
              icon: Icons.send,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
