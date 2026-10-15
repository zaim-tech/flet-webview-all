## Ad blocking

Ad and tracker blocking is built in and **enabled by default**. It uses the
EasyList and AdGuard filter lists via
[`adblocker_manager`](https://pub.dev/packages/adblocker_manager).

```python
FletWebviewAll(url="https://example.com", expand=True)            # blocking on

FletWebviewAll(
    url="https://example.com",
    ad_block_allowed_domains=["trusted-site.com"],   # never block here (subdomains too)
    ad_block_blocked_domains=["ads.example.com"],    # always block
    on_ad_blocked=lambda e: print("blocked", e.url, e.is_main_frame),
)

FletWebviewAll(url="https://example.com", ad_block_enabled=False)  # opt out
```

| Property | Type | Default | Description |
| --- | --- | --- | --- |
| `ad_block_enabled` | `bool` | `True` | Block ads/trackers and hide ad elements. |
| `ad_block_filters` | `list[str] \| None` | `None` | `"easylist"`, `"adguard"`. `None` loads both. |
| `ad_block_allowed_domains` | `list[str] \| None` | `None` | Skip blocking on these domains and subdomains. |
| `ad_block_blocked_domains` | `list[str] \| None` | `None` | Always block these domains and subdomains. |

Event `on_ad_blocked` gives `e.url` and `e.is_main_frame`. Methods
`await webview.get_ad_block_stats()` (keys `blocked_resource_count`,
`css_rules_applied_count`, `blocked_domains`) and
`await webview.reset_ad_block_stats()`.

Notes:

- Filter lists load once per application and are shared by all WebViews; the
  first WebView to start decides which lists are loaded. Statistics are also
  application-wide.
- Blocking covers navigations (including ad iframes and pop-up redirects) and
  hides ad elements with CSS after the page finishes loading. It does not
  intercept individual sub-resource requests (scripts, images, XHR) before
  they load, so ad network traffic can still occur and elements may flash
  briefly before being hidden.
- If the filter lists fail to load, the WebView keeps working without
  list-based blocking (custom blocked domains still apply).
- Changing `ad_block_enabled` or the domain lists at runtime reloads the page.
