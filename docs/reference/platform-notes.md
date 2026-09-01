# Platform notes

## Android
- Requires API level 19 or higher
- JavaScript is enabled by default
- User-Agent can be customized per URL

## iOS
- Requires iOS 11.0 or higher
- JavaScript is enabled by default
- Custom User-Agent requires iOS 13.0+

## macOS
- Requires macOS 10.11 or higher
- Full JavaScript support
- Custom User-Agent supported

## Windows
- Requires Windows 10 or higher
- WebView2 must be installed on the system
- Full JavaScript support
- Supports Playwright attachment through `remote_debugging_port` — see
  [Playwright (Windows CDP)](../controls/fletwebviewall/playwright.md)

## Web
- Uses an iframe for embedding
- Some restrictions may apply based on CORS policies
- Custom User-Agent may not be fully supported
- Cross-origin iframe content cannot be scripted by the host — see
  [Console capture](../guides/console.md#web-platform-limits)
