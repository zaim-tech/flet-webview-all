# Properties

## `url`

```
url: Optional[str] = None
```

The URL to load in the webview. Supports HTTP, HTTPS, `file://`, and `data:`
URL schemes.

```python
webview = FletWebviewAll(url="https://www.google.com")
```

## `html`

```
html: Optional[str] = None
```

HTML content to display directly in the webview. Used as an alternative to
the `url` property.

```python
html_content = "<h1>Hello World</h1><p>This is HTML content</p>"
webview = FletWebviewAll(html=html_content)
```

## `allow_navigation`

```
allow_navigation: bool = True
```

Whether to allow navigation to new URLs by clicking links within the
webview.

```python
webview = FletWebviewAll(
    url="https://www.example.com",
    allow_navigation=False,  # Prevent clicking on links
)
```

## `zoom_enabled`

```
zoom_enabled: bool = True
```

Whether zoom controls are enabled for the user to zoom in and out of
content.

```python
webview = FletWebviewAll(
    url="https://www.example.com",
    zoom_enabled=True,
)
```

## `javascript_enabled`

```
javascript_enabled: bool = True
```

Whether JavaScript execution is enabled in the webview.

```python
webview = FletWebviewAll(
    url="https://www.example.com",
    javascript_enabled=True,  # Allow JavaScript
)
```

## `javascript_mode` and `javascript_channels`

```
javascript_mode: Optional[str | bool] = None
javascript_channels: Optional[list[str]] = None
```

`javascript_mode` overrides `javascript_enabled` when set. Use
`"unrestricted"`/`True` to enable JavaScript or `"disabled"`/`False` to
disable it. `javascript_channels` registers names exposed to page
JavaScript; after a page load it can call
`ChannelName.postMessage("message")`.

```python
webview = FletWebviewAll(
    url="https://example.com",
    javascript_channels=["FletBridge"],
    on_javascript_message=lambda e: print(e.channel_name, e.message_body),
)
```

New channels take effect on the next page load, as required by the
underlying WebView implementation. See [Events](events.md) for the
`on_javascript_message` payload.

## `user_agent`

```
user_agent: Optional[str] = None
```

Custom User-Agent string to use for HTTP requests made by the webview.

```python
webview = FletWebviewAll(
    url="https://www.example.com",
    user_agent="MyApp/1.0",
)
```

## `debugging_enabled`

```
debugging_enabled: bool = False
```

Enable debugging features for development purposes. See
[Console capture](../../guides/console.md) for what this forwards and how
it differs from `on_console_message`.

```python
webview = FletWebviewAll(
    url="https://www.example.com",
    debugging_enabled=True,
)
```

## `background_color`

```
background_color: Optional[ft.ColorValue] = None
```

Sets the native WebView canvas color before content is displayed, which is
useful for avoiding a white flash in dark applications.

```python
webview = FletWebviewAll(background_color=ft.Colors.BLUE_GREY_900)
```

## `allow_webview_permissions`

```
allow_webview_permissions: bool = False
```

Controls the WebView layer of camera/microphone permission requests.
Request the operating-system permission first with
[`flet-permission-handler`](../../guides/permissions.md), then enable this
flag only for a trusted page. Requests are denied by default. See
[Permissions](../../guides/permissions.md) for the full flow.

## `remote_debugging_port`

```
remote_debugging_port: Optional[int] = None
```

Windows-only, startup-time WebView2 CDP port for attaching tools such as
Playwright to the visible WebView. The value must be between `1` and
`65535` and must be set on the first WebView. WebView2 shares one
environment per process, so later controls that explicitly set a port must
use the same value.

```python
webview = FletWebviewAll(
    url="https://www.example.com",
    remote_debugging_port=9222,
)
```

Remote debugging is for development and test automation only. Leave the
value as `None` in production. See [Playwright (Windows CDP)](playwright.md)
for the full setup.

## Inherited properties

As `FletWebviewAll` extends `LayoutControl`, it inherits the following
categories of properties:

**Layout** — `expand`, `width`, `height`, `padding`, `margin`, `alignment`,
`aspect_ratio`

**Visual** — `opacity`, `bgcolor`, `border`, `shadow`

**Transform** — `rotation`, `scale`, `offset`

**Interaction** — `disabled`, `on_hover`, `on_focus`, `on_blur`

For the complete list and details, see the
[Flet LayoutControl documentation](https://flet.dev/docs/controls/layoutcontrol/).

## Property-by-property examples

### `url` and `html`

Set `url` for a remote/local document. Set `html` for an inline document. If
both are set, `url` wins. To switch modes at runtime, set the unused
property to `None` and call `page.update()`.

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

`javascript_mode` takes precedence when supplied. Use the explicit mode
when you want configuration to be self-documenting.

### User agent and background

```python
FletWebviewAll(
    user_agent="MyCompanyHelpDesk/2.0",
    background_color=ft.Colors.BLACK,
)
```

### Windows remote debugging

Set the port before the first WebView is created. WebView2 shares one
browser environment per process.

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
Never enable this option in production. See
[Playwright (Windows CDP)](playwright.md) for the complete workflow.

### Runtime property updates

`page.update()` applies most property changes at runtime — JavaScript,
zoom, navigation, and user agent can all be changed while the app is
running. `remote_debugging_port` cannot; it is a startup-time setting.

```python
webview.javascript_enabled = False
webview.zoom_enabled = False
webview.allow_navigation = False
webview.user_agent = "MyApp/1.0"
page.update()
```

!!! note "If a setting appears unchanged"
    `zoom_enabled` and JavaScript mode are native WebView settings. After
    changing the native extension implementation or dependency, stop the app
    and rebuild the extension (`flet build windows -v`, or the target platform
    you are testing). A plain `flet run` can use an already-built extension
    bundle.
    For a Python property change, `page.update()` is sufficient.

    `zoom_enabled=False` disables the WebView's native zoom controls. It
    does not prevent a page from applying CSS zoom or JavaScript that
    changes its own scale. `javascript_mode="disabled"` prevents WebView
    JavaScript execution; it does not disable JavaScript in the browser
    hosting the Flet app itself. Reload the page after changing modes if
    the document was already running scripts.
