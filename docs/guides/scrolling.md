# Scrolling

All scrolling methods are asynchronous and use document pixels:

```python
await webview.scroll_to(0, 0)
await webview.scroll_by(0, 300)

position = await webview.get_scroll_position()
print(position["x"], position["y"])
```

Subscribe to scroll changes with `on_scroll_position_change`:

```python
def scrolled(e):
    print(f"scroll position: {e.x}, {e.y}")

webview.on_scroll_position_change = scrolled
page.update()
```

## Scrollbar visibility

Scrollbar visibility is capability-gated. Always check support before
changing it:

```python
async def hide_scrollbars():
    if await webview.supports_set_scrollbars_enabled():
        await webview.set_vertical_scrollbar_enabled(False)
        await webview.set_horizontal_scrollbar_enabled(False)
```

Since `webview_all` 1.3.2, rendering remains engine-specific. macOS reports
this capability as unsupported because public `WKWebView` does not expose
its internal scroll view. Web and Windows implement visibility with
injected CSS.

See [Controller methods](../controls/fletwebviewall/methods.md) for the
full method list these calls belong to.
