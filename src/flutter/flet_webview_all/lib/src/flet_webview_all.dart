import 'package:flet/flet.dart';
import 'package:flutter/material.dart';
import 'package:webview_all/webview_all.dart';
import 'package:webview_all_windows/webview_all_windows.dart';
import 'webview_impl.dart';

class FletWebviewAllControl extends StatefulWidget {
  final Control control;

  const FletWebviewAllControl({super.key, required this.control});

  @override
  State<FletWebviewAllControl> createState() => _FletWebviewAllControlState();
}

class _FletWebviewAllControlState extends State<FletWebviewAllControl> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController(
      onPermissionRequest: _onPermissionRequest,
    );
    widget.control.addInvokeMethodListener(_invokeMethod);
  }

  Future<void> _onPermissionRequest(WebViewPermissionRequest request) async {
    widget.control.triggerEvent("permission_request", {
      "resource_types": request.types.map((type) => type.name).toList(),
    });
    if (widget.control.getBool("allow_webview_permissions", false) ?? false) {
      await request.grant();
    } else {
      await request.deny();
    }
  }

  @override
  void dispose() {
    widget.control.removeInvokeMethodListener(_invokeMethod);
    super.dispose();
  }

  Future<dynamic> _invokeMethod(String name, dynamic args) async {
    switch (name) {
      case "reload":
        return _controller.reload();
      case "stop_loading":
        // webview_all does not expose a native stop-loading API. This is the
        // browser-standard best effort supported by all of its engines.
        return _controller.runJavaScript("window.stop();");
      case "can_go_back":
        return _controller.canGoBack();
      case "go_back":
        return _controller.goBack();
      case "can_go_forward":
        return _controller.canGoForward();
      case "go_forward":
        return _controller.goForward();
      case "clear_cache":
        return _controller.clearCache();
      case "clear_cookies":
        return WebViewCookieManager().clearCookies();
      case "get_current_url":
        return _controller.currentUrl();
      case "run_javascript":
        return _controller.runJavaScript((args as Map?)?["script"] as String);
      case "run_javascript_returning_result":
        return _controller.runJavaScriptReturningResult(
          (args as Map?)?["script"] as String,
        );
      case "scroll_to":
        final map = args as Map;
        return _controller.scrollTo(map["x"] as int, map["y"] as int);
      case "scroll_by":
        final map = args as Map;
        return _controller.scrollBy(map["x"] as int, map["y"] as int);
      case "get_scroll_position":
        final position = await _controller.getScrollPosition();
        return {"x": position.dx.round(), "y": position.dy.round()};
      case "supports_set_scrollbars_enabled":
        return _controller.supportsSetScrollBarsEnabled();
      case "set_vertical_scrollbar_enabled":
        return _controller.setVerticalScrollBarEnabled(
          ((args as Map)["enabled"] as bool?) ?? true,
        );
      case "set_horizontal_scrollbar_enabled":
        return _controller.setHorizontalScrollBarEnabled(
          ((args as Map)["enabled"] as bool?) ?? true,
        );
      case "open_devtools":
        final platform = _controller.platform;
        if (platform is WindowsWebViewController) {
          return platform.openDevTools();
        }
        throw UnsupportedError("DevTools opening is only supported on Windows");
      case "get_webview_version":
        if (_controller.platform is WindowsWebViewController) {
          return WindowsWebViewController.getWebViewVersion();
        }
        throw UnsupportedError("WebView runtime version is only available on Windows");
      default:
        throw Exception("Unknown FletWebviewAll method: $name");
    }
  }

  @override
  Widget build(BuildContext context) {
    final control = widget.control;
    final url = control.getString("url");
    final html = control.getString("html");
    final allowNavigation = control.getBool("allow_navigation", true) ?? true;
    final zoomEnabled = control.getBool("zoom_enabled", true) ?? true;
    final javascriptEnabled =
        control.getBool("javascript_enabled", true) ?? true;
    final javascriptMode = control.get("javascript_mode");
    final debuggingEnabled =
        control.getBool("debugging_enabled", false) ?? false;
    final userAgent = control.getString("user_agent");
    final backgroundColor = control.getColor("background_color", context);
    final remoteDebuggingPort = control.getInt("remote_debugging_port");
    final javascriptChannels = (control.get("javascript_channels") as List?)
            ?.whereType<String>()
            .toSet() ??
        const <String>{};

    final initialContent = url ?? html ?? "about:blank";
    final myControl = buildWebviewWidget(
      controller: _controller,
      initialContent: initialContent,
      javascriptEnabled: javascriptEnabled,
      javascriptMode: javascriptMode,
      allowNavigation: allowNavigation,
      debuggingEnabled: debuggingEnabled,
      userAgent: userAgent,
      zoomEnabled: zoomEnabled,
      backgroundColor: backgroundColor,
      javascriptChannels: javascriptChannels,
      onPageStarted: (url) =>
          control.triggerEvent("page_started", {"url": url}),
      onPageFinished: (url) =>
          control.triggerEvent("page_finished", {"url": url}),
      onProgress: (progress) =>
          control.triggerEvent("progress", {"progress": progress}),
      onWebResourceError: (error) =>
          control.triggerEvent("web_resource_error", {
        "domain": Uri.tryParse(error.url ?? "")?.host ?? error.url ?? "",
        "description": error.description,
        "error_code": error.errorCode,
        "error_type": error.errorType.toString(),
        "is_for_main_frame": error.isForMainFrame ?? false,
      }),
      onNavigationRequest: (request) {
        control.triggerEvent("navigation_request", {
          "url": request.url,
          "is_main_frame": request.isMainFrame,
        });
        return allowNavigation ||
            (!_looksLikeHtml(initialContent) && request.url == initialContent);
      },
      onJavaScriptMessage: (channelName, messageBody) =>
          control.triggerEvent("javascript_message", {
        "channel_name": channelName,
        "message_body": messageBody,
      }),
      onScrollPositionChange: (x, y) =>
          control.triggerEvent("scroll_position_change", {"x": x, "y": y}),
      onConsoleMessage: (message) =>
          control.triggerEvent("console_message", {
            "message": message.message,
            "level": message.level.name,
          }),
      remoteDebuggingPort: remoteDebuggingPort,
    );

    return LayoutControl(control: control, child: myControl);
  }

  bool _looksLikeHtml(String content) {
    final trimmed = content.trimLeft().toLowerCase();
    return trimmed.startsWith('<!doctype html') || trimmed.startsWith('<html');
  }
}
