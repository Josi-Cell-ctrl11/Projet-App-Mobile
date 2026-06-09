import "package:flutter/material.dart";
import "package:webview_flutter/webview_flutter.dart";

import "../theme/app_colors.dart";
import "fedapay_service.dart";

/// Écran WebView FedaPay — affiche la page de paiement.
/// Retourne `true` si le paiement est approuvé, `false` sinon.
class FedaPayWebViewScreen extends StatefulWidget {
  const FedaPayWebViewScreen({
    super.key,
    required this.checkoutUrl,
    required this.transactionId,
    required this.montant,
    required this.description,
  });

  final String checkoutUrl;
  final String transactionId;
  final double montant;
  final String description;

  @override
  State<FedaPayWebViewScreen> createState() => _FedaPayWebViewScreenState();
}

class _FedaPayWebViewScreenState extends State<FedaPayWebViewScreen> {
  late final WebViewController _ctrl;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _ctrl = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _loading = true),
          onPageFinished: (_) => setState(() => _loading = false),
          onNavigationRequest: (request) {
            final url = request.url;

            // FedaPay sandbox redirige vers checkout-sandbox.fedapay.com/done
            // avec ?status=approved|declined|canceled en paramètre
            if (url.contains("fedapay.com/done") ||
                url.contains("fedapay.com/pay") && url.contains("status=")) {
              final uri = Uri.parse(url);
              final status = uri.queryParameters["status"];
              Navigator.pop(context, status == "approved");
              return NavigationDecision.prevent;
            }

            // Intercepter la callback_url personnalisée
            if (url.contains("ozelservices-payment.web.app/callback")) {
              final uri = Uri.parse(url);
              final status = uri.queryParameters["status"];
              Navigator.pop(context, status == "approved");
              return NavigationDecision.prevent;
            }

            // Intercepter les URLs de retour FedaPay (approved/declined)
            if (url.contains("transaction_id") &&
                (url.contains("approved") || url.contains("declined") ||
                    url.contains("canceled"))) {
              final approved = url.contains("approved");
              Navigator.pop(context, approved);
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
          onWebResourceError: (error) {
            // Ignorer les erreurs sur la callback URL (domaine inexistant)
            // FedaPay a déjà envoyé le statut dans l'URL
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context, false),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Paiement sécurisé",
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
            Text(
              widget.description,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.lock_rounded, size: 12),
                const SizedBox(width: 4),
                const Text(
                  "FedaPay",
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _ctrl),
          if (_loading)
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text(
                    "Chargement du paiement...",
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          // Bouton de confirmation manuelle (fallback si pas de redirection auto)
          if (!_loading)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: _ConfirmationManuelle(
                transactionId: widget.transactionId,
                onConfirm: (approved) => Navigator.pop(context, approved),
              ),
            ),
        ],
      ),
    );
  }
}

/// Lance le paiement FedaPay et retourne true si approuvé.
Future<bool> lancerPaiementFedaPay({
  required BuildContext context,
  required double montant,
  required String description,
  required String customerName,
  required String customerPhone,
  required String customerEmail,
}) async {
  final service = FedaPayService();

  // Afficher loading
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    ),
  );

  final result = await service.createTransaction(
    amountFcfa: montant,
    description: description,
    customerEmail: customerEmail,
    customerPhone: customerPhone,
    customerName: customerName,
  );

  if (!context.mounted) return false;
  Navigator.pop(context); // Fermer loading

  if (!result.success || result.checkoutUrl == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.message)),
    );
    return false;
  }

  // Ouvrir la WebView FedaPay
  final paid = await Navigator.push<bool>(
    context,
    MaterialPageRoute(
      builder: (_) => FedaPayWebViewScreen(
        checkoutUrl: result.checkoutUrl!,
        transactionId: result.transactionId,
        montant: montant,
        description: description,
      ),
    ),
  );

  return paid ?? false;
}

// Import nécessaire déjà en haut du fichier

// ── Widget de confirmation manuelle ──────────────────────────────────────────
// Affiché en overlay quand FedaPay ne redirige pas automatiquement (sandbox)

class _ConfirmationManuelle extends StatefulWidget {
  final String transactionId;
  final void Function(bool approved) onConfirm;

  const _ConfirmationManuelle({
    required this.transactionId,
    required this.onConfirm,
  });

  @override
  State<_ConfirmationManuelle> createState() => _ConfirmationManuelleState();
}

class _ConfirmationManuelleState extends State<_ConfirmationManuelle> {
  bool _checking = false;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    // Afficher le bouton après 5 secondes (laisse le temps à FedaPay de rediriger)
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) setState(() => _visible = true);
    });
  }

  Future<void> _verifierStatut() async {
    setState(() => _checking = true);
    final approved =
        await FedaPayService().checkTransactionStatus(widget.transactionId);
    if (mounted) {
      setState(() => _checking = false);
      widget.onConfirm(approved);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.primary, size: 18),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Paiement effectué ? Cliquez pour confirmer',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 36,
            child: ElevatedButton(
              onPressed: _checking ? null : _verifierStatut,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: _checking
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Vérifier', style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}
