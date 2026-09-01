import os

import flet as ft
from flet_webview_all import FletWebviewAll


DEFAULT_HTML = """
<!DOCTYPE html>
<html>
<head>
    <title>FletWebviewAll Example</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; min-height: 2200px; background-color: #f7f7f7; color: #333; }
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
    <p><button onclick="FletBridge.postMessage('Hello from the embedded page!')">Send message to Python</button></p>
</body>
</html>
"""

REMOTE_DEBUGGING_PORT = os.getenv("FLET_WEBVIEW_ALL_REMOTE_DEBUGGING_PORT")


def main(page: ft.Page):
    page.title = "FletWebviewAll Example"
    page.window.width = 1000
    page.window.height = 800
    page.padding = ft.Padding.all(20)
    page.theme_mode = ft.ThemeMode.SYSTEM

    current_url = None
    webview = None
    status = ft.Text("Ready")
    progress = ft.ProgressBar(value=0, width=180)

    def on_page_started(e):
        status.value = f"Loading: {e.url}"
        progress.value = 0
        page.update()

    def on_page_finished(e):
        status.value = f"Loaded: {e.url}"
        progress.value = 1
        page.update()

    def on_progress(e):
        progress.value = e.progress / 100
        page.update()

    def on_javascript_message(e):
        status.value = f"{e.channel_name}: {e.message_body}"
        page.update()

    def on_permission_request(e):
        status.value = f"WebView permission request: {', '.join(e.resource_types)}"
        page.update()

    def on_scroll_position_change(e):
        status.value = f"Scroll position: ({e.x}, {e.y})"
        page.update()

    def on_console_message(e):
        status.value = f"Console [{e.level}]: {e.message}"
        page.update()

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
        elif example_name == "flet":
            set_webview_url("https://flet.dev")
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
            ft.Button("Flet", on_click=lambda _: load_example("flet")),
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
        javascript_channels=["FletBridge"],
        background_color=ft.Colors.BLUE_GREY_900,
        on_page_started=on_page_started,
        on_page_finished=on_page_finished,
        on_progress=on_progress,
        on_javascript_message=on_javascript_message,
        on_permission_request=on_permission_request,
        on_scroll_position_change=on_scroll_position_change,
        on_console_message=on_console_message,
        remote_debugging_port=(
            int(REMOTE_DEBUGGING_PORT) if REMOTE_DEBUGGING_PORT else None
        ),
        expand=True,
    )

    async def on_setting_change(e):
        webview.allow_navigation = allow_nav_switch.value
        webview.zoom_enabled = zoom_switch.value
        webview.javascript_enabled = js_switch.value
        page.update()
        # Reload so engines that apply JavaScript policy at document start
        # cannot keep executing the already-loaded page.
        await webview.reload()

    allow_nav_switch.on_change = on_setting_change
    zoom_switch.on_change = on_setting_change
    js_switch.on_change = on_setting_change

    async def go_back(_):
        if await webview.can_go_back():
            await webview.go_back()

    async def go_forward(_):
        if await webview.can_go_forward():
            await webview.go_forward()

    async def reload(_):
        await webview.reload()

    async def page_title(_):
        title = await webview.run_javascript_returning_result("document.title")
        status.value = f"Page title: {title}"
        page.update()

    async def scroll_top(_):
        await webview.scroll_to(0, 0)

    async def scroll_down(_):
        await webview.scroll_by(0, 300)

    async def hide_scrollbars(_):
        if await webview.supports_set_scrollbars_enabled():
            await webview.set_vertical_scrollbar_enabled(False)
            await webview.set_horizontal_scrollbar_enabled(False)
            status.value = "Scrollbars hidden"
        else:
            status.value = "Scrollbar visibility unsupported on this engine"
        page.update()

    async def inspect_webview(_):
        try:
            version = await webview.get_webview_version()
            await webview.open_devtools()
            status.value = f"WebView2 runtime: {version} (DevTools opened)"
        except Exception as error:
            status.value = f"DevTools is Windows/WebView2 only: {error}"
        page.update()

    controls_panel = ft.Column(
        [
            ft.Row(
                [url_input, load_url_btn, example_buttons],
                spacing=10,
                wrap=True,
            ),
            ft.Row(
                [
                    ft.IconButton(ft.Icons.ARROW_BACK, on_click=go_back),
                    ft.IconButton(ft.Icons.ARROW_FORWARD, on_click=go_forward),
                    ft.IconButton(ft.Icons.REFRESH, on_click=reload),
                    ft.Button("Read page title", on_click=page_title),
                    allow_nav_switch,
                    zoom_switch,
                    js_switch,
                ],
                spacing=12,
                wrap=True,
            ),
            ft.Row(
                [
                    ft.Button("Scroll top", on_click=scroll_top),
                    ft.Button("Scroll down 300px", on_click=scroll_down),
                    ft.Button("Hide scrollbars", on_click=hide_scrollbars),
                    ft.Button("Open DevTools", on_click=inspect_webview),
                ],
                spacing=8,
                wrap=True,
            ),
            ft.Row([progress, status], spacing=12, wrap=True),
        ],
        spacing=6,
    )

    appbar = ft.AppBar(
        title=controls_panel,
        toolbar_height=158,
        automatically_imply_leading=False,
        title_spacing=12,
    )

    page.add(
        appbar,
        webview,
    )
    

if __name__ == "__main__":
    ft.run(main)
