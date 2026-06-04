import 'package:flet/flet.dart';
import 'package:flutter/material.dart';
#if !dart.library.html
import 'package:webview_all/webview_all.dart';
#endif

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

#if dart.library.html
    // Web platform fallback - webview_all is not supported on web
    Widget myControl = Container(
      color: Colors.grey[100],
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.language, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'WebView not supported on Web',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Use mobile/desktop for WebView support',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              if (url != null) ...[
                const SizedBox(height: 16),
                SelectableText(
                  'URL: $url',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ],
          ),
        ),
      ),
    );
#else
    // Mobile and desktop platforms use webview_all
    Widget myControl = Webview(
      initialUrl: initialContent,
      userAgent: userAgent,
      zoomEnabled: zoomEnabled,
    );
#endif

    return LayoutControl(control: control, child: myControl);
  }
}
