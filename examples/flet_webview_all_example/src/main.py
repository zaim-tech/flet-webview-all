import flet as ft
from flet_webview_all import FletWebviewAll


def main(page: ft.Page):
    page.title = "FletWebviewAll Example"
    page.window.width = 1000
    page.window.height = 800
    page.vertical_alignment = ft.MainAxisAlignment.STRETCH
    page.horizontal_alignment = ft.CrossAxisAlignment.STRETCH

    # State variables
    current_url = "https://www.google.com"
    webview = None

    def url_change(e):
        nonlocal current_url
        current_url = url_input.value
        url_input.value = ""
        page.update()

    def load_example(example_name):
        nonlocal current_url
        if example_name == "google":
            current_url = "https://www.google.com"
        elif example_name == "github":
            current_url = "https://github.com"
        elif example_name == "flutter":
            current_url = "https://flutter.dev"
        elif example_name == "html":
            current_url = None
            # Create webview with HTML content
            webview.html = """
            <!DOCTYPE html>
            <html>
            <head>
                <title>FletWebviewAll Example</title>
                <style>
                    body { font-family: Arial, sans-serif; margin: 20px; background-color: #f0f0f0; }
                    h1 { color: #333; }
                    p { color: #666; line-height: 1.6; }
                    button { padding: 10px 20px; background-color: #007bff; color: white; border: none; border-radius: 4px; cursor: pointer; }
                    button:hover { background-color: #0056b3; }
                    .code { background-color: #e0e0e0; padding: 10px; border-radius: 4px; font-family: monospace; }
                </style>
            </head>
            <body>
                <h1>Welcome to FletWebviewAll! 🎉</h1>
                <p>This is a custom HTML page rendered directly in the webview.</p>
                <p>FletWebviewAll Control provides a cross-platform webview for displaying web content in your Flet application.</p>
                <h2>Features:</h2>
                <ul>
                    <li>Load URLs (http, https, file)</li>
                    <li>Display HTML content directly</li>
                    <li>JavaScript support</li>
                    <li>Zoom controls</li>
                    <li>Custom user agent</li>
                    <li>Debugging support</li>
                </ul>
                <h2>Supported Platforms:</h2>
                <ul>
                    <li>Android</li>
                    <li>iOS</li>
                    <li>macOS</li>
                    <li>Windows</li>
                    <li>Web</li>
                </ul>
                <p><button onclick="alert('JavaScript is working!')">Click Me</button></p>
            </body>
            </html>
            """
        page.update()

    # URL input section
    url_input = ft.TextField(
        label="Enter URL",
        on_submit=url_change,
        width=400,
    )
    load_url_btn = ft.IconButton(
        icon=ft.Icons.CHECK,
        on_click=lambda _: url_change(None),
        tooltip="Load URL",
    )

    # Example buttons
    example_buttons = ft.Row(
        [
            ft.ElevatedButton("Google", on_click=lambda _: load_example("google")),
            ft.ElevatedButton("GitHub", on_click=lambda _: load_example("github")),
            ft.ElevatedButton("Flutter", on_click=lambda _: load_example("flutter")),
            ft.ElevatedButton("HTML Example", on_click=lambda _: load_example("html")),
        ],
        spacing=10,
        wrap=True,
    )

    # Settings controls
    allow_nav_switch = ft.Switch(
        label="Allow Navigation",
        value=True,
        on_change=lambda e: page.update(),
    )
    zoom_switch = ft.Switch(
        label="Zoom Enabled",
        value=True,
        on_change=lambda e: page.update(),
    )
    js_switch = ft.Switch(
        label="JavaScript Enabled",
        value=True,
        on_change=lambda e: page.update(),
    )

    # Main webview control
    webview = FletWebviewAll(
        url=current_url,
        allow_navigation=allow_nav_switch.value,
        zoom_enabled=zoom_switch.value,
        javascript_enabled=js_switch.value,
        expand=True,
    )

    # Update webview settings when switches change
    def on_setting_change(e):
        webview.allow_navigation = allow_nav_switch.value
        webview.zoom_enabled = zoom_switch.value
        webview.javascript_enabled = js_switch.value
        page.update()

    allow_nav_switch.on_change = on_setting_change
    zoom_switch.on_change = on_setting_change
    js_switch.on_change = on_setting_change

    # Controls panel
    controls_panel = ft.Column(
        [
            ft.Text("URL Input", style=ft.TextThemeStyle.HEADLINE_SMALL),
            ft.Row(
                [url_input, load_url_btn],
                spacing=10,
                wrap=True,
            ),
            ft.Divider(),
            ft.Text("Quick Load Examples", style=ft.TextThemeStyle.HEADLINE_SMALL),
            example_buttons,
            ft.Divider(),
            ft.Text("Settings", style=ft.TextThemeStyle.HEADLINE_SMALL),
            allow_nav_switch,
            zoom_switch,
            js_switch,
        ],
        spacing=10,
        run_spacing=10,
    )

    # Main layout
    main_content = ft.Column(
        [
            ft.Container(
                content=controls_panel,
                padding=10,
                bgcolor=ft.Colors.GREY_100,
            ),
            ft.Divider(height=1),
            webview,
        ],
        spacing=0,
        expand=True,
    )

    page.add(main_content)


if __name__ == "__main__":
    ft.run(main)
