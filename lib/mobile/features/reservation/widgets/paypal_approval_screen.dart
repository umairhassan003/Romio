import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/payment_constants.dart';

/// Hosts PayPal's hosted approval page in an in-app browser. PayPal redirects
/// the buyer to [PaymentConstants.paypalReturnUrl] on approval or
/// [PaymentConstants.paypalCancelUrl] on cancel; we intercept that navigation
/// (before it loads) and pop with the result:
///   * `true`  → approved (caller should capture the order)
///   * `false` → cancelled / dismissed
///
/// Push it and await the result:
/// ```dart
/// final approved = await Navigator.push<bool>(context,
///   MaterialPageRoute(builder: (_) => PayPalApprovalScreen(approvalUrl: url)));
/// ```
class PayPalApprovalScreen extends StatefulWidget {
  final String approvalUrl;
  const PayPalApprovalScreen({super.key, required this.approvalUrl});

  @override
  State<PayPalApprovalScreen> createState() => _PayPalApprovalScreenState();
}

class _PayPalApprovalScreenState extends State<PayPalApprovalScreen> {
  late final WebViewController _controller;
  bool _settled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            if (request.url.startsWith(PaymentConstants.paypalReturnUrl)) {
              _finish(true);
              return NavigationDecision.prevent;
            }
            if (request.url.startsWith(PaymentConstants.paypalCancelUrl)) {
              _finish(false);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onPageStarted: (_) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.approvalUrl));
  }

  void _finish(bool approved) {
    if (_settled) return;
    _settled = true;
    if (mounted) Navigator.of(context).pop(approved);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopScope(
      // A back gesture / button counts as cancelling the payment.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _finish(false);
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundWhite,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundWhite,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.primaryBurgundy),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _finish(false),
          ),
          title: Text(l10n?.paymentPaypalApprovalTitle ?? 'PayPal',
              style: AppTextStyles.headingS),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              const LinearProgressIndicator(
                color: AppColors.primaryBurgundy,
                backgroundColor: AppColors.surfaceLight,
              ),
          ],
        ),
      ),
    );
  }
}
