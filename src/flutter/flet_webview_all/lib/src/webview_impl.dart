import 'package:flutter/material.dart';
import 'package:webview_all/webview_all.dart';

/// Build a WebView widget for mobile and desktop platforms.
Widget buildWebviewWidget({
  required String initialContent,
  required bool javascriptEnabled,
  required bool allowNavigation,
  String? userAgent,
  bool zoomEnabled = true,
}) {
  return _WebviewAllWidget(
    initialContent: initialContent,
    javascriptEnabled: javascriptEnabled,
    allowNavigation: allowNavigation,
    userAgent: userAgent,
    zoomEnabled: zoomEnabled,
  );
}

class _WebviewAllWidget extends StatefulWidget {
  final String initialContent;
  final bool javascriptEnabled;
  final bool allowNavigation;
  final String? userAgent;
  final bool zoomEnabled;

  const _WebviewAllWidget({
    required this.initialContent,
    required this.javascriptEnabled,
    required this.allowNavigation,
    required this.userAgent,
    required this.zoomEnabled,
  });

  @override
  State<_WebviewAllWidget> createState() => _WebviewAllWidgetState();
}

class _WebviewAllWidgetState extends State<_WebviewAllWidget> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController();
    _configureController();
    _loadContent(widget.initialContent);
  }

  @override
  void didUpdateWidget(covariant _WebviewAllWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.javascriptEnabled != widget.javascriptEnabled ||
        oldWidget.allowNavigation != widget.allowNavigation ||
        oldWidget.userAgent != widget.userAgent ||
        oldWidget.zoomEnabled != widget.zoomEnabled) {
      _configureController();
    }

    if (oldWidget.initialContent != widget.initialContent) {
      _loadContent(widget.initialContent);
    }
  }

  void _configureController() {
    _controller
      ..setJavaScriptMode(
        widget.javascriptEnabled
            ? JavaScriptMode.unrestricted
            : JavaScriptMode.disabled,
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            if (widget.allowNavigation ||
                (!_looksLikeHtml(widget.initialContent) &&
                    request.url == widget.initialContent)) {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
        ),
      )
      ..enableZoom(widget.zoomEnabled);

    final userAgent = widget.userAgent;
    if (userAgent != null && userAgent.isNotEmpty) {
      _controller.setUserAgent(userAgent);
    }
  }

  void _loadContent(String content) {
    if (_looksLikeHtml(content)) {
      _controller.loadHtmlString(content);
      return;
    }

    _controller.loadRequest(Uri.parse(content));
  }

  bool _looksLikeHtml(String content) {
    final trimmed = content.trimLeft().toLowerCase();
    return trimmed.startsWith('<!doctype html') || trimmed.startsWith('<html');
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}
