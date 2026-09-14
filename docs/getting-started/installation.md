# Installation

FletWebviewAll ships as a Flet extension. Add it to your app's dependencies
and Flet will build the platform-native extension the first time you run
or package your app.

## Add the dependency

In your `pyproject.toml`:

```toml
dependencies = [
    "flet-webview-all @ git+https://github.com/yourusername/flet-webview-all",
    "flet>=0.85.2",
]
```

Or, once published on PyPI:

```toml
dependencies = [
    "flet-webview-all",
    "flet>=0.85.2",
]
```

## Import it

```python
from flet_webview_all import FletWebviewAll
```

## Platform prerequisites

Different platforms need different runtime pieces before the control will
render. See [Platform notes](../reference/platform-notes.md) for the full
list — the most common one to check first is **Windows**, which requires
the WebView2 runtime to be installed on the machine. For Linux, install the
WebKitGTK 4.1 development/runtime package before building:

```bash
sudo apt-get install libwebkit2gtk-4.1-dev
```

The Linux plugin installs the required `GtkOverlay` automatically, so you do
not need to modify `linux/runner/my_application.cc`.

## Next step

Continue to the [quickstart](quickstart.md) to load your first page.
