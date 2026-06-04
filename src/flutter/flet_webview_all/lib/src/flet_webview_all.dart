import 'package:flet/flet.dart';
import 'package:flutter/material.dart';
import 'webview_impl.dart';

class FletWebviewAllControl extends StatelessWidget {
  final Control control;

  const FletWebviewAllControl({
    super.key,
    required this.control,
  });

  @override
  Widget build(BuildContext context) {
    String? url = control.getString("url");
    String? html = control.getString("html");
    bool allowNavigation = control.getBool("allow_navigation", true) ?? true;
    bool zoomEnabled = control.getBool("zoom_enabled", true) ?? true;
    bool javascriptEnabled = control.getBool("javascript_enabled", true) ?? true;
    bool debuggingEnabled = control.getBool("debugging_enabled", false) ?? false;
    String? userAgent = control.getString("user_agent");

    // Determine initial content - use url if available, otherwise html
    String initialContent = url ?? html ?? "about:blank";

    // Use the platform-specific implementation imported above
    Widget myControl = buildWebviewWidget(
      initialContent: initialContent,
      javascriptEnabled: javascriptEnabled,
      allowNavigation: allowNavigation,
      debuggingEnabled: debuggingEnabled,
      userAgent: userAgent,
      zoomEnabled: zoomEnabled,
    );

    return LayoutControl(control: control, child: myControl);
  }
}
