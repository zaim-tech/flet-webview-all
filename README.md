# flet-webview-all

`flet-webview-all` is a Flet extension that embeds web content in a Flet application. It wraps [`webview_all`](https://pub.dev/packages/webview_all), a Flutter WebView implementation with support for Android, iOS, Linux, macOS, Windows, and the web.

The control is a `ft.LayoutControl`, so it can use Flet layout properties such as `expand`, `width`, `height`, and `visible`.

## Installation

Install the published package from PyPI:

```bash
pip install flet-webview-all
```

Or add it to your application's `pyproject.toml`:

```toml
[project]
dependencies = [
    "flet>=0.86.5",
    "flet-webview-all",
]
```

To install the latest unreleased version directly from GitHub instead, use:

```toml
[project]
dependencies = [
    "flet>=0.86.5",
    "flet-webview-all @ git+https://github.com/zaim-tech/flet-webview-all.git",
]
```

For a local checkout during development, add the package as a path dependency instead. See the included [example application](examples/flet_webview_all_example/) for a working configuration.

## Usage

```python
import flet as ft

from flet_webview_all import FletWebviewAll


def main(page: ft.Page):
    page.title = "WebView example"
    page.add(
        FletWebviewAll(
            url="https://flet.dev",
            expand=True,
        )
    )


ft.run(main)
```

### Render HTML directly

Pass a complete HTML document using `html`. The control loads `url` when it is set; otherwise, it uses `html`.

```python
page.add(
    FletWebviewAll(
        html="""
        <!doctype html>
        <html>
          <body><h1>Hello from Flet</h1></body>
        </html>
        """,
        expand=True,
    )
)
```

## Control properties

| Property | Type | Default | Description |
| --- | --- | --- | --- |
| `url` | `str \| None` | `None` | URL to load. When set, it takes precedence over `html`. |
| `html` | `str \| None` | `None` | Complete HTML document to render when `url` is not set. |
| `allow_navigation` | `bool` | `True` | Allows navigation requests from the WebView. |
| `zoom_enabled` | `bool` | `True` | Enables WebView zoom where the platform supports it. |
| `javascript_enabled` | `bool` | `True` | Enables unrestricted JavaScript execution. |
| `user_agent` | `str \| None` | `None` | Overrides the WebView user-agent when provided. |
| `debugging_enabled` | `bool` | `False` | Prints JavaScript console messages through Flutter's debug logger. |

Use `page.update()` after changing a control property at runtime:

```python
webview.javascript_enabled = False
page.update()
```

## Platform support

Support is supplied by the underlying [`webview_all`](https://pub.dev/packages/webview_all) package:

| Platform | Minimum requirement / implementation |
| --- | --- |
| Android | API 24+ |
| iOS | 13.0+ (`WKWebView`) |
| Linux | `webkit2gtk-4.1` |
| macOS | 10.15+ (`WKWebView`) |
| Windows | Windows 10 version 1809+ (`WebView2`) |
| Web | Modern browser |

Platform WebView engines can differ in their capabilities. Test the settings your application relies on on each target platform.

## Build the example

Flet extensions include Python and Flutter code. After changing the Flutter package, rebuild the example application; Python-only changes can be run without rebuilding once the extension has been built for the target platform.

```bash
cd examples/flet_webview_all_example
flet build windows -v
```

Replace `windows` with another supported Flet build target, such as `macos`, `apk`, `ipa`, or `web`. To run the example during Python development:

```bash
flet run
```

## Development

The project follows Flet's extension structure:

```text
src/flet_webview_all/                  Python control
src/flutter/flet_webview_all/          Flutter extension and webview_all dependency
examples/flet_webview_all_example/     Sample Flet application
docs/                                  Additional documentation
```

To add or update the Flutter dependency, work from the Flutter package directory:

```bash
cd src/flutter/flet_webview_all
flutter pub get
```

## References

- [flet-webview-all repository](https://github.com/zaim-tech/flet-webview-all)
- [webview_all package](https://pub.dev/packages/webview_all)
- [Creating a Flet extension](https://flet.dev/docs/extend/user-extensions/)

## License

See [LICENSE](LICENSE).
