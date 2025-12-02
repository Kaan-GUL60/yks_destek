// webview_screen.dart
import 'dart:io'; // Platform kontrolü
import 'package:flutter/cupertino.dart'; // iOS widget'ları
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

// 🖥️ Web Sayfasini Uygulama Icinde Gosteren Ekran
class WebViewScreen extends StatefulWidget {
  final String url;
  final String title;

  const WebViewScreen({super.key, required this.url, required this.title});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true; // Yükleme durumu takibi

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress: $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
            if (mounted) {
              setState(() {
                _isLoading = true;
              });
            }
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint(
              'Web Resource Error: Code ${error.errorCode}, Description: ${error.description}',
            );
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    // --- 1. iOS TASARIMI (Cupertino) ---
    if (Platform.isIOS) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(widget.title),
          previousPageTitle: "Geri", // Önceki sayfanın adı yerine "Geri" yazar
        ),
        child: SafeArea(
          child: Stack(
            children: [
              WebViewWidget(controller: _controller),
              if (_isLoading)
                const Center(child: CupertinoActivityIndicator(radius: 15)),
            ],
          ),
        ),
      );
    }
    // --- 2. ANDROID TASARIMI (Material) ---
    else {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          //backgroundColor: const Color(0xFF1E6C53),
          bottom: _isLoading
              ? const PreferredSize(
                  preferredSize: Size.fromHeight(4.0),
                  child: LinearProgressIndicator(),
                )
              : null,
        ),
        body: WebViewWidget(controller: _controller),
      );
    }
  }
}
