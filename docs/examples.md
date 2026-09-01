# Examples

This page collects focused examples. For the complete application, see the
[API guide](FletWebviewAll.md).

## URL navigation bar

```python
import flet as ft
from flet_webview_all import FletWebviewAll


def main(page: ft.Page):
    webview = FletWebviewAll(expand=True)
    address = ft.TextField(value="https://flet.dev", expand=True)

    def navigate(_):
        value = (address.value or "").strip()
        if value and not value.startswith(("http://", "https://")):
            value = "https://" + value
        if value:
            webview.url, webview.html = value, None
            page.update()

    page.add(ft.Column([ft.Row([address, ft.Button("Go", on_click=navigate)]), webview], expand=True))


ft.run(main)
```

## Offline HTML with a bridge

```python
HTML = """<html><body>
<button onclick=\"App.postMessage('clicked')\">Send to Flet</button>
</body></html>"""

def message(e):
    print(e.channel_name, e.message_body)

webview = FletWebviewAll(
    html=HTML,
    javascript_channels=["App"],
    on_javascript_message=message,
)
```

## Safe navigation policy

```python
webview = FletWebviewAll(
    url="https://mycompany.example",
    allow_navigation=False,
)
```

This permits the initial URL but blocks links and redirects. The
`on_navigation_request` callback can log requests, but its Python handler is
asynchronous and cannot synchronously return the native allow/block decision.

## Async browser toolbar

```python
async def back(_):
    if await webview.can_go_back():
        await webview.go_back()

async def forward(_):
    if await webview.can_go_forward():
        await webview.go_forward()

async def refresh(_):
    await webview.reload()

async def inspect(_):
    print("URL:", await webview.get_current_url())
    print("Title:", await webview.run_javascript_returning_result("document.title"))
```

## Dark mode and custom user agent

```python
webview = FletWebviewAll(
    url="https://example.com",
    background_color=ft.Colors.BLACK,
    user_agent="MyFletApp/1.0",
    javascript_mode="unrestricted",
    zoom_enabled=False,
)
```

## Testing with Playwright on Windows

See the dedicated [Playwright section](FletWebviewAll.md#playwright-on-windows-webview2-cdp)
for CDP setup, endpoint verification, attachment, screenshots, and multiple
WebViews.
