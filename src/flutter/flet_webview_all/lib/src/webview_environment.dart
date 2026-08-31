import 'webview_environment_stub.dart'
    if (dart.library.io) 'webview_environment_io.dart' as platform;

/// Initializes platform-specific WebView process settings before the first
/// WebViewController is constructed.
Future<void> ensureWebViewEnvironment({required int remoteDebuggingPort}) {
  return platform.ensureWebViewEnvironment(
    remoteDebuggingPort: remoteDebuggingPort,
  );
}
