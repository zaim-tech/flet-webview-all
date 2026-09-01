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

The underlying Flutter controller also supports opening DevTools when
writing a custom Flutter extension:

```dart
final windows = controller.platform as WindowsWebViewController;
await windows.openDevTools();
final version = await WindowsWebViewController.getWebViewVersion();
debugPrint('WebView2 runtime: $version');
```

## Android

```dart
await AndroidWebViewController.enableDebugging(true);
```

Inspect the Android WebView with Chrome or Edge remote debugging tools.

## iOS and macOS

```dart
final webKit = controller.platform as WebKitWebViewController;
await webKit.setInspectable(true);
```

Availability depends on the OS version and developer settings.

## Linux

```dart
final linux = controller.platform as LinuxWebViewController;
await linux.setDeveloperExtrasEnabled(true);
await linux.openDevTools();
```

You can also set `developerExtrasEnabled` in
`LinuxWebViewControllerCreationParams` when constructing a custom
controller.

## OHOS and Web

```dart
await OhosWebViewController.enableDebugging(true);
```

On Web, use browser DevTools. The control is rendered in an iframe;
browser same-origin rules apply.

For console output specifically (rather than full DevTools), see
[Console capture](console.md).

See the
[upstream common API](https://abandoft.github.io/webview_all/reference/common-api/)
for platform controller details.
