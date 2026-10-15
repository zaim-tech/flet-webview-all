import 'package:adblocker_manager/adblocker_manager.dart';
import 'package:flet_webview_all/src/ad_block_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdBlockEngine.parseFilterTypes', () {
    test('null selects every bundled list', () {
      expect(
        AdBlockEngine.parseFilterTypes(null),
        <FilterType>[FilterType.easyList, FilterType.adGuard],
      );
    });

    test('is case-insensitive, ignores separators and de-duplicates', () {
      expect(
        AdBlockEngine.parseFilterTypes(<String>['EasyList', 'easy_list']),
        <FilterType>[FilterType.easyList],
      );
      expect(
        AdBlockEngine.parseFilterTypes(<String>['AdGuard']),
        <FilterType>[FilterType.adGuard],
      );
    });

    test('unknown names are ignored and empty means custom domains only', () {
      expect(AdBlockEngine.parseFilterTypes(<String>['bogus']), isEmpty);
      expect(AdBlockEngine.parseFilterTypes(<String>[]), isEmpty);
    });
  });

  group('AdBlockEngine domain policy (no filter lists loaded)', () {
    late AdBlockEngine engine;

    setUp(() => engine = AdBlockEngine());

    test('blocks custom domains and their subdomains only', () {
      const blocked = <String>{'ads.example.com'};
      expect(
        engine.shouldBlock('https://ads.example.com/x.js',
            blockedDomains: blocked),
        isTrue,
      );
      expect(
        engine.shouldBlock('https://cdn.ads.example.com/x.js',
            blockedDomains: blocked),
        isTrue,
      );
      expect(
        engine.shouldBlock('https://example.com/', blockedDomains: blocked),
        isFalse,
      );
      expect(
        engine.shouldBlock('https://notads.example.com/',
            blockedDomains: blocked),
        isFalse,
      );
    });

    test('allowed domains win over blocked domains', () {
      expect(
        engine.shouldBlock(
          'https://ads.example.com/x.js',
          allowedDomains: <String>{'example.com'},
          blockedDomains: <String>{'ads.example.com'},
        ),
        isFalse,
      );
    });

    test('never blocks non-http(s) URLs', () {
      const blocked = <String>{'example.com'};
      expect(engine.shouldBlock('about:blank', blockedDomains: blocked), isFalse);
      expect(
        engine.shouldBlock('data:text/html,hi', blockedDomains: blocked),
        isFalse,
      );
      expect(engine.shouldBlock('not a url', blockedDomains: blocked), isFalse);
    });

    test('counts blocked requests per domain and can reset', () {
      const blocked = <String>{'ads.example.com'};
      engine.shouldBlock('https://ads.example.com/a', blockedDomains: blocked);
      engine.shouldBlock('https://ads.example.com/b', blockedDomains: blocked);

      var stats = engine.stats();
      expect(stats['blocked_resource_count'], 2);
      expect(stats['blocked_domains'], <String, int>{'ads.example.com': 2});

      engine.resetStatistics();
      stats = engine.stats();
      expect(stats['blocked_resource_count'], 0);
      expect(stats['blocked_domains'], isEmpty);
    });

    test('cosmeticCss is null until filters are loaded', () {
      expect(engine.cosmeticCss('https://example.com/'), isNull);
    });
  });
}
