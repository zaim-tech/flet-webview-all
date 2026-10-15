# Ad blocking

Ad and tracker blocking is built in and enabled by default. It uses the
EasyList and AdGuard filter lists through
[`adblocker_manager`](https://pub.dev/packages/adblocker_manager).

## Configure blocking

```python
from flet_webview_all import FletWebviewAll

# Blocking is enabled by default.
webview = FletWebviewAll(url="https://example.com", expand=True)

# Allow a domain and its subdomains; always block another domain.
webview = FletWebviewAll(
    url="https://example.com",
    ad_block_allowed_domains=["trusted-site.com"],
    ad_block_blocked_domains=["ads.example.com"],
    on_ad_blocked=lambda e: print("blocked", e.url, e.is_main_frame),
)

# Opt out for this WebView.
webview = FletWebviewAll(
    url="https://example.com",
    ad_block_enabled=False,
)
```

| Property | Type | Default | Description |
| --- | --- | --- | --- |
| `ad_block_enabled` | `bool` | `True` | Block ads and trackers and hide ad elements. |
| `ad_block_filters` | `list[str] \| None` | `None` | Filter lists to load: `"easylist"` and/or `"adguard"`. `None` loads both. |
| `ad_block_allowed_domains` | `list[str] \| None` | `None` | Skip blocking for these domains and their subdomains. |
| `ad_block_blocked_domains` | `list[str] \| None` | `None` | Always block these domains and their subdomains, in addition to filter-list rules. |

## Observe blocked requests and stats

The `on_ad_blocked` event provides the blocked URL and whether it was a main
frame navigation:

```python
def ad_blocked(e):
    print("Blocked:", e.url, "main frame:", e.is_main_frame)

webview = FletWebviewAll(
    url="https://example.com",
    on_ad_blocked=ad_blocked,
)
```

Read or reset the app-wide counters asynchronously:

```python
stats = await webview.get_ad_block_stats()
print(stats["blocked_resource_count"])
print(stats["css_rules_applied_count"])
print(stats["blocked_domains"])

await webview.reset_ad_block_stats()
```

`blocked_domains` maps domains to hit counts. The counters are shared across
all WebViews in the application.

## Behavior and limitations

- Filter lists are loaded once per application and shared by all WebViews.
  The first WebView to start determines which lists are loaded; per-control
  filter-list settings on later WebViews do not replace them.
- Blocking covers navigations, including ad iframes and pop-up redirects.
  Ad elements are hidden with CSS after the page finishes loading.
- Individual sub-resource requests such as scripts, images, and XHR are not
  intercepted before they load. Network traffic can still occur, and ad
  elements may briefly appear before CSS hides them.
- If filter lists fail to load, the WebView continues without list-based
  blocking. Custom blocked domains still apply.
- Changing `ad_block_enabled` or either domain list at runtime reloads the
  page.

See [Properties](properties.md), [Events](events.md), and
[Controller methods](methods.md) for the corresponding API reference.