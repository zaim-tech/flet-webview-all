import 'dart:async';

import 'package:flet_webview_all/src/webview_environment_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WebViewEnvironmentManager', () {
    test('rejects ports outside the TCP range', () async {
      var initializationCount = 0;
      final manager = WebViewEnvironmentManager(
        initialize: (_) {
          initializationCount++;
          return Future<void>.value();
        },
      );

      for (final port in <int>[-1, 0, 65536]) {
        await expectLater(
          manager.ensureInitialized(remoteDebuggingPort: port),
          throwsA(isA<ArgumentError>()),
        );
      }

      expect(initializationCount, 0);
    });

    test('passes loopback-only CDP arguments to WebView2', () async {
      String? receivedArguments;
      final manager = WebViewEnvironmentManager(
        initialize: (additionalArguments) {
          receivedArguments = additionalArguments;
          return Future<void>.value();
        },
      );

      await manager.ensureInitialized(remoteDebuggingPort: 9222);

      expect(
        receivedArguments,
        '--remote-debugging-port=9222 '
        '--remote-debugging-address=127.0.0.1',
      );
    });

    test(
      'shares one initialization for concurrent requests to the same port',
      () async {
        final initialization = Completer<void>();
        var initializationCount = 0;
        final manager = WebViewEnvironmentManager(
          initialize: (_) {
            initializationCount++;
            return initialization.future;
          },
        );

        final first = manager.ensureInitialized(remoteDebuggingPort: 9222);
        final second = manager.ensureInitialized(remoteDebuggingPort: 9222);

        expect(identical(first, second), isTrue);
        expect(initializationCount, 1);

        initialization.complete();
        await Future.wait(<Future<void>>[first, second]);
      },
    );

    test('rejects a different port after initialization starts', () async {
      final initialization = Completer<void>();
      final manager = WebViewEnvironmentManager(
        initialize: (_) => initialization.future,
      );

      final first = manager.ensureInitialized(remoteDebuggingPort: 9222);

      await expectLater(
        manager.ensureInitialized(remoteDebuggingPort: 9333),
        throwsA(isA<StateError>()),
      );

      initialization.complete();
      await first;
    });

    test('allows the same port to retry after asynchronous failure', () async {
      var attempts = 0;
      final manager = WebViewEnvironmentManager(
        initialize: (_) {
          attempts++;
          if (attempts == 1) {
            return Future<void>.error(StateError('temporary failure'));
          }
          return Future<void>.value();
        },
      );

      await expectLater(
        manager.ensureInitialized(remoteDebuggingPort: 9222),
        throwsA(isA<StateError>()),
      );
      await manager.ensureInitialized(remoteDebuggingPort: 9222);

      expect(attempts, 2);
    });

    test(
      'converts synchronous initialization errors into Future errors',
      () async {
        var attempts = 0;
        final manager = WebViewEnvironmentManager(
          initialize: (_) {
            attempts++;
            if (attempts == 1) {
              throw StateError('synchronous failure');
            }
            return Future<void>.value();
          },
        );

        final failedInitialization = manager.ensureInitialized(
          remoteDebuggingPort: 9222,
        );

        await expectLater(failedInitialization, throwsA(isA<StateError>()));
        await manager.ensureInitialized(remoteDebuggingPort: 9222);

        expect(attempts, 2);
      },
    );
  });
}
