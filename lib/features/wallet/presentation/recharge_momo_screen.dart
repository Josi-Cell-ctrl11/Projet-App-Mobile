import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../../../core/payment/fedapay_service.dart";
import "../../../core/theme/app_colors.dart";
import "../../../shared/widgets/ozel_button.dart";
import "../../../shared/widgets/ozel_text_field.dart";
import "../../auth/application/auth_session.dart";
import "../application/wallet_notifier.dart";

/// Recharge wallet via MoMo (flux FedaPay simulé).
class RechargeMomoScreen extends ConsumerStatefulWidget {
  const RechargeMomoScreen({super.key});

  @override
  ConsumerState<RechargeMomoScreen> createState() => _RechargeMomoScreenState();
}

class _RechargeMomoScreenState extends ConsumerState<RechargeMomoScreen> {
  final _amount = TextEditingController(text: "5000");
  PaymentMethod _method = PaymentMethod.mtnMomo;
  bool _loading = false;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final value = double.tryParse(_amount.text.trim().replaceAll(",", "."));
    if (value == null || value <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Montant invalide.")),
      );
      return;
    }
    setState(() => _loading = true);
    final res = await FedaPayService().pay(amountFcfa: value, method: _method);
    setState(() => _loading = false);
    if (!mounted || !res.success) return;

    ref.read(walletTxProvider.notifier).addCredit("Recharge wallet", value);
    final user = ref.read(authSessionProvider).user;
    if (user != null) {
      await ref.read(authSessionProvider.notifier).updateUser(
            user.copyWith(walletBalanceFcfa: user.walletBalanceFcfa + value),
          );
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res.message)),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Recharge MoMo")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Recharge OzelWallet",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            "Simulation FedaPay : aucun vrai débit n’est effectué dans ce MVP.",
            style: const TextStyle(color: AppColors.textSecondary, height: 1.35),
          ),
          const SizedBox(height: 16),
          OzelTextField(
            controller: _amount,
            label: "Montant (FCFA)",
            keyboardType: TextInputType.number,
            prefixIcon: Icons.payments_outlined,
          ),
          const SizedBox(height: 12),
          ...PaymentMethod.values.map(
            (m) => RadioListTile<PaymentMethod>(
              value: m,
              groupValue: _method,
              onChanged: (v) => setState(() => _method = v!),
              title: Text(m.labelFr),
            ),
          ),
          const SizedBox(height: 12),
          OzelPrimaryButton(
            label: _loading ? "Traitement..." : "Valider la recharge",
            enabled: !_loading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
