import flet as ft
from flet_webview_all import FletWebviewAll


DEFAULT_HTML = """
<!DOCTYPE html>
<html>
<head>
    <title>FletWebviewAll Example</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background-color: #f7f7f7; color: #333; }
        p { color: #555; line-height: 1.6; }
        button { padding: 10px 20px; background-color: #007bff; color: white; border: none; border-radius: 4px; cursor: pointer; }
        button:hover { background-color: #0056b3; }
    </style>
</head>
<body>
    <h1>Welcome to FletWebviewAll!</h1>
    <p>This local HTML page is rendered directly in the webview.</p>
    <p>Use the toolbar above to load websites, switch back to this HTML example, or change webview settings.</p>
    <p><button onclick="alert('JavaScript is working!')">Click Me</button></p>
</body>
</html>
"""


def main(page: ft.Page):
    page.title = "FletWebviewAll Example"
    page.window.width = 1000
    page.window.height = 800
    page.padding = 0

    current_url = None
    webview = None

    def set_webview_url(url: str):
        nonlocal current_url
        current_url = url
        webview.url = current_url
        webview.html = None
        page.update()

    def url_change(e):
        value = (url_input.value or "").strip()
        if not value:
            return
        if not value.startswith(("http://", "https://", "file://", "data:")):
            value = "https://" + value
        url_input.value = ""
        set_webview_url(value)

    def load_example(example_name):
        nonlocal current_url
        if example_name == "google":
            set_webview_url("https://www.google.com")
        elif example_name == "github":
            set_webview_url("https://github.com")
        elif example_name == "flutter":
            set_webview_url("https://flutter.dev")
        elif example_name == "html":
            current_url = None
            webview.url = None
            webview.html = DEFAULT_HTML
            page.update()

    url_input = ft.TextField(
        label="Enter URL",
        on_submit=url_change,
        width=400,
        height=42,
    )
    load_url_btn = ft.IconButton(
        icon=ft.Icons.CHECK,
        on_click=url_change,
        tooltip="Load URL",
    )

    example_buttons = ft.Row(
        [
            ft.Button("Google", on_click=lambda _: load_example("google")),
            ft.Button("GitHub", on_click=lambda _: load_example("github")),
            ft.Button("Flutter", on_click=lambda _: load_example("flutter")),
            ft.Button("HTML Example", on_click=lambda _: load_example("html")),
        ],
        spacing=8,
        wrap=True,
    )

    allow_nav_switch = ft.Switch(label="Allow Navigation", value=True)
    zoom_switch = ft.Switch(label="Zoom Enabled", value=True)
    js_switch = ft.Switch(label="JavaScript Enabled", value=True)

    webview = FletWebviewAll(
        url=current_url,
        html=DEFAULT_HTML,
        allow_navigation=allow_nav_switch.value,
        zoom_enabled=zoom_switch.value,
        javascript_enabled=js_switch.value,
        expand=True,
    )

    def on_setting_change(e):
        webview.allow_navigation = allow_nav_switch.value
        webview.zoom_enabled = zoom_switch.value
        webview.javascript_enabled = js_switch.value
        page.update()

    allow_nav_switch.on_change = on_setting_change
    zoom_switch.on_change = on_setting_change
    js_switch.on_change = on_setting_change

    controls_panel = ft.Column(
        [
            ft.Row(
                [url_input, load_url_btn, example_buttons],
                spacing=10,
                wrap=True,
            ),
            ft.Row(
                [allow_nav_switch, zoom_switch, js_switch],
                spacing=12,
                wrap=True,
            ),
        ],
        spacing=6,
    )

    page.appbar = ft.AppBar(
        title=controls_panel,
        toolbar_height=118,
        bgcolor=ft.Colors.GREY_100,
        automatically_imply_leading=False,
        title_spacing=12,
    )

    page.add(webview)


if __name__ == "__main__":
    ft.run(main)
