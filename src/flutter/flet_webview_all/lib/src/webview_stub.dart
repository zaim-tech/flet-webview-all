import 'package:flutter/material.dart';

/// Build a fallback widget for web platform (webview_all not supported)
Widget buildWebviewWidget({
  required String initialContent,
  required bool javascriptEnabled,
  required bool allowNavigation,
  String? userAgent,
  bool zoomEnabled = true,
}) {
  // Extract URL from initialContent for display
  String? displayUrl;
  if (!initialContent.startsWith('<') && initialContent != 'about:blank') {
    displayUrl = initialContent;
  }

  return Container(
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
            if (displayUrl != null) ...[
              const SizedBox(height: 16),
              SelectableText(
                'URL: $displayUrl',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}
