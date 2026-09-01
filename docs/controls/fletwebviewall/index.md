# FletWebviewAll

`FletWebviewAll` is a Flet extension control that provides a unified webview
for displaying web content across all platforms. It wraps the `webview_all`
Flutter package, offering seamless integration of web content within Flet
applications.

This control extends `ft.LayoutControl`, inheriting all its layout and
styling properties while adding webview-specific functionality.

**Inheritance:** `FletWebviewAll` → `ft.LayoutControl` → `ft.Control`

## What's on each page

| Page | Covers |
| --- | --- |
| [Properties](properties.md) | `url`, `html`, navigation, zoom, JavaScript, user agent, debugging, background color, permissions flag, remote debugging port, plus everything inherited from `LayoutControl` |
| [Events](events.md) | Lifecycle, navigation, JavaScript-message, permission-request, scroll, and console events |
| [Controller methods](methods.md) | Async methods for history, reload, cache/cookies, running JavaScript, and scrolling |
| [Playwright (Windows CDP)](playwright.md) | Attaching Playwright to the visible WebView2 instance for automated testing |

## Complete application example

The following application demonstrates URL and HTML loading, every
lifecycle callback, the JavaScript bridge, history controls, runtime
settings, and the JavaScript controller methods. Save it as `main.py`,
install `flet-webview-all`, and run it with `flet run main.py`.

```python
import flet as ft
from flet_webview_all import FletWebviewAll


HTML = """<!doctype html>
<html><head><title>Bridge demo</title></head>
<body>
  <h1>FletWebviewAll</h1>
  <button onclick="FletBridge.postMessage('Button clicked')">
    Send message to Flet
  </button>
</body></html>"""


def main(page: ft.Page):
    page.title = "WebView controller demo"
    page.padding = 0

    address = ft.TextField(value="https://example.com", expand=True)
    status = ft.Text("Ready")
    progress = ft.ProgressBar(value=0, expand=True)
    webview = FletWebviewAll(expand=True)

    def set_status(value):
        status.value = value
        page.update()

    def load_url(_):
        value = (address.value or "").strip()
        if value and not value.startswith(("http://", "https://")):
            value = "https://" + value
        if value:
            webview.url, webview.html = value, None
            page.update()

    def load_html(_):
        webview.url, webview.html = None, HTML
        page.update()

    async def back(_):
        if await webview.can_go_back():
            await webview.go_back()

    async def forward(_):
        if await webview.can_go_forward():
            await webview.go_forward()

    async def reload(_):
        await webview.reload()

    async def read_title(_):
        title = await webview.run_javascript_returning_result("document.title")
        set_status(f"Title: {title}")

    async def clear_browser_data(_):
        await webview.clear_cache()
        await webview.clear_cookies()
        set_status("Cache and cookies cleared")

    def on_started(e):
        progress.value = 0
        set_status(f"Started: {e.url}")

    def on_finished(e):
        progress.value = 1
        set_status(f"Finished: {e.url}")

    def on_progress(e):
        progress.value = e.progress / 100
        page.update()

    def on_error(e):
        set_status(f"Error {e.error_code}: {e.description}")

    def on_message(e):
        set_status(f"JavaScript [{e.channel_name}]: {e.message_body}")

    webview.url = address.value
    webview.javascript_channels = ["FletBridge"]
    webview.on_page_started = on_started
    webview.on_page_finished = on_finished
    webview.on_progress = on_progress
    webview.on_web_resource_error = on_error
    webview.on_javascript_message = on_message

    page.add(
        ft.Column(
            [
                ft.Row([
                    address,
                    ft.Button("Load", on_click=load_url),
                    ft.Button("HTML", on_click=load_html),
                ]),
                ft.Row([
                    ft.IconButton(ft.Icons.ARROW_BACK, on_click=back),
                    ft.IconButton(ft.Icons.ARROW_FORWARD, on_click=forward),
                    ft.IconButton(ft.Icons.REFRESH, on_click=reload),
                    ft.Button("Read title", on_click=read_title),
                    ft.Button("Clear data", on_click=clear_browser_data),
                ]),
                ft.Row([progress, status]),
                webview,
            ],
            expand=True,
        )
    )


ft.run(main)
```
