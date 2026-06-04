import 'package:flet/flet.dart';
import 'package:flutter/material.dart';
import 'package:webview_all/webview_all.dart';

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
    bool zoomEnabled = control.getBool("zoom_enabled", true) ?? true;
    bool javascriptEnabled = control.getBool("javascript_enabled", true) ?? true;
    String? userAgent = control.getString("user_agent");

    // Determine initial content - use url if available, otherwise html
    String initialContent = url ?? html ?? "about:blank";

    Widget myControl = Webview(
      initialUrl: initialContent,
      userAgent: userAgent,
      zoomEnabled: zoomEnabled,
    );

    return LayoutControl(control: control, child: myControl);
  }
}
