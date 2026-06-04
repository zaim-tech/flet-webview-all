import 'package:flet/flet.dart';
import 'package:flutter/material.dart';
import 'package:webview_all/webview_all.dart';

class FletWebviewAllControl extends StatefulWidget {
  final Control control;

  const FletWebviewAllControl({
    super.key,
    required this.control,
  });

  @override
  State<FletWebviewAllControl> createState() => _FletWebviewAllControlState();
}

class _FletWebviewAllControlState extends State<FletWebviewAllControl> {
  late WebviewAllController _webViewController;

  @override
  void initState() {
    super.initState();
    _setupWebViewController();
  }

  void _setupWebViewController() {
    WebviewAllController.platform.setWebviewAllDebuggingEnabled(
      widget.control.getBool("debugging_enabled", false) ?? false,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String? url = widget.control.getString("url");
    String? html = widget.control.getString("html");
    bool allowNavigation = widget.control.getBool("allow_navigation", true) ?? true;
    bool zoomEnabled = widget.control.getBool("zoom_enabled", true) ?? true;
    bool javascriptEnabled = widget.control.getBool("javascript_enabled", true) ?? true;
    String? userAgent = widget.control.getString("user_agent");

    // Determine initial content
    if (url == null && html == null) {
      url = "about:blank";
    }

    Widget myControl = WebviewAll(
      onWebviewCreated: (controller) {
        _webViewController = controller;
      },
      initialUrl: url,
      initialContent: html,
      javascriptMode: javascriptEnabled
          ? JavascriptMode.unrestricted
          : JavascriptMode.disabled,
      navigationDelegate: allowNavigation
          ? null
          : (NavigationRequest request) {
              return NavigationDecision.prevent;
            },
      userAgent: userAgent ?? "",
      gestureNavigationEnabled: true,
      onPageStarted: (String url) {
        debugPrint('Page started loading: $url');
      },
      onPageFinished: (String url) {
        debugPrint('Page finished loading: $url');
      },
      onWebResourceError: (WebResourceError error) {
        debugPrint('Error: ${error.description}');
      },
      onProgress: (int progress) {
        debugPrint('Progress: $progress%');
      },
      zoomEnabled: zoomEnabled,
    );

    return LayoutControl(control: widget.control, child: myControl);
  }
}
