import 'package:flutter/material.dart';
import 'package:webview_all/webview_all.dart';

/// Build a Webview widget for mobile and desktop platforms
Widget buildWebviewWidget({
  required String initialContent,
  String? userAgent,
  bool zoomEnabled = true,
}) {
  return Webview(
    initialUrl: initialContent,
    userAgent: userAgent,
    zoomEnabled: zoomEnabled,
  );
}
