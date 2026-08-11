import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_all/webview_all.dart';

/// Build a WebView widget for mobile and desktop platforms.
Widget buildWebviewWidget({
  required String initialContent,
  required bool javascriptEnabled,
  required bool allowNavigation,
  required bool debuggingEnabled,
  String? userAgent,
  bool zoomEnabled = true,
}) {
  return _WebviewAllWidget(
    initialContent: initialContent,
    javascriptEnabled: javascriptEnabled,
    allowNavigation: allowNavigation,
    debuggingEnabled: debuggingEnabled,
    userAgent: userAgent,
    zoomEnabled: zoomEnabled,
  );
}

class _WebviewAllWidget extends StatefulWidget {
  final String initialContent;
  final bool javascriptEnabled;
  final bool allowNavigation;
  final bool debuggingEnabled;
  final String? userAgent;
  final bool zoomEnabled;

  const _WebviewAllWidget({
    required this.initialContent,
    required this.javascriptEnabled,
    required this.allowNavigation,
    required this.debuggingEnabled,
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
        oldWidget.debuggingEnabled != widget.debuggingEnabled ||
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

    if (widget.debuggingEnabled) {
      _controller.setOnConsoleMessage((JavaScriptConsoleMessage message) {
        debugPrint("FletWebviewAll console: ${message.message}");
      });
    }

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
    // On Windows, webview_all renders WebView2 into a Flutter GPU texture.
    // During a fullscreen transition (and occasionally a DPI transition) the
    // texture can retain its old surface dimensions while Flutter stretches it
    // to the new constraints. Rebuilding the *widget* after the viewport has
    // settled makes the Windows backend report the new surface size again. The
    // controller is deliberately retained, so the loaded page and its state
    // are not recreated.
    return _ViewportSynchronizedWebView(controller: _controller);
  }
}

/// Recreates the Windows texture widget after a top-level metrics or layout
/// change. A short debounce avoids tearing down the widget for every interim
/// size emitted while the user is dragging a window border.
class _ViewportSynchronizedWebView extends StatefulWidget {
  const _ViewportSynchronizedWebView({required this.controller});

  final WebViewController controller;

  @override
  State<_ViewportSynchronizedWebView> createState() =>
      _ViewportSynchronizedWebViewState();
}

class _ViewportSynchronizedWebViewState
    extends State<_ViewportSynchronizedWebView> with WidgetsBindingObserver {
  Timer? _settleTimer;
  int _viewportGeneration = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeMetrics() {
    // Covers fullscreen, restore, and monitor-DPI changes.
    _scheduleTextureRebuild();
  }

  void _scheduleTextureRebuild() {
    _settleTimer?.cancel();
    _settleTimer = Timer(const Duration(milliseconds: 120), () {
      if (!mounted) {
        return;
      }
      setState(() => _viewportGeneration++);
    });
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (notification) {
        // Also cover Flet control/layout changes which do not alter the host
        // window metrics (for example, a resizable pane).
        _scheduleTextureRebuild();
        return false;
      },
      child: SizeChangedLayoutNotifier(
        child: WebViewWidget(
          key: ValueKey<int>(_viewportGeneration),
          controller: widget.controller,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _settleTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
