import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_all/webview_all.dart';
import 'webview_environment.dart';

/// Build a WebView widget for mobile and desktop platforms.
Widget buildWebviewWidget({
  required WebViewController controller,
  required String initialContent,
  required bool javascriptEnabled,
  required dynamic javascriptMode,
  required bool allowNavigation,
  required bool debuggingEnabled,
  String? userAgent,
  bool zoomEnabled = true,
  Color? backgroundColor,
  Set<String> javascriptChannels = const <String>{},
  void Function(String url)? onPageStarted,
  void Function(String url)? onPageFinished,
  void Function(int progress)? onProgress,
  void Function(WebResourceError error)? onWebResourceError,
  bool Function(NavigationRequest request)? onNavigationRequest,
  void Function(String channelName, String messageBody)? onJavaScriptMessage,
  void Function(int x, int y)? onScrollPositionChange,
  void Function(JavaScriptConsoleMessage message)? onConsoleMessage,
  int? remoteDebuggingPort,
}) {
  final webview = _WebviewAllWidget(
    controller: controller,
    initialContent: initialContent,
    javascriptEnabled: javascriptEnabled,
    javascriptMode: javascriptMode,
    allowNavigation: allowNavigation,
    debuggingEnabled: debuggingEnabled,
    userAgent: userAgent,
    zoomEnabled: zoomEnabled,
    backgroundColor: backgroundColor,
    javascriptChannels: javascriptChannels,
    onPageStarted: onPageStarted,
    onPageFinished: onPageFinished,
    onProgress: onProgress,
    onWebResourceError: onWebResourceError,
    onNavigationRequest: onNavigationRequest,
    onJavaScriptMessage: onJavaScriptMessage,
    onScrollPositionChange: onScrollPositionChange,
    onConsoleMessage: onConsoleMessage,
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
  final WebViewController controller;
  final String initialContent;
  final bool javascriptEnabled;
  final dynamic javascriptMode;
  final bool allowNavigation;
  final bool debuggingEnabled;
  final String? userAgent;
  final bool zoomEnabled;
  final Color? backgroundColor;
  final Set<String> javascriptChannels;
  final void Function(String url)? onPageStarted;
  final void Function(String url)? onPageFinished;
  final void Function(int progress)? onProgress;
  final void Function(WebResourceError error)? onWebResourceError;
  final bool Function(NavigationRequest request)? onNavigationRequest;
  final void Function(String channelName, String messageBody)?
      onJavaScriptMessage;
  final void Function(int x, int y)? onScrollPositionChange;
  final void Function(JavaScriptConsoleMessage message)? onConsoleMessage;

  const _WebviewAllWidget({
    required this.controller,
    required this.initialContent,
    required this.javascriptEnabled,
    required this.javascriptMode,
    required this.allowNavigation,
    required this.debuggingEnabled,
    required this.userAgent,
    required this.zoomEnabled,
    required this.backgroundColor,
    required this.javascriptChannels,
    required this.onPageStarted,
    required this.onPageFinished,
    required this.onProgress,
    required this.onWebResourceError,
    required this.onNavigationRequest,
    required this.onJavaScriptMessage,
    required this.onScrollPositionChange,
    required this.onConsoleMessage,
  });

  @override
  State<_WebviewAllWidget> createState() => _WebviewAllWidgetState();
}

class _WebviewAllWidgetState extends State<_WebviewAllWidget> {
  late final WebViewController _controller;
  final Set<String> _registeredJavaScriptChannels = <String>{};

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    unawaited(_initialize());
  }

  @override
  void didUpdateWidget(covariant _WebviewAllWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.javascriptEnabled != widget.javascriptEnabled ||
        oldWidget.javascriptMode != widget.javascriptMode ||
        oldWidget.allowNavigation != widget.allowNavigation ||
        oldWidget.debuggingEnabled != widget.debuggingEnabled ||
        oldWidget.userAgent != widget.userAgent ||
        oldWidget.zoomEnabled != widget.zoomEnabled ||
        oldWidget.backgroundColor != widget.backgroundColor ||
        oldWidget.javascriptChannels != widget.javascriptChannels) {
      unawaited(_configureController());
    }

    if (oldWidget.initialContent != widget.initialContent) {
      unawaited(_loadContent(widget.initialContent));
    }
  }

  Future<void> _initialize() async {
    await _configureController();
    await _loadContent(widget.initialContent);
  }

  Future<void> _configureController() async {
    await _controller.setJavaScriptMode(_javascriptMode());
    await _controller.setNavigationDelegate(
      NavigationDelegate(
        onNavigationRequest: (NavigationRequest request) {
          final allowed = widget.onNavigationRequest?.call(request) ??
              (widget.allowNavigation ||
                  (!_looksLikeHtml(widget.initialContent) &&
                      request.url == widget.initialContent));
          if (allowed) {
            return NavigationDecision.navigate;
          }
          return NavigationDecision.prevent;
        },
        onPageStarted: widget.onPageStarted,
        onPageFinished: widget.onPageFinished,
        onProgress: widget.onProgress,
        onWebResourceError: widget.onWebResourceError,
      ),
    );
    await _controller.enableZoom(widget.zoomEnabled);
    await _controller.setOnScrollPositionChange((change) {
      widget.onScrollPositionChange?.call(change.x.round(), change.y.round());
    });
    await _syncJavaScriptChannels();

    if (widget.debuggingEnabled || widget.onConsoleMessage != null) {
      await _controller.setOnConsoleMessage((JavaScriptConsoleMessage message) {
        if (widget.debuggingEnabled) {
          debugPrint("FletWebviewAll console: ${message.message}");
        }
        widget.onConsoleMessage?.call(message);
      });
    }

    final userAgent = widget.userAgent;
    if (userAgent != null && userAgent.isNotEmpty) {
      await _controller.setUserAgent(userAgent);
    }

    final backgroundColor = widget.backgroundColor;
    if (backgroundColor != null) {
      await _controller.setBackgroundColor(backgroundColor);
    }
  }

  JavaScriptMode _javascriptMode() {
    final mode = widget.javascriptMode;
    if (mode is bool) {
      return mode ? JavaScriptMode.unrestricted : JavaScriptMode.disabled;
    }
    if (mode is String && mode.toLowerCase() == 'disabled') {
      return JavaScriptMode.disabled;
    }
    return widget.javascriptEnabled
        ? JavaScriptMode.unrestricted
        : JavaScriptMode.disabled;
  }

  Future<void> _syncJavaScriptChannels() async {
    final removed = _registeredJavaScriptChannels.difference(
      widget.javascriptChannels,
    );
    for (final channel in removed) {
      await _controller.removeJavaScriptChannel(channel);
      _registeredJavaScriptChannels.remove(channel);
    }
    final added = widget.javascriptChannels.difference(
      _registeredJavaScriptChannels,
    );
    for (final channel in added) {
      if (channel.trim().isEmpty) {
        continue;
      }
      await _controller.addJavaScriptChannel(
        channel,
        onMessageReceived: (message) {
          widget.onJavaScriptMessage?.call(channel, message.message);
        },
      );
      _registeredJavaScriptChannels.add(channel);
    }
  }

  Future<void> _loadContent(String content) {
    if (_looksLikeHtml(content)) {
      return _controller.loadHtmlString(content);
    }

    return _controller.loadRequest(Uri.parse(content));
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
