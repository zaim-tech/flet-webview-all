import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_all/webview_all.dart';
import 'webview_environment.dart';

/// Build a WebView widget for mobile and desktop platforms.
Widget buildWebviewWidget({
  required String initialContent,
  required bool javascriptEnabled,
  required bool allowNavigation,
  required bool debuggingEnabled,
  String? userAgent,
  bool zoomEnabled = true,
  int? remoteDebuggingPort,
}) {
  final webview = _WebviewAllWidget(
    initialContent: initialContent,
    javascriptEnabled: javascriptEnabled,
    allowNavigation: allowNavigation,
    debuggingEnabled: debuggingEnabled,
    userAgent: userAgent,
    zoomEnabled: zoomEnabled,
  );

  if (remoteDebuggingPort == null ||
      kIsWeb ||
      defaultTargetPlatform != TargetPlatform.windows) {
    return webview;
  }

  return _WebViewEnvironmentGate(
    remoteDebuggingPort: remoteDebuggingPort,
    child: webview,
  );
}

class _WebViewEnvironmentGate extends StatefulWidget {
  const _WebViewEnvironmentGate({
    required this.remoteDebuggingPort,
    required this.child,
  });

  final int remoteDebuggingPort;
  final Widget child;

  @override
  State<_WebViewEnvironmentGate> createState() =>
      _WebViewEnvironmentGateState();
}

class _WebViewEnvironmentGateState extends State<_WebViewEnvironmentGate> {
  late Future<void> _initialization;

  @override
  void initState() {
    super.initState();
    _initialization = ensureWebViewEnvironment(
      remoteDebuggingPort: widget.remoteDebuggingPort,
    );
  }

  @override
  void didUpdateWidget(covariant _WebViewEnvironmentGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.remoteDebuggingPort != widget.remoteDebuggingPort) {
      _initialization = ensureWebViewEnvironment(
        remoteDebuggingPort: widget.remoteDebuggingPort,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: SelectableText(
              'Failed to initialize WebView2 remote debugging: '
              '${snapshot.error}',
              textAlign: TextAlign.center,
            ),
          );
        }

        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        return widget.child;
      },
    );
  }
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
    // to the new constraints. The wrapper below makes the backend report the
    // new surface size again without recreating this widget or its controller.
    return _ViewportSynchronizedWebView(controller: _controller);
  }
}

/// Forces the Windows backend to report a settled surface size after a
/// top-level metrics or layout change. A short debounce avoids doing this for
/// every interim size emitted while the user is dragging a window border.
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
  Timer? _pulseTimer;
  bool _nudgeViewport = false;
  int _ignoredSizeNotifications = 0;

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
      // webview_all reports the native WebView2 surface size only when its
      // Flutter child gets a new layout size. Change it by one physical pixel
      // for one frame, then restore it. Unlike replacing WebViewWidget, this
      // leaves the GPU texture mounted and avoids a visible blank flash.
      _ignoredSizeNotifications = 8;
      _pulseViewport(3);
    });
  }

  void _pulseViewport(int remaining) {
    if (!mounted) {
      return;
    }
    setState(() => _nudgeViewport = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() => _nudgeViewport = false);
      // WebView2 can apply the new rasterization scale one compositor frame
      // after Flutter lays out the texture. Three inexpensive pulses cover
      // that delayed transition on small windows and DPI changes.
      if (remaining > 1) {
        _pulseTimer?.cancel();
        _pulseTimer = Timer(
          const Duration(milliseconds: 32),
          () => _pulseViewport(remaining - 1),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (notification) {
        if (_ignoredSizeNotifications > 0) {
          _ignoredSizeNotifications--;
          return false;
        }
        // Also cover Flet control/layout changes which do not alter the host
        // window metrics (for example, a resizable pane).
        _scheduleTextureRebuild();
        return false;
      },
      child: SizeChangedLayoutNotifier(
        child: Padding(
          // One physical pixel is enough to make the package call its native
          // SetSurfaceSize method, while being imperceptible to the user.
          padding: EdgeInsets.only(
            right: _nudgeViewport ? 1 / View.of(context).devicePixelRatio : 0,
          ),
          child: WebViewWidget(controller: widget.controller),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _settleTimer?.cancel();
    _pulseTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
