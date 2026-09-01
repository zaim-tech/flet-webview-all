import 'package:flutter/material.dart';

/// Build a fallback widget for web platform (webview_all not supported)
Widget buildWebviewWidget({
  required dynamic controller,
  required String initialContent,
  required bool javascriptEnabled,
  dynamic javascriptMode,
  required bool allowNavigation,
  required bool debuggingEnabled,
  String? userAgent,
  bool zoomEnabled = true,
  dynamic backgroundColor,
  Set<String> javascriptChannels = const <String>{},
  void Function(String url)? onPageStarted,
  void Function(String url)? onPageFinished,
  void Function(int progress)? onProgress,
  dynamic onWebResourceError,
  dynamic onNavigationRequest,
  void Function(String channelName, String messageBody)? onJavaScriptMessage,
  void Function(int x, int y)? onScrollPositionChange,
  dynamic onConsoleMessage,
  int? remoteDebuggingPort,
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
