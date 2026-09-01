# Scrolling, debugging, and advanced browser APIs

This page documents the portable features exposed by `FletWebviewAll` and
points to the upstream platform APIs where behavior is engine-specific.

## Scrolling

All scrolling methods are asynchronous and use document pixels:

```python
await webview.scroll_to(0, 0)
await webview.scroll_by(0, 300)

position = await webview.get_scroll_position()
print(position["x"], position["y"])
```

Subscribe to scroll changes with `on_scroll_position_change`:

```python
def scrolled(e):
    print(f"scroll position: {e.x}, {e.y}")

webview.on_scroll_position_change = scrolled
page.update()
```

Scrollbar visibility is capability-gated. Always check support before changing
it:

```python
async def hide_scrollbars():
    if await webview.supports_set_scrollbars_enabled():
        await webview.set_vertical_scrollbar_enabled(False)
        await webview.set_horizontal_scrollbar_enabled(False)
```

Since `webview_all` 1.3.2, rendering remains engine-specific. macOS reports
this capability as unsupported because public `WKWebView` does not expose its
internal scroll view. Web and Windows implement visibility with injected CSS.

## Debugging and inspection

Debugging differs by platform. Keep inspection disabled in production builds.

### Windows

For the Flet control, use `remote_debugging_port` and Playwright/CDP. See the
[Playwright guide](FletWebviewAll.md#playwright-on-windows-webview2-cdp).

The Python control also provides Windows convenience methods:

```python
async def inspect_webview(_):
    version = await webview.get_webview_version()
    print("WebView2 runtime:", version)
    await webview.open_devtools()
```

These methods raise an unsupported-platform error outside Windows. For
automation, `remote_debugging_port` is usually preferable because it exposes a
stable CDP endpoint to Playwright.

### Android

Use the platform's WebView inspection tools (for example, Chrome or Edge
remote debugging) when supported by the device and OS.

### iOS and macOS

WebKit inspection availability depends on the OS version and developer
settings. Enable inspection using the device's normal development settings.

### Linux

Use the WebKitGTK inspector supplied by the Linux runtime when available.

### OHOS and Web

Use the browser or device developer tools supplied by the target platform. On
Web, the control is rendered in an iframe and browser same-origin rules apply.

## Console capture

Set `debugging_enabled=True` on the Flet control to forward page console
messages to the platform debug log.

Avoid uploading page content or sensitive console values without user consent.

Python applications can receive console messages as typed Flet events:

```python
def console_message(e):
    print(f"[{e.level}] {e.message}")

webview = FletWebviewAll(
    url="https://example.com",
    on_console_message=console_message,
)
```

`debugging_enabled=True` continues to print messages through the platform
debug log; `on_console_message` is useful when the Python app needs to display
or record them.

On Web, cross-origin iframe content cannot be scripted by the host. APIs such
as JavaScript evaluation, channels, console hooks, and scroll reads/writes
require same-origin content or plugin-managed isolated HTML.

See the [upstream common API](https://abandoft.github.io/webview_all/reference/common-api/)
for platform controller details.
