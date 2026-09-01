# Debugging & DevTools

Debugging differs by platform. Keep inspection disabled in production
builds.

## Windows

For the Flet control, use `remote_debugging_port` and Playwright/CDP — see
[Playwright (Windows CDP)](../controls/fletwebviewall/playwright.md).

The Python control also provides Windows convenience methods:

```python
async def inspect_webview(_):
    version = await webview.get_webview_version()
    print("WebView2 runtime:", version)
    await webview.open_devtools()
```

These methods raise an unsupported-platform error outside Windows. For
automation, `remote_debugging_port` is usually preferable because it
exposes a stable CDP endpoint to Playwright.

## Android

Use the platform's WebView inspection tools (for example, Chrome or Edge
remote debugging) when supported by the device and OS.

## iOS and macOS

WebKit inspection availability depends on the OS version and developer
settings. Enable inspection using the device's normal development settings.

## Linux

Use the WebKitGTK inspector supplied by the Linux runtime when available.

## OHOS and Web

Use the browser or device developer tools supplied by the target platform. On
Web, the control is rendered in an iframe and browser same-origin rules apply.

For console output specifically (rather than full DevTools), see
[Console capture](console.md).

See the
[upstream common API](https://abandoft.github.io/webview_all/reference/common-api/)
for platform controller details.
