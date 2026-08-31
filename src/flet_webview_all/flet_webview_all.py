from typing import Optional

import flet as ft


@ft.control("flet_webview_all")
class FletWebviewAll(ft.LayoutControl):
    """
    FletWebviewAll Control - A unified webview control for displaying web content across all platforms.
    
    This control integrates the webview_all Flutter package, providing a cross-platform webview
    that works on Android, iOS, macOS, Windows, and Web platforms.
    
    Properties:
        url: The URL to load in the webview (http, https, file://, or data: URLs)
        html: HTML content to display (alternative to url)
        allow_navigation: Whether to allow navigation to new URLs (default: True)
        zoom_enabled: Whether zoom controls are enabled (default: True)
        javascript_enabled: Whether JavaScript is enabled (default: True)
        user_agent: Custom User-Agent string
        debugging_enabled: Whether debugging is enabled (default: False)
        remote_debugging_port: Windows-only, startup-time WebView2 CDP port.
            Must be between 1 and 65535. When set, Playwright can attach to
            the same visible WebView with chromium.connect_over_cdp().
    """

    url: Optional[str] = None
    html: Optional[str] = None
    allow_navigation: bool = True
    zoom_enabled: bool = True
    javascript_enabled: bool = True
    user_agent: Optional[str] = None
    debugging_enabled: bool = False
    remote_debugging_port: Optional[int] = None
