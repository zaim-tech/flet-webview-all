import 'package:adblocker_manager/adblocker_manager.dart';
import 'package:flutter/foundation.dart';

/// Process-wide ad-blocking engine shared by every FletWebviewAll control.
///
/// Filter lists (EasyList / AdGuard) are parsed once and reused. Allow and
/// block domain lists are *per control* and are passed on each call, so two
/// WebViews can use different policies while sharing one rule set.
class AdBlockEngine {
  AdBlockEngine({AdblockFilterManager? manager})
      : _manager = manager ?? AdblockFilterManager();

  static final AdBlockEngine instance = AdBlockEngine();

  final AdblockFilterManager _manager;
  Future<void>? _ready;

  int _blockedResourceCount = 0;
  final Map<String, int> _blockedDomains = <String, int>{};
  final Set<String> _appliedCssRules = <String>{};

  /// Loads the filter lists once per process. The first caller decides which
  /// lists are loaded; later calls with different lists are ignored.
  ///
  /// Never throws: if the lists cannot be loaded the WebView keeps working
  /// without list-based blocking, and the next call retries.
  Future<void> ensureReady(Iterable<String>? filters) {
    return _ready ??= _initialize(filters);
  }

  Future<void> _initialize(Iterable<String>? filters) async {
    try {
      final types = parseFilterTypes(filters);
      if (types.isEmpty) {
        // Only custom blocked domains are used.
        return;
      }
      await _manager.init(FilterConfig(filterTypes: types));
    } catch (error, stackTrace) {
      debugPrint('FletWebviewAll: ad-block filters failed to load: $error');
      debugPrintStack(stackTrace: stackTrace);
      _ready = null;
    }
  }

  /// Maps the Python-side names to [FilterType]. `null` selects every list.
  @visibleForTesting
  static List<FilterType> parseFilterTypes(Iterable<String>? names) {
    if (names == null) {
      return <FilterType>[FilterType.easyList, FilterType.adGuard];
    }
    final types = <FilterType>[];
    for (final name in names) {
      final key = name.toLowerCase().replaceAll(RegExp('[^a-z]'), '');
      FilterType? type;
      if (key == 'easylist') {
        type = FilterType.easyList;
      } else if (key == 'adguard') {
        type = FilterType.adGuard;
      } else {
        debugPrint('FletWebviewAll: unknown ad_block_filters entry "$name"');
      }
      if (type != null && !types.contains(type)) {
        types.add(type);
      }
    }
    return types;
  }

  /// Whether [url] should be blocked. Only http(s) URLs are ever blocked.
  bool shouldBlock(
    String url, {
    Set<String> allowedDomains = const <String>{},
    Set<String> blockedDomains = const <String>{},
  }) {
    final uri = Uri.tryParse(url);
    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
      return false;
    }
    final host = uri.host.toLowerCase();
    if (host.isEmpty || _matchesDomain(host, allowedDomains)) {
      return false;
    }

    var block = _matchesDomain(host, blockedDomains);
    if (!block && _manager.isInitialized) {
      block = _manager.shouldBlockResource(url);
    }
    if (block) {
      _blockedResourceCount++;
      _blockedDomains.update(host, (count) => count + 1, ifAbsent: () => 1);
    }
    return block;
  }

  /// Element-hiding CSS for the page at [url], or `null` when there is none
  /// (disabled for this domain, filters not loaded, or no matching rules).
  String? cosmeticCss(
    String url, {
    Set<String> allowedDomains = const <String>{},
  }) {
    final host = Uri.tryParse(url)?.host.toLowerCase() ?? '';
    if (host.isEmpty ||
        !_manager.isInitialized ||
        _matchesDomain(host, allowedDomains)) {
      return null;
    }

    final rules = _manager.getCSSRulesForWebsite(host);
    if (rules.isEmpty) {
      return null;
    }
    _appliedCssRules.addAll(rules);

    // Rules may be full CSS rules or bare selectors; accept both. Each rule
    // stays separate so one invalid selector cannot discard the others.
    return rules
        .map((rule) => rule.contains('{')
            ? rule
            : '$rule{display:none !important}')
        .join('\n');
  }

  Map<String, dynamic> stats() => <String, dynamic>{
        'blocked_resource_count': _blockedResourceCount,
        'css_rules_applied_count': _appliedCssRules.length,
        'blocked_domains': Map<String, int>.of(_blockedDomains),
      };

  void resetStatistics() {
    _blockedResourceCount = 0;
    _blockedDomains.clear();
    _appliedCssRules.clear();
  }

  static bool _matchesDomain(String host, Set<String> domains) {
    for (final raw in domains) {
      var domain = raw.trim().toLowerCase();
      if (domain.startsWith('.')) {
        domain = domain.substring(1);
      }
      if (domain.isNotEmpty && (host == domain || host.endsWith('.$domain'))) {
        return true;
      }
    }
    return false;
  }
}
