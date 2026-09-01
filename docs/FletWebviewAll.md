# FletWebviewAll Control Reference

## Description

`FletWebviewAll` is a Flet extension control that provides a unified webview for displaying web content across all platforms. It wraps the `webview_all` Flutter package, offering seamless integration of web content within Flet applications.

This control extends `ft.LayoutControl`, inheriting all its layout and styling properties while adding webview-specific functionality.

## Inheritance

`FletWebviewAll` → `ft.LayoutControl` → `ft.Control`

## Properties

### url

```
url: Optional[str] = None
```

The URL to load in the webview. Supports HTTP, HTTPS, file://, and data: URL schemes.

**Example:**
```python
webview = FletWebviewAll(url="https://www.google.com")
```

### html

```
html: Optional[str] = None
```

HTML content to display directly in the webview. Used as an alternative to the `url` property.

**Example:**
```python
html_content = "<h1>Hello World</h1><p>This is HTML content</p>"
webview = FletWebviewAll(html=html_content)
```

### allow_navigation

```
allow_navigation: bool = True
```

Whether to allow navigation to new URLs by clicking links within the webview.

**Example:**
```python
webview = FletWebviewAll(
    url="https://www.example.com",
    allow_navigation=False  # Prevent clicking on links
)
```

### zoom_enabled

```
zoom_enabled: bool = True
```

Whether zoom controls are enabled for the user to zoom in and out of content.

**Example:**
```python
webview = FletWebviewAll(
    url="https://www.example.com",
    zoom_enabled=True
)
```

### javascript_enabled

```
javascript_enabled: bool = True
```

Whether JavaScript execution is enabled in the webview.

**Example:**
```python
webview = FletWebviewAll(
    url="https://www.example.com",
    javascript_enabled=True  # Allow JavaScript
)
```

### javascript_mode and javascript_channels

```
javascript_mode: Optional[str | bool] = None
javascript_channels: Optional[list[str]] = None
```

`javascript_mode` overrides `javascript_enabled` when set. Use
`"unrestricted"`/`True` to enable JavaScript or `"disabled"`/`False` to
disable it. `javascript_channels` registers names exposed to page JavaScript;
after a page load it can call `ChannelName.postMessage("message")`.

```python
webview = FletWebviewAll(
    url="https://example.com",
    javascript_channels=["FletBridge"],
    on_javascript_message=lambda e: print(e.channel_name, e.message_body),
)
```

New channels take effect on the next page load, as required by the underlying
WebView implementation.

### user_agent

```
user_agent: Optional[str] = None
```

Custom User-Agent string to use for HTTP requests made by the webview.

**Example:**
```python
webview = FletWebviewAll(
    url="https://www.example.com",
    user_agent="MyApp/1.0"
)
```

### debugging_enabled

```
debugging_enabled: bool = False
```

Enable debugging features for development purposes.

**Example:**
```python
webview = FletWebviewAll(
    url="https://www.example.com",
    debugging_enabled=True
)
```

### background_color

```
background_color: Optional[ft.ColorValue] = None
```

Sets the native WebView canvas color before content is displayed, which is
useful for avoiding a white flash in dark applications.

```python
webview = FletWebviewAll(background_color=ft.Colors.BLUE_GREY_900)
```

### allow_webview_permissions

```
allow_webview_permissions: bool = False
```

Controls the WebView layer of camera/microphone permission requests. Request
the operating-system permission first with
[`flet-permission-handler`](permissions.md), then enable this flag only for a
trusted page. Requests are denied by default.

## Events

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

`on_navigation_request` is a notification. Since Flet control events are
asynchronous, its Python handler cannot return an immediate navigation decision.
Use `allow_navigation=False` to block navigations (except the initial URL) or
set that property before navigation begins.

## Controller methods

The following coroutines are available once the control is on a page:

```python
await webview.reload()
await webview.stop_loading()  # browser-standard window.stop(), best effort
await webview.go_back()
await webview.go_forward()
can_go_back = await webview.can_go_back()
can_go_forward = await webview.can_go_forward()
await webview.clear_cache()
cookies_were_cleared = await webview.clear_cookies()
url = await webview.get_current_url()
await webview.run_javascript("document.body.dataset.ready = 'true'")
value = await webview.run_javascript_returning_result("document.title")
await webview.scroll_to(0, 0)
await webview.scroll_by(0, 300)
position = await webview.get_scroll_position()
if await webview.supports_set_scrollbars_enabled():
await webview.set_vertical_scrollbar_enabled(False)
await webview.open_devtools()  # Windows/WebView2 only
version = await webview.get_webview_version()  # Windows/WebView2 only
```

`clear_cookies()` clears the cookie store shared by application WebViews.
`stop_loading()` is best effort because `webview_all` does not expose a native
stop-loading API.

### remote_debugging_port

```
remote_debugging_port: Optional[int] = None
```

Windows-only, startup-time WebView2 CDP port for attaching tools such as
Playwright to the visible WebView. The value must be between 1 and 65535 and
must be set on the first WebView. WebView2 shares one environment per process,
so later controls that explicitly set a port must use the same value.

