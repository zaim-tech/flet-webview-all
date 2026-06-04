# flet-webview-all

A Flet extension that provides a unified webview control for displaying web content across all platforms using the `webview_all` Flutter package.

## Features

- **Cross-Platform Support**: Works seamlessly on Android, iOS, macOS, Windows, and Web
- **URL Loading**: Load any HTTP, HTTPS, file://, or data: URLs
- **HTML Content**: Display HTML content directly without external URLs
- **JavaScript Support**: Enable or disable JavaScript execution
- **Navigation Control**: Allow or restrict user navigation
- **Zoom Support**: Built-in zoom controls
- **Custom User Agent**: Set custom user agent strings for requests
- **Debug Support**: Enable debugging for development

## Installation

### Option 1: Git Dependency

Add the dependency to your `pyproject.toml`:

```toml
dependencies = [
  "flet-webview-all @ git+https://github.com/yourusername/flet-webview-all",
  "flet>=0.85.2",
]
```

### Option 2: PyPI Dependency (when published)

```toml
dependencies = [
  "flet-webview-all",
  "flet>=0.85.2",
]
```

## Quick Start

### Build the Extension

1. Navigate to the example folder:
```bash
cd examples/flet_webview_all_example
```

2. Build for your platform:
```bash
# macOS
flet build macos -v

# Windows
flet build windows -v

# Android
flet build apk -v

# iOS
flet build ipa -v

# Web
flet build web -v
```

3. Run the built app:
```bash
# macOS
open build/macos/flet-webview-all-example.app

# Windows
flet run
```

### Basic Usage

```python
import flet as ft
from flet_webview_all import FletWebviewAll

def main(page: ft.Page):
    page.title = "WebView Example"
    
    page.add(
        FletWebviewAll(
            url="https://www.google.com",
            expand=True,
        )
    )

ft.run(main)
```

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `url` | `Optional[str]` | `None` | URL to load in the webview |
| `html` | `Optional[str]` | `None` | HTML content to display directly |
| `allow_navigation` | `bool` | `True` | Allow navigation to new URLs |
| `zoom_enabled` | `bool` | `True` | Enable zoom controls |
| `javascript_enabled` | `bool` | `True` | Enable JavaScript execution |
| `user_agent` | `Optional[str]` | `None` | Custom User-Agent string |
| `debugging_enabled` | `bool` | `False` | Enable debugging features |

## Examples

### Display a Website

```python
import flet as ft
from flet_webview_all import FletWebviewAll

def main(page: ft.Page):
    page.add(
        FletWebviewAll(
            url="https://flutter.dev",
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
    html_content = """
    <!DOCTYPE html>
    <html>
    <head>
        <title>Hello</title>
        <style>
            body { font-family: Arial; margin: 20px; }
            h1 { color: #007AFF; }
        </style>
    </head>
    <body>
        <h1>Hello from FletWebviewAll!</h1>
        <p>This HTML is rendered directly in the webview.</p>
    </body>
    </html>
    """
    
    page.add(
        FletWebviewAll(
            html=html_content,
            expand=True,
        )
    )

ft.run(main)
```

### Interactive Webview

```python
import flet as ft
from flet_webview_all import FletWebviewAll

def main(page: ft.Page):
    webview = FletWebviewAll(
        url="https://www.example.com",
        expand=True,
    )
    
    def toggle_js(e):
        webview.javascript_enabled = not webview.javascript_enabled
        page.update()
    
    def toggle_zoom(e):
        webview.zoom_enabled = not webview.zoom_enabled
        page.update()
    
    page.add(
        ft.Column([
            ft.Row([
                ft.ElevatedButton("Toggle JS", on_click=toggle_js),
                ft.ElevatedButton("Toggle Zoom", on_click=toggle_zoom),
            ]),
            webview,
        ], expand=True)
    )

ft.run(main)
```

## Project Structure

```
flet-webview-all/
├── src/
│   ├── flet_webview_all/          # Python package
│   │   ├── __init__.py
│   │   └── flet_webview_all.py    # Control definition
│   └── flutter/
│       └── flet_webview_all/      # Flutter package
│           ├── pubspec.yaml
│           ├── lib/
│           │   ├── flet_webview_all.dart
│           │   └── src/
│           │       ├── extension.dart
│           │       └── flet_webview_all.dart
├── examples/
│   └── flet_webview_all_example/  # Example app
│       ├── src/
│       │   └── main.py
│       └── pyproject.toml
├── docs/                           # Documentation
│   ├── index.md
│   └── FletWebviewAll.md
└── README.md
```

## Development

### Setup Development Environment

1. Create a virtual environment:
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

2. Install dependencies:
```bash
pip install flet>=0.85.2
```

3. Build and test the extension:
```bash
cd examples/flet_webview_all_example
flet build macos -v
```

### Making Changes

**Python Changes:**
- Edit files in `src/flet_webview_all/`
- Changes take effect immediately without rebuild

**Flutter/Dart Changes:**
- Edit files in `src/flutter/flet_webview_all/`
- Rebuild required: `flet build macos -v`

### Add Flutter Dependencies

To add new Flutter packages:

```bash
cd src/flutter/flet_webview_all
flutter pub add package_name
```

Then update the Dart implementation to use the new package.

## Platform Support

| Platform | Status | Requirements |
|----------|--------|--------------|
| Android | ✅ Supported | API 19+ |
| iOS | ✅ Supported | iOS 11.0+ |
| macOS | ✅ Supported | macOS 10.11+ |
| Windows | ✅ Supported | Windows 10+, WebView2 |
| Web | ✅ Supported | Modern browsers |

## Documentation

Full documentation is available in the [docs](docs/) folder and includes:
- [Index](docs/index.md) - Getting started guide
- [FletWebviewAll Reference](docs/FletWebviewAll.md) - API reference with examples

## Troubleshooting

### Webview not displaying

- Ensure the URL is valid and accessible
- For local files, use `file://` URL scheme
- Check network connectivity
- Try enabling debugging: `debugging_enabled=True`

### JavaScript not working

- Verify `javascript_enabled=True`
- Check the browser console for errors
- Enable debugging to see error messages

### Build issues

- Clear Flutter cache: `flutter clean`
- Clear Flet cache: `flet clean`
- Update dependencies: `flutter pub get`
- Rebuild with verbose output: `flet build macos -vv`

## Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.

## License

See [LICENSE](LICENSE) file for details.

## References

- [Flet Documentation](https://flet.dev)
- [webview_all Package](https://pub.dev/packages/webview_all)
- [Flutter Documentation](https://flutter.dev)

## Support

For issues and questions:
- Check the [documentation](docs/)
- Review the [example app](examples/flet_webview_all_example/)
- Open an issue on GitHub
