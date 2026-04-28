import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class OrderWebViewScreen extends StatefulWidget {
  final int orderId;
  final Uri url;

  const OrderWebViewScreen({
    super.key,
    required this.orderId,
    required this.url,
  });

  @override
  State<OrderWebViewScreen> createState() => _OrderWebViewScreenState();
}

class _OrderWebViewScreenState extends State<OrderWebViewScreen> {
  late final WebViewController _controller;
  var _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) {
              setState(() => _isLoading = true);
            }
          },
          onPageFinished: (_) {
            if (mounted) {
              setState(() => _isLoading = false);
            }
          },
        ),
      )
      ..loadRequest(widget.url);
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr
            ? 'تفاصيل الطلب #${widget.orderId}'
            : 'Order #${widget.orderId}'),
        backgroundColor: const Color(0xFF1A2543),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFF6FE0DA)),
            ),
        ],
      ),
    );
  }
}
