# FletWebviewAll

A unified webview control for the Flet framework that provides cross-platform web content display.

## Overview

FletWebviewAll is a Flet extension that integrates the `webview_all` Flutter package, enabling you to display web content directly within your Flet applications. This control works seamlessly across Android, iOS, macOS, Windows, and Web platforms.

## Features

- **Cross-Platform Support**: Works on Android, iOS, macOS, Windows, and Web
- **URL Loading**: Load any HTTP, HTTPS, file://, or data: URLs
- **HTML Content**: Display HTML content directly without needing an external URL
- **JavaScript Support**: Enable or disable JavaScript execution
- **Navigation Control**: Allow or restrict navigation to new URLs
- **Zoom Support**: Built-in zoom controls for user convenience
- **Custom User Agent**: Set custom user agent strings
- **Debug Support**: Enable debugging for development and troubleshooting

## Installation

### Using as a Flet Extension

Add the dependency to your `pyproject.toml`:

```toml
dependencies = [
    "flet-webview-all @ git+https://github.com/yourusername/flet-webview-all",
    "flet>=0.85.2",
]
```

Or if published on PyPI:

```toml
dependencies = [
    "flet-webview-all",
    "flet>=0.85.2",
]
```

## Basic Usage

```python
import flet as ft
from flet_webview_all import FletWebviewAll

def main(page: ft.Page):
    page.add(
        FletWebviewAll(
            url="https://www.example.com",
            expand=True,
        )
    )

ft.run(main)
```

## Properties

### url
- **Type**: `Optional[str]`
- **Default**: `None`
- **Description**: The URL to load in the webview. Can be HTTP, HTTPS, file://, or data: URLs.

### html
- **Type**: `Optional[str]`
- **Default**: `None`
- **Description**: HTML content to display directly in the webview (alternative to url).

### allow_navigation
- **Type**: `bool`
- **Default**: `True`
- **Description**: Whether to allow navigation to new URLs by clicking links.

### zoom_enabled
- **Type**: `bool`
- **Default**: `True`
- **Description**: Whether zoom controls are available to users.

### javascript_enabled
- **Type**: `bool`
- **Default**: `True`
- **Description**: Whether JavaScript execution is enabled.

### user_agent
- **Type**: `Optional[str]`
- **Default**: `None`
- **Description**: Custom User-Agent string to use for requests.

### debugging_enabled
- **Type**: `bool`
- **Default**: `False`
- **Description**: Enable debugging for development purposes.

## Layout Properties

As FletWebviewAll extends `LayoutControl`, it inherits all standard layout properties including:
- `expand`
- `width` / `height`
- `margin` / `padding`
- `alignment`
- `opacity`
- `rotation`
- `scale`
- `offset`
- And many more...

See the [Flet LayoutControl documentation](https://flet.dev/docs/reference/controls/layoutcontrol) for complete list of inherited properties.

## Examples

### Load a Website

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
    html_content = """
    <!DOCTYPE html>
    <html>
    <head>
        <title>My Page</title>
        <style>
            body { font-family: Arial; margin: 20px; }
            h1 { color: #333; }
        </style>
    </head>
    <body>
        <h1>Hello from FletWebviewAll!</h1>
        <p>This HTML content is rendered directly in the webview.</p>
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

### Control Settings

```python
import flet as ft
from flet_webview_all import FletWebviewAll

def main(page: ft.Page):
    webview = FletWebviewAll(
        url="https://www.example.com",
        javascript_enabled=True,
        zoom_enabled=True,
        allow_navigation=True,
        expand=True,
    )
    
    def toggle_js(e):
        webview.javascript_enabled = not webview.javascript_enabled
        page.update()
    
    page.add(
        ft.Column([
            ft.ElevatedButton("Toggle JavaScript", on_click=toggle_js),
            webview,
        ], expand=True)
    )

ft.run(main)
```

## Classes

[FletWebviewAll](FletWebviewAll.md)
