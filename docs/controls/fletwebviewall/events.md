# Events

| Handler | Event fields | Description |
| --- | --- | --- |
| `on_page_started` | `url` | A page has started loading. |
| `on_page_finished` | `url` | A page has completed loading. |
| `on_progress` | `progress` | Page progress from 0 to 100. |
| `on_web_resource_error` | `domain`, `description`, `error_code`, `error_type`, `is_for_main_frame` | A resource could not be loaded. |
| `on_navigation_request` | `url`, `is_main_frame` | A navigation request was observed. |
| `on_javascript_message` | `channel_name`, `message_body` | A registered JavaScript channel posted a message. |
| `on_permission_request` | `resource_types` | A page requested protected WebView resources. |
| `on_scroll_position_change` | `x`, `y` | The document scroll position changed. |
| `on_console_message` | `level`, `message` | A page wrote to the JavaScript console. |

!!! warning "`on_navigation_request` is observational"
    Since Flet control events are asynchronous, its Python handler cannot
    return an immediate navigation decision. Use `allow_navigation=False`
    to block navigations (except the initial URL) or set that property
    before navigation begins — see
    [Navigation and zoom](properties.md#navigation-and-zoom).

## Callback examples

```python
def started(e):
    print("Loading", e.url)

def finished(e):
    print("Loaded", e.url)

def progress_changed(e):
    print(f"Progress: {e.progress}%")

def resource_failed(e):
    print(e.domain, e.error_code, e.description, e.is_for_main_frame)

def navigation_requested(e):
    print("Requested", e.url, "main frame:", e.is_main_frame)

def javascript_message(e):
    print(e.channel_name, e.message_body)

webview = FletWebviewAll(
    url="https://example.com",
    on_page_started=started,
    on_page_finished=finished,
    on_progress=progress_changed,
    on_web_resource_error=resource_failed,
    on_navigation_request=navigation_requested,
    javascript_channels=["FletBridge"],
    on_javascript_message=javascript_message,
)
```

The navigation callback is observational. Use `allow_navigation` to enforce
a policy; changing it from the callback is asynchronous and cannot affect
the already pending native decision.

## Related recipes

- [Display a loading indicator](../../guides/examples.md#display-a-loading-indicator)
  using `on_page_started` / `on_progress` / `on_page_finished`.
- [Handle failed resources](../../guides/examples.md#handle-failed-resources)
  using `on_web_resource_error`.
- [Console capture](../../guides/console.md) for `on_console_message` and
  `debugging_enabled`.
- [Permissions](../../guides/permissions.md) for `on_permission_request`.
- [Scrolling](../../guides/scrolling.md) for `on_scroll_position_change`.
