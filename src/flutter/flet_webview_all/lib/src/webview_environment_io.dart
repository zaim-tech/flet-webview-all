import 'dart:io';

import 'package:webview_all_windows/webview_all_windows.dart';
import 'webview_environment_manager.dart';

final _environmentManager = WebViewEnvironmentManager(
  initialize: (additionalArguments) =>
      WindowsWebViewController.initializeEnvironment(
    additionalArguments: additionalArguments,
  ),
);

Future<void> ensureWebViewEnvironment({required int remoteDebuggingPort}) {
  if (!Platform.isWindows) {
    return Future<void>.value();
  }

  return _environmentManager.ensureInitialized(
    remoteDebuggingPort: remoteDebuggingPort,
  );
}
