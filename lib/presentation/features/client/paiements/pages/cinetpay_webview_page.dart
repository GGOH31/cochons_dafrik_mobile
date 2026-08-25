import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:cochons_dafrik_mobile/core/themes/app_color.dart';

/// Résultat renvoyé par [CinetPayWebviewPage] quand elle se ferme.
enum CinetPayResult { success, failed, cancelled }

/// Ouvre la page de paiement hébergée par CinetPay dans une WebView intégrée
/// à l'application, et détecte automatiquement la redirection vers success_url /
/// failed_url pour fermer la WebView.
///
/// Le statut réel de la commande n'est JAMAIS déduit de cette redirection :
/// l'appelant doit ensuite appeler `ClientService.verifyCinetPayPayment` pour
/// obtenir le statut authentique (confirmé côté serveur via l'API CinetPay).
class CinetPayWebviewPage extends StatefulWidget {
  final String paymentUrl;

  const CinetPayWebviewPage({super.key, required this.paymentUrl});

  @override
  State<CinetPayWebviewPage> createState() => _CinetPayWebviewPageState();
}

class _CinetPayWebviewPageState extends State<CinetPayWebviewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _resultReturned = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) => _handleUrlChange(url),
          onNavigationRequest: (request) {
            _handleUrlChange(request.url);
            return NavigationDecision.navigate;
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (error) {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _loadError =
                    "${error.description} (${error.url ?? 'URL inconnue'})";
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _handleUrlChange(String url) {
    if (_resultReturned) return;

    if (url.contains('/payments/cinetpay/success')) {
      _returnResult(CinetPayResult.success);
    } else if (url.contains('/payments/cinetpay/failed')) {
      _returnResult(CinetPayResult.failed);
    }
  }

  void _returnResult(CinetPayResult result) {
    if (_resultReturned) return;
    _resultReturned = true;
    Navigator.of(context).pop(result);
  }

  Future<bool> _onWillPop() async {
    _returnResult(CinetPayResult.cancelled);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) _onWillPop();
      },
      child: Scaffold(
        backgroundColor: CdaColors.creme,
        appBar: AppBar(
          backgroundColor: CdaColors.vertForet,
          foregroundColor: Colors.white,
          title: Text(
            "Paiement CinetPay",
            style: GoogleFonts.fredoka(fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _returnResult(CinetPayResult.cancelled),
          ),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    CdaColors.vertForet,
                  ),
                ),
              ),
            if (_loadError != null)
              Container(
                color: CdaColors.creme,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.wifi_off,
                      color: CdaColors.rouge,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Impossible de charger la page de paiement",
                      style: GoogleFonts.fredoka(
                        fontWeight: FontWeight.bold,
                        color: CdaColors.encre,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _loadError!,
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: CdaColors.gris,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
