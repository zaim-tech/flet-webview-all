# Examples

This page collects focused examples. For the complete application, see the
[control overview](../controls/fletwebviewall/index.md#complete-application-example).

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

## Dynamic URL loading from a text field

Validates and normalizes user input before assigning it to `url`, so
scheme-less input like `example.com` still resolves.

```python
import flet as ft
from flet_webview_all import FletWebviewAll


def main(page: ft.Page):
    webview = FletWebviewAll(expand=True)
    url_input = ft.TextField(label="Enter URL", width=300)

    def load_url(e):
        url = url_input.value
        if url:
            if not url.startswith(("http://", "https://", "file://", "data:")):
                url = "https://" + url
            webview.url = url
            page.update()

    page.add(
        ft.Column([
            ft.Row([url_input, ft.IconButton(ft.Icons.CHECK, on_click=load_url)]),
            webview,
        ], expand=True)
    )


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

## Toggle settings at runtime

Any of `javascript_enabled`, `zoom_enabled`, `allow_navigation`, and
`user_agent` can be flipped after the control is on the page — call
`page.update()` afterward.

```python
import flet as ft
from flet_webview_all import FletWebviewAll


def main(page: ft.Page):
    webview = FletWebviewAll(
        url="https://www.example.com",
        expand=True,
    )

    def toggle_javascript(e):
        webview.javascript_enabled = not webview.javascript_enabled
        page.update()

    def toggle_zoom(e):
        webview.zoom_enabled = not webview.zoom_enabled
        page.update()

    def toggle_navigation(e):
        webview.allow_navigation = not webview.allow_navigation
        page.update()

    page.add(
        ft.Column([
            ft.Row([
                ft.ElevatedButton("Toggle JS", on_click=toggle_javascript),
                ft.ElevatedButton("Toggle Zoom", on_click=toggle_zoom),
                ft.ElevatedButton("Toggle Navigation", on_click=toggle_navigation),
            ]),
            webview,
        ], expand=True)
    )


ft.run(main)
```

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

## Display a loading indicator

```python
progress = ft.ProgressBar(value=0)

def started(e):
    progress.value = 0
    page.update()

def changed(e):
    progress.value = e.progress / 100
    page.update()

def finished(e):
    progress.value = 1
    page.update()

webview = FletWebviewAll(
    url="https://example.com",
    on_page_started=started,
    on_progress=changed,
    on_page_finished=finished,
)
```

## Handle failed resources

```python
def report_error(e):
    if e.is_for_main_frame:
        print(f"The page failed: {e.description} ({e.error_code})")
    else:
        print(f"A subresource failed: {e.domain}")

webview = FletWebviewAll(
    url="https://example.com",
    on_web_resource_error=report_error,
)
```

## Testing with Playwright on Windows

See the dedicated
[Playwright page](../controls/fletwebviewall/playwright.md) for CDP setup,
endpoint verification, attachment, screenshots, and multiple WebViews.
