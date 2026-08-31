typedef WebViewEnvironmentInitializer = Future<void> Function(
    String additionalArguments);

/// Coordinates the one-time configuration of the shared WebView2 environment.
class WebViewEnvironmentManager {
  WebViewEnvironmentManager({required WebViewEnvironmentInitializer initialize})
      : _initialize = initialize;

  final WebViewEnvironmentInitializer _initialize;

  Future<void>? _initialization;
  int? _configuredRemoteDebuggingPort;

  Future<void> ensureInitialized({required int remoteDebuggingPort}) {
    if (remoteDebuggingPort < 1 || remoteDebuggingPort > 65535) {
      return Future<void>.error(
        ArgumentError.value(
          remoteDebuggingPort,
          'remoteDebuggingPort',
          'must be between 1 and 65535',
        ),
      );
    }

    final existingInitialization = _initialization;
    if (existingInitialization != null) {
      if (_configuredRemoteDebuggingPort != remoteDebuggingPort) {
        return Future<void>.error(
          StateError(
            'WebView2 uses one shared environment per process. '
            'It is already configured for remote debugging on port '
            '$_configuredRemoteDebuggingPort and cannot be changed to '
            '$remoteDebuggingPort without restarting the app.',
          ),
        );
      }
      return existingInitialization;
    }

    final additionalArguments = '--remote-debugging-port=$remoteDebuggingPort '
        '--remote-debugging-address=127.0.0.1';

    _configuredRemoteDebuggingPort = remoteDebuggingPort;

    late final Future<void> initialization;
    initialization = Future<void>.sync(() => _initialize(additionalArguments))
        .onError((Object error, StackTrace stackTrace) {
      // webview_all_windows supports retrying a failed environment startup.
      // Do not keep returning the same failed Future forever.
      if (identical(_initialization, initialization)) {
        _initialization = null;
        _configuredRemoteDebuggingPort = null;
      }
      Error.throwWithStackTrace(error, stackTrace);
    });

    _initialization = initialization;
    return initialization;
  }
}
