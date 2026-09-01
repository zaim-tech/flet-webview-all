# Playwright on Windows (WebView2 CDP)

!!! important "Configure the first WebView"
    Set `remote_debugging_port` on the first `FletWebviewAll` created in the
    process. WebView2 uses one shared browser environment, so later
    WebViews inherit the same CDP endpoint. If another WebView is created
    first, restart the application before enabling the port.

Remote debugging is intended for development and test automation. The CDP
endpoint has no application-level authentication and can inspect every
WebView in the shared environment. Always leave
`remote_debugging_port=None` in production.

## Start the Flet app

```python
import flet as ft
from flet_webview_all import FletWebviewAll


def main(page: ft.Page):
    webview = FletWebviewAll(
        url="https://example.com",
        remote_debugging_port=9222,
        expand=True,
    )
    page.add(webview)


ft.run(main)
```

The port must be between `1` and `65535`. It is a startup-time setting;
changing it after the WebView2 environment has initialized requires
restarting the app. If you prefer environment-based configuration:

```powershell
$env:FLET_WEBVIEW_ALL_REMOTE_DEBUGGING_PORT = "9222"
flet run src/main.py
```

```python
import os

port = os.getenv("FLET_WEBVIEW_ALL_REMOTE_DEBUGGING_PORT")
webview = FletWebviewAll(
    url="https://example.com",
    remote_debugging_port=int(port) if port else None,
)
```

## Verify the endpoint

Before attaching Playwright, open
[`http://127.0.0.1:9222/json/list`](http://127.0.0.1:9222/json/list) in a
browser or request it with PowerShell:

```powershell
Invoke-RestMethod http://127.0.0.1:9222/json/list |
    Select-Object id, title, url, webSocketDebuggerUrl
```

The response should contain a page target for the visible WebView2
document.

## Attach with Playwright

Install Playwright in a separate test environment with
`pip install playwright` (the WebView2 browser is already installed by the
Flet desktop runtime):

```python
import asyncio
from playwright.async_api import async_playwright


async def attach_and_test():
    async with async_playwright() as playwright:
        browser = await playwright.chromium.connect_over_cdp(
            "http://127.0.0.1:9222"
        )
        pages = [
            page
            for context in browser.contexts
            for page in context.pages
        ]
        if not pages:
            raise RuntimeError("No WebView2 page target was found")

        page = next(
            page for page in pages
            if page.url.startswith("https://example.com")
        )
        print("URL:", page.url)
        print("Title:", await page.title())
        await page.screenshot(path="webview-screenshot.png")


asyncio.run(attach_and_test())
```

## Test a JavaScript bridge with Playwright

When the Flet control registers `javascript_channels=["FletBridge"]`, the
page can call `FletBridge.postMessage(...)`. Playwright can exercise the
page while Flet receives the resulting `on_javascript_message` event (see
[Events](events.md)):

```python
await page.evaluate("FletBridge.postMessage('message from Playwright')")
```

## Multiple WebViews

Every WebView in the process shares the first environment and CDP
endpoint. A second control may omit the port or repeat exactly the same
value:

```python
page.add(
    ft.Row([
        FletWebviewAll(url="https://example.com", remote_debugging_port=9222),
        FletWebviewAll(url="https://flet.dev"),  # inherits port 9222
    ], expand=True)
)
```

Do not use a different port on the second control, and do not create any
WebView before the control that configures the port.

See [`remote_debugging_port`](properties.md#remote_debugging_port) for the
property itself, and [Debugging & DevTools](../../guides/debugging.md) for
the non-Windows, non-Playwright debugging options.
