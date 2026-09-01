# Permissions

Web content permissions have two layers:

1. Your app must have the operating-system permission (for example, camera or microphone).
2. The WebView must approve the page request.

Before enabling the WebView layer, request the operating-system permission with
Flet's official `flet-permission-handler` package:

```bash
pip install flet-permission-handler
```

```python
import flet_permission_handler as fph

ph = fph.PermissionHandler()
status = await ph.request(fph.Permission.MICROPHONE)
print(status.name if status else "unknown")
```

Add the package to your Flet application's dependencies when you use this
permission flow. The WebView extension itself does not require it for ordinary
URL/HTML rendering. It supports Android, iOS, Windows, and Web; mobile targets
still need native permission declarations.

`FletWebviewAll` exposes the WebView layer through `allow_webview_permissions`
and `on_permission_request`. The default is safe: requests are denied. Set the
flag only when your app has a deliberate permission policy.

!!! warning
    Granting a WebView request does not grant the operating-system permission.
    Configure Android, iOS, macOS, Windows, or browser permissions separately.

## Basic permission policy

```python
import flet as ft
import flet_permission_handler as fph
from flet_webview_all import FletWebviewAll


def permission_requested(e):
    print("Web page requested:", e.resource_types)


def main(page: ft.Page):
    ph = fph.PermissionHandler()

    async def request_microphone(_):
        status = await ph.request(fph.Permission.MICROPHONE)
        print("OS permission:", status.name if status else "unknown")

    page.add(
        ft.Column([
            ft.Button("Request microphone OS permission", on_click=request_microphone),
            FletWebviewAll(
                url="https://example.com",
                allow_webview_permissions=True,
                on_permission_request=permission_requested,
                expand=True,
            ),
        ], expand=True)
    )


ft.run(main)
```

The event is informational. The native callback must decide immediately, so
the control grants all requested resources when `allow_webview_permissions`
is `True` and denies them when it is `False`. This avoids an asynchronous Flet
event leaving a native permission prompt unresolved.

## Resource types

Common resource names include:

| Resource | Meaning |
| --- | --- |
| `camera` | Camera capture. |
| `microphone` | Audio capture. |

The underlying platform may also report Android/OHOS-specific resources such
as MIDI sysex or protected media identifiers. Treat unknown values as denied
unless you have reviewed the target platform's security model.

## Camera and microphone checklist

```python
def permission_requested(e):
    allowed = {"camera", "microphone"}
    unexpected = set(e.resource_types) - allowed
    if unexpected:
        print("Unexpected request; review before enabling:", unexpected)
    else:
        print("Approved WebView resources:", e.resource_types)
```

Before enabling the flag, add the matching native declarations and request the
OS permission. For web deployments, the browser owns the final prompt and the
page generally must be served from a secure (`https`) origin.

## Geolocation, file selectors, and fullscreen

The detailed geolocation prompt, Android/OHOS file selector, and custom
fullscreen widget callbacks are platform-native APIs from `webview_all`. They
are not exposed as portable Flet properties because their callback signatures
and permission objects differ by platform. Add those callbacks in a custom
Flutter extension when you need them, following the upstream documentation:

- [webview_all permissions guide](https://abandoft.github.io/webview_all/guides/permissions/)
- [webview_all common API](https://abandoft.github.io/webview_all/reference/common-api/)

This extension's portable permission surface intentionally covers camera and
microphone approval plus safe default denial across supported platforms.
