# Quickstart

## Load a URL

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

`expand=True` lets the webview fill the available space — see
[Inherited properties](../controls/fletwebviewall/properties.md#inherited-properties)
for the full set of layout properties it picks up from `LayoutControl`.

## Or render inline HTML

Use `html` instead of `url` when you don't have a page to fetch — for
offline content, generated reports, or local documentation:

```python
FletWebviewAll(
    html="<h1>Hello World</h1><p>This is HTML content</p>",
    expand=True,
)
```

Only one of `url` / `html` is active at a time; see
[`url` and `html`](../controls/fletwebviewall/properties.md#url-and-html)
for how to switch between them at runtime.

## Where to next

- Add navigation, JavaScript, and lifecycle callbacks — see the
  [control reference](../controls/fletwebviewall/index.md).
- Grab a ready-made recipe — see [Examples](../guides/examples.md).
- Wire up camera/microphone access — see [Permissions](../guides/permissions.md).
