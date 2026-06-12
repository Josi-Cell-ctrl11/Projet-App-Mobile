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
  WebViewController? _ctrl;
  bool _loading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    final uri = Uri.tryParse(widget.checkoutUrl);
    if (widget.checkoutUrl.isEmpty || uri == null || !uri.hasScheme) {
      setState(() {
        _loadError = "URL de paiement invalide.";
        _loading = false;
      });
      return;
    }

    _ctrl = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _loading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
          onNavigationRequest: (request) {
            final url = request.url;

            if (url.contains("fedapay.com/done") ||
                url.contains("fedapay.com/pay") && url.contains("status=")) {
              final uri = Uri.parse(url);
              final status = uri.queryParameters["status"];
              Navigator.pop(context, status == "approved");
              return NavigationDecision.prevent;
            }

            if (url.contains("ozelservices-payment.web.app/callback")) {
              final uri = Uri.parse(url);
              final status = uri.queryParameters["status"];
              Navigator.pop(context, status == "approved");
              return NavigationDecision.prevent;
            }

            if (url.contains("transaction_id") &&
                (url.contains("approved") ||
                    url.contains("declined") ||
                    url.contains("canceled"))) {
              final approved = url.contains("approved");
              Navigator.pop(context, approved);
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
          onWebResourceError: (error) {
            if (!mounted) return;
            if (error.url?.contains("ozelservices-payment.web.app/callback") ==
                true) {
              return;
            }
            setState(() {
              _loadError = error.description.isNotEmpty
                  ? error.description
                  : "Impossible de charger la page de paiement.";
              _loading = false;
            });
          },
        ),
      )
      ..loadRequest(uri);
  }

  void _retry() {
    final uri = Uri.tryParse(widget.checkoutUrl);
    if (_ctrl == null || uri == null || !uri.hasScheme) {
      _initWebView();
      return;
    }
    setState(() {
      _loadError = null;
      _loading = true;
    });
    _ctrl!.loadRequest(uri);
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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.lock_rounded, size: 12),
                SizedBox(width: 4),
                Text(
                  "FedaPay",
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _loadError != null
          ? _ErrorView(
              message: _loadError!,
              onRetry: _retry,
              onCancel: () => Navigator.pop(context, false),
            )
          : Stack(
              children: [
                if (_ctrl != null) WebViewWidget(controller: _ctrl!),
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
                if (!_loading && _ctrl != null)
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

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
    required this.onCancel,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 56,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            const Text(
              "Impossible de charger la page de paiement",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text("Réessayer"),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onCancel,
                child: const Text("Annuler"),
              ),
            ),
          ],
        ),
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
  Navigator.pop(context);

  if (!result.success || result.checkoutUrl == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.message)),
    );
    return false;
  }

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

class _ConfirmationManuelle extends StatefulWidget {
  const _ConfirmationManuelle({
    required this.transactionId,
    required this.onConfirm,
  });

  final String transactionId;
  final void Function(bool approved) onConfirm;

  @override
  State<_ConfirmationManuelle> createState() => _ConfirmationManuelleState();
}

class _ConfirmationManuelleState extends State<_ConfirmationManuelle> {
  bool _checking = false;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
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
              "Paiement effectué ? Cliquez pour confirmer",
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
                  borderRadius: BorderRadius.circular(8),
                ),
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
                  : const Text("Vérifier", style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}
