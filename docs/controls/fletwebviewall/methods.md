# Controller methods

The following coroutines are available once the control is on a page:

```python
await webview.reload()
await webview.stop_loading()  # browser-standard window.stop(), best effort
await webview.go_back()
await webview.go_forward()
can_go_back = await webview.can_go_back()
can_go_forward = await webview.can_go_forward()
await webview.clear_cache()
cookies_were_cleared = await webview.clear_cookies()
url = await webview.get_current_url()
await webview.run_javascript("document.body.dataset.ready = 'true'")
value = await webview.run_javascript_returning_result("document.title")
await webview.scroll_to(0, 0)
await webview.scroll_by(0, 300)
position = await webview.get_scroll_position()
if await webview.supports_set_scrollbars_enabled():
    await webview.set_vertical_scrollbar_enabled(False)
await webview.open_devtools()  # Windows/WebView2 only
version = await webview.get_webview_version()  # Windows/WebView2 only
```

`clear_cookies()` clears the cookie store shared by application WebViews.
`stop_loading()` is best effort because `webview_all` does not expose a
native stop-loading API. Scrolling and per-platform debugging methods are
covered in more depth in [Scrolling](../../guides/scrolling.md) and
[Debugging & DevTools](../../guides/debugging.md).

## Controller method examples

```python
async def browser_actions(_):
    if await webview.can_go_back():
        await webview.go_back()
    if await webview.can_go_forward():
        await webview.go_forward()
    await webview.reload()
    await webview.stop_loading()  # best effort: window.stop()
    await webview.run_javascript("document.body.style.zoom = '110%'")
    result = await webview.run_javascript_returning_result("document.title")
    current = await webview.get_current_url()
    await webview.clear_cache()
    cookies_removed = await webview.clear_cookies()
    print(result, current, cookies_removed)
```

All methods are asynchronous and require the control to have been added to
a page. `clear_cookies()` affects the application-wide WebView cookie
store.

## More practical recipes

### Run JavaScript after loading

```python
async def highlight_page(e):
    await webview.run_javascript(
        "document.body.style.fontFamily = 'system-ui';"
    )

webview.on_page_finished = highlight_page
```

For automated testing of these same methods from outside the app, see
[Playwright (Windows CDP)](playwright.md).
