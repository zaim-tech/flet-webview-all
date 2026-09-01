# Console capture

Set `debugging_enabled=True` on the Flet control to forward page console
messages to the platform debug log.

!!! warning
    Avoid uploading page content or sensitive console values without user
    consent.

## Receiving console messages in Python

Python applications can receive console messages as typed Flet events:

```python
def console_message(e):
    print(f"[{e.level}] {e.message}")

webview = FletWebviewAll(
    url="https://example.com",
    on_console_message=console_message,
)
```

`debugging_enabled=True` continues to print messages through the platform
debug log; `on_console_message` is useful when the Python app needs to display
or record them.

## Web platform limits

On Web, cross-origin iframe content cannot be scripted by the host. APIs
such as JavaScript evaluation, channels, console hooks, and scroll
reads/writes require same-origin content or plugin-managed isolated HTML.

See [Debugging & DevTools](debugging.md) for full DevTools access per
platform, and [Events](../controls/fletwebviewall/events.md) for the
`on_console_message` event signature.
