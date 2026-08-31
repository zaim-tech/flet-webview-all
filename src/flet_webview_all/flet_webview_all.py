from dataclasses import dataclass
from typing import Any, Optional, Union

import flet as ft


@dataclass
class WebViewPageEvent(ft.Event["FletWebviewAll"]):
    """A page-load event containing the affected URL."""

    url: str


@dataclass
class WebViewProgressEvent(ft.Event["FletWebviewAll"]):
    """A page-load progress update, from 0 through 100."""

    progress: int


@dataclass
class WebViewResourceErrorEvent(ft.Event["FletWebviewAll"]):
    """Details reported by the platform for a failed web resource."""

    domain: str
    description: str
    error_code: int
    error_type: str
    is_for_main_frame: bool


@dataclass
class WebViewJavaScriptMessageEvent(ft.Event["FletWebviewAll"]):
    """A message posted by a registered JavaScript channel."""

    channel_name: str
    message_body: str


@dataclass
class WebViewNavigationRequestEvent(ft.Event["FletWebviewAll"]):
    """A navigation request observed by the WebView."""

    url: str
    is_main_frame: bool


@ft.control("flet_webview_all")
class FletWebviewAll(ft.LayoutControl):
    """A unified, controllable WebView backed by ``webview_all``.

    Event handlers receive the typed event objects declared above. Controller
    methods are coroutines and must be awaited after the control is on a page.
    """

    url: Optional[str] = None
    html: Optional[str] = None
    allow_navigation: bool = True
    zoom_enabled: bool = True
    javascript_enabled: bool = True
    javascript_mode: Optional[Union[str, bool]] = None
    javascript_channels: Optional[list[str]] = None
    user_agent: Optional[str] = None
    debugging_enabled: bool = False
    background_color: Optional[ft.ColorValue] = None
    remote_debugging_port: Optional[int] = None

    on_page_started: Optional[ft.EventHandler[WebViewPageEvent]] = None
    on_page_finished: Optional[ft.EventHandler[WebViewPageEvent]] = None
    on_progress: Optional[ft.EventHandler[WebViewProgressEvent]] = None
    on_web_resource_error: Optional[ft.EventHandler[WebViewResourceErrorEvent]] = None
    on_navigation_request: Optional[ft.EventHandler[WebViewNavigationRequestEvent]] = None
    on_javascript_message: Optional[
        ft.EventHandler[WebViewJavaScriptMessageEvent]
    ] = None

    async def reload(self) -> None:
        """Reload the current page."""
        await self._invoke_method("reload")

    async def stop_loading(self) -> None:
        """Best-effort cancellation of the current document load."""
        await self._invoke_method("stop_loading")

    async def can_go_back(self) -> bool:
        """Return whether browser history has a previous entry."""
        return await self._invoke_method("can_go_back")

    async def go_back(self) -> None:
        """Navigate to the previous history entry, if any."""
        await self._invoke_method("go_back")

    async def can_go_forward(self) -> bool:
        """Return whether browser history has a following entry."""
        return await self._invoke_method("can_go_forward")

    async def go_forward(self) -> None:
        """Navigate to the next history entry, if any."""
        await self._invoke_method("go_forward")

    async def clear_cache(self) -> None:
        """Clear the browser HTTP, Cache API, and application caches."""
        await self._invoke_method("clear_cache")

    async def clear_cookies(self) -> bool:
        """Clear cookies shared by WebViews in this application."""
        return await self._invoke_method("clear_cookies")

    async def get_current_url(self) -> Optional[str]:
        """Return the URL currently displayed by the WebView."""
        return await self._invoke_method("get_current_url")

    async def run_javascript(self, script: str) -> None:
        """Evaluate JavaScript in the active document without returning a value."""
        await self._invoke_method("run_javascript", {"script": script})

    async def run_javascript_returning_result(self, script: str) -> Any:
        """Evaluate JavaScript and return a platform-serializable result."""
        return await self._invoke_method(
            "run_javascript_returning_result", {"script": script}
        )
