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
            // FedaPay redirige vers callback_url après paiement
            if (request.url
                .contains("ozelservices.bj/payment/callback")) {
              // Succès — on vérifie via l'URL
              final uri = Uri.parse(request.url);
              final status = uri.queryParameters["status"];
              Navigator.pop(context, status == "approved");
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
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