```python
webview = FletWebviewAll(
    url="https://www.example.com",
    remote_debugging_port=9222,
)
```

Remote debugging is for development and test automation only. Leave the value
as `None` in production.

## Inherited Properties

As `FletWebviewAll` extends `LayoutControl`, it inherits the following categories of properties:

### Layout Properties
- `expand` - Fill available space
- `width`, `height` - Explicit dimensions
- `padding`, `margin` - Spacing
- `alignment` - Content alignment
- `aspect_ratio` - Maintain aspect ratio

### Visual Properties
- `opacity` - Transparency (0-1)
- `bgcolor` - Background color
- `border` - Border styling
- `shadow` - Drop shadow

### Transform Properties
- `rotation` - Rotate the control
- `scale` - Scale the control
- `offset` - Offset the control position

### Interaction Properties
- `disabled` - Disable the control
- `on_hover` - Handle hover events
- `on_focus` - Handle focus events
- `on_blur` - Handle blur events

For complete list and details, see [LayoutControl documentation](https://flet.dev/docs/controls/layoutcontrol/).

## Examples

### Simple URL Loading

```python
import flet as ft
from flet_webview_all import FletWebviewAll

def main(page: ft.Page):
    page.add(
        FletWebviewAll(
            url="https://www.google.com",
            expand=True,
        )
    )

ft.run(main)
```

### Display HTML Content

```python
import flet as ft
from flet_webview_all import FletWebviewAll

def main(page: ft.Page):
    html = """
    <!DOCTYPE html>
    <html>
    <head>
        <title>Custom Page</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                margin: 20px;
                background-color: #f5f5f5;
            }
            h1 { color: #333; }
            p { line-height: 1.6; }
        </style>
    </head>
    <body>
        <h1>Welcome to FletWebviewAll</h1>
        <p>This is custom HTML content rendered in the webview.</p>
        <button onclick="alert('Button clicked!')">Click Me</button>
    </body>
    </html>
    """
    
    page.add(
        FletWebviewAll(
            html=html,
            expand=True,
            javascript_enabled=True,
        )
    )

ft.run(main)
```

### Dynamic URL Loading

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
            ft.Row([url_input, ft.IconButton(ft.icons.CHECK, on_click=load_url)]),
            webview,
        ], expand=True)
    )

ft.run(main)
```

### Controlled Settings

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

## Platform-Specific Notes

### Android
- Requires API level 19 or higher
- JavaScript is enabled by default
- User-Agent can be customized per URL

### iOS
- Requires iOS 11.0 or higher
- JavaScript is enabled by default
- Custom User-Agent requires iOS 13.0+

### macOS
- Requires macOS 10.11 or higher
- Full JavaScript support
- Custom User-Agent supported

### Windows
- Requires Windows 10 or higher
- WebView2 must be installed on the system
- Full JavaScript support
- Supports Playwright attachment through `remote_debugging_port`

### Web
- Uses iframe for embedding
- Some restrictions may apply based on CORS policies
- Custom User-Agent may not be fully supported

## Best Practices

1. **Always provide a fallback**: Use `html` property if `url` fails to load
2. **Handle JavaScript carefully**: Disable if not needed for security
3. **Test cross-platform**: Test on multiple platforms as behavior may vary
4. **Use expand=True**: For full-screen webview experience
5. **Implement error handling**: Monitor console for JavaScript errors during debugging

## Troubleshooting

### Webview not loading
- Check that the URL is valid and accessible
- For local files, use `file://` scheme
- Verify network connectivity

### JavaScript not working
- Ensure `javascript_enabled=True`
- Check browser console for errors (enable debugging)
- Verify the JavaScript code is correct

### Performance issues
- Consider disabling zoom if not needed
- Disable JavaScript if not required
- Use smaller HTML content when possible

## See Also

