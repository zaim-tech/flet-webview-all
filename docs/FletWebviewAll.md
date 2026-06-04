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

For complete list and details, see [LayoutControl documentation](https://flet.dev/docs/reference/controls/layoutcontrol).

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
