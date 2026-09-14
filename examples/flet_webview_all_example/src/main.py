import os

import flet as ft
from flet_webview_all import FletWebviewAll


REMOTE_DEBUGGING_PORT = os.getenv("FLET_WEBVIEW_ALL_REMOTE_DEBUGGING_PORT")

BRIDGE_HTML = """
<!doctype html>
<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Flet Bridge Test</title>
    <style>
        body { font-family: Segoe UI, sans-serif; padding: 32px; color: #17324d; }
        button { border: 0; border-radius: 8px; padding: 12px 16px; margin: 5px;
            color: white; background: #2563eb; cursor: pointer; }
        button.green { background: #059669; }
        #result { margin-top: 20px; font-weight: 600; }
    </style>
</head>
<body>
    <h1>Flet Bridge Test</h1>
    <p>This is local HTML loaded directly into the native WebView.</p>
    <button class="green" onclick="console.info('JavaScript console works')">Test console</button>
    <button onclick="alert('JavaScript alert works')">Test alert</button>
    <button onclick="document.getElementById('result').textContent = 'JavaScript works'">Change HTML</button>
    <p id="result">Waiting for a test...</p>
</body>
</html>
"""

BOOKMARKS = {
    "Flet": ("https://flet.dev", ft.Icons.AUTO_AWESOME),
    "Flutter": ("https://flutter.dev", ft.Icons.TUNE),
    "GitHub": ("https://github.com", ft.Icons.CODE),
    "Example": ("https://example.com", ft.Icons.PUBLIC),
}


def main(page: ft.Page):
    page.title = "Fieldnotes"
    page.window.width = 1000
    page.window.height = 800
    page.padding = 0
    page.theme_mode = ft.ThemeMode.SYSTEM

    current_url = "https://flet.dev"
    webview = None
    page_label = ft.Text("Ready", size=12, color=ft.Colors.GREY_800)
    url_field = ft.TextField(value=current_url, dense=True, expand=True)

    def on_page_started(e):
        page_label.value = f"Loading {e.url}"
        page.update()

    def on_page_finished(e):
        page_label.value = f"Reading {e.url}"
        page.update()

    def on_web_resource_error(e):
        location = e.domain or "main document"
        page_label.value = (
            f"Could not load {location}: {e.description} "
            f"(error {e.error_code})"
        )
        page.update()

    def on_console_message(e):
        page_label.value = f"JavaScript console [{e.level}]: {e.message}"
        page.update()

    def set_webview_url(url: str):
        nonlocal current_url
        current_url = url
        url_field.value = url
        webview.url = url
        webview.html = None
        page.update()

    def open_url(e=None):
        value = (url_field.value or "").strip()
        if not value:
            return
        if not value.startswith(("http://", "https://")):
            value = "https://" + value
        set_webview_url(value)

    def open_bridge_test(e=None):
        nonlocal current_url
        current_url = None
        url_field.value = "Local HTML / Flet Bridge Test"
        webview.url = None
        webview.html = BRIDGE_HTML
        page_label.value = "Local HTML loaded"
        page.update()

    def bookmark_button(name, icon):
        return ft.TextButton(
            content=ft.Row([ft.Icon(icon, size=17), ft.Text(name)], spacing=10),
            on_click=lambda _: set_webview_url(BOOKMARKS[name][0]),
        )

    webview = FletWebviewAll(
        url=current_url,
        allow_navigation=True,
        zoom_enabled=True,
        javascript_enabled=True,
        background_color=ft.Colors.WHITE,
        on_page_started=on_page_started,
        on_page_finished=on_page_finished,
        on_web_resource_error=on_web_resource_error,
        on_console_message=on_console_message,
        remote_debugging_port=(
            int(REMOTE_DEBUGGING_PORT) if REMOTE_DEBUGGING_PORT else None
        ),
        expand=True,
    )

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
        page_label.value = f"Page title: {title}"
        page.update()

    sidebar = ft.Container(
        width=190,
        padding=ft.Padding.only(left=18, right=12, top=24, bottom=18),
        bgcolor=ft.Colors.BLUE,
        content=ft.Column(
            [
                ft.Text("FIELDNOTES", size=16, weight=ft.FontWeight.BOLD),
                ft.Text("A quiet place to browse", size=13, color=ft.Colors.GREY_600),
                ft.Divider(height=26),
                ft.Text("SAVED PLACES", size=10, color=ft.Colors.GREY_600),
                *[bookmark_button(name, icon) for name, (_, icon) in BOOKMARKS.items()],
                ft.Divider(height=26),
                ft.Text("TOOLS", size=10, color=ft.Colors.GREY_600),
                ft.TextButton("Page title", icon=ft.Icons.TITLE, on_click=page_title),
                ft.TextButton("Back", icon=ft.Icons.ARROW_BACK, on_click=go_back),
                ft.TextButton("Forward", icon=ft.Icons.ARROW_FORWARD, on_click=go_forward),
                ft.TextButton("Reload", icon=ft.Icons.REFRESH, on_click=reload),
                ft.TextButton("Bridge lab", icon=ft.Icons.BOLT, on_click=open_bridge_test),
                ft.Container(expand=True),
                ft.Text("Windows WebView desk", size=13, color=ft.Colors.BLACK),
            ],
            spacing=4,
            
        ),
    )

    browser_bar = ft.Container(
        padding=ft.Padding.only(left=18, right=18, top=14, bottom=10),
        content=ft.Row(
            [
                ft.Icon(ft.Icons.LANGUAGE, color=ft.Colors.BLUE_GREY_700),
                url_field,
                ft.IconButton(ft.Icons.ARROW_CIRCLE_RIGHT, on_click=open_url),
            ],
        ),
    )

    workspace = ft.Column(
        [
            browser_bar,
            webview,
            ft.Container(page_label, padding=ft.Padding.only(left=18, top=7, bottom=7),
                         bgcolor=ft.Colors.GREEN),
        ],
        spacing=0,
        expand=True,
    )

    page.add(ft.Row([sidebar, workspace], spacing=0, expand=True))

if __name__ == "__main__":
    ft.run(main)