- [Flet Documentation](https://flet.dev)
- [webview_all Package](https://pub.dev/packages/webview_all)
- [Flutter WebView](https://pub.dev/packages/webview_flutter)

## Complete application example

The following application demonstrates URL and HTML loading, every lifecycle
callback, the JavaScript bridge, history controls, runtime settings, and the
JavaScript controller methods. Save it as `main.py`, install
`flet-webview-all`, and run it with `flet run main.py`.

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

## Property-by-property examples

### `url` and `html`

Set `url` for a remote/local document. Set `html` for an inline document. If
both are set, `url` wins. To switch modes at runtime, set the unused property to
`None` and call `page.update()`.

```python
webview = FletWebviewAll(url="https://flet.dev", expand=True)
webview.url, webview.html = None, "<html><body><h1>Offline</h1></body></html>"
page.update()
```

### Navigation and zoom

```python
webview = FletWebviewAll(
    url="https://example.com",
    allow_navigation=False,  # only the initial URL is allowed
    zoom_enabled=True,
)
```

### JavaScript settings

```python
FletWebviewAll(javascript_enabled=False)
FletWebviewAll(javascript_mode="disabled")
FletWebviewAll(javascript_mode="unrestricted")
```

`javascript_mode` takes precedence when supplied. Use the explicit mode when
you want configuration to be self-documenting.

### User agent and background

```python
FletWebviewAll(
    user_agent="MyCompanyHelpDesk/2.0",
    background_color=ft.Colors.BLACK,
)
```

### Windows remote debugging

Set the port before the first WebView is created. WebView2 shares one browser
environment per process.

```powershell
$env:FLET_WEBVIEW_ALL_REMOTE_DEBUGGING_PORT = "9222"
flet run main.py
```

```python
import os
FletWebviewAll(
    url="https://example.com",
    remote_debugging_port=int(os.environ["FLET_WEBVIEW_ALL_REMOTE_DEBUGGING_PORT"]),
)
```

Use Playwright with `chromium.connect_over_cdp("http://127.0.0.1:9222")`.
Never enable this option in production.

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

The navigation callback is observational. Use `allow_navigation` to enforce a
policy; changing it from the callback is asynchronous and cannot affect the
already pending native decision.

## Controller method examples

```python
async def browser_actions(_):
    if await webview.can_go_back():
        await webview.go_back()
    if await webview.can_go_forward():
        await webview.go_forward()
    await webview.reload()
    await webview.stop_loading()  # best effort: window.stop()
    await webview.run_javascript("document.body.style.zoom = '110%'")
    result = await webview.run_javascript_returning_result("document.title")
    current = await webview.get_current_url()
    await webview.clear_cache()
    cookies_removed = await webview.clear_cookies()
    print(result, current, cookies_removed)
```

All methods are asynchronous and require the control to have been added to a
page. `clear_cookies()` affects the application-wide WebView cookie store.

## Playwright on Windows (WebView2 CDP)

!!! important "Configure the first WebView"
    Set `remote_debugging_port` on the first `FletWebviewAll` created in the
    process. WebView2 uses one shared browser environment, so later WebViews
    inherit the same CDP endpoint. If another WebView is created first, restart
    the application before enabling the port.

Remote debugging is intended for development and test automation. The CDP
endpoint has no application-level authentication and can inspect every WebView
in the shared environment. Always leave `remote_debugging_port=None` in
production.

### Start the Flet app

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
changing it after the WebView2 environment has initialized requires restarting
the app. If you prefer environment-based configuration:

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

### Verify the endpoint

Before attaching Playwright, open
[`http://127.0.0.1:9222/json/list`](http://127.0.0.1:9222/json/list) in a
browser or request it with PowerShell:

```powershell
Invoke-RestMethod http://127.0.0.1:9222/json/list |
    Select-Object id, title, url, webSocketDebuggerUrl
```

The response should contain a page target for the visible WebView2 document.

### Attach with Playwright

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

### Test a JavaScript bridge with Playwright

When the Flet control registers `javascript_channels=["FletBridge"]`, the
page can call `FletBridge.postMessage(...)`. Playwright can exercise the page
while Flet receives the resulting `on_javascript_message` event:

```python
await page.evaluate("FletBridge.postMessage('message from Playwright')")
```

### Multiple WebViews

Every WebView in the process shares the first environment and CDP endpoint. A
second control may omit the port or repeat exactly the same value:

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

### Runtime property updates

Use `page.update()` after changing a control property. Settings such as
JavaScript, zoom, navigation, and user agent can be changed at runtime; the
remote debugging port cannot.

```python
webview.javascript_enabled = False
webview.zoom_enabled = False
webview.allow_navigation = False
webview.user_agent = "MyApp/1.0"
page.update()
```

!!! note "If a setting appears unchanged"
    `zoom_enabled` and JavaScript mode are native WebView settings. After
    changing Dart code or the Flutter dependency, stop the app and rebuild the
    extension (`flet build windows -v`, or the target platform you are testing).
    A plain `flet run` can use an already-built extension bundle. For a Python
    property change, `page.update()` is sufficient.

    `zoom_enabled=False` disables the WebView's native zoom controls. It does
    not prevent a page from applying CSS zoom or JavaScript that changes its
    own scale. `javascript_mode="disabled"` prevents WebView JavaScript
    execution; it does not disable JavaScript in the browser hosting the Flet
    app itself. Reload the page after changing modes if the document was
    already running scripts.

## More practical recipes

### Display a loading indicator

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

### Run JavaScript after loading

```python
async def highlight_page(e):
    await webview.run_javascript(
        "document.body.style.fontFamily = 'system-ui';"
    )

webview.on_page_finished = highlight_page
```

### Handle failed resources

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

## Project links

- Source repository: [github.com/zaim-tech/flet-webview-all](https://github.com/zaim-tech/flet-webview-all)
- Issues and feature requests: [GitHub Issues](https://github.com/zaim-tech/flet-webview-all/issues)
- Published package: [PyPI: flet-webview-all](https://pypi.org/project/flet-webview-all/)
- Underlying Flutter package: [webview_all on pub.dev](https://pub.dev/packages/webview_all)
