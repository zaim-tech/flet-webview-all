# FletWebviewAll

A unified webview control for the [Flet](https://flet.dev) framework that
provides consistent, cross-platform web content display on Android, iOS,
macOS, Windows, and Web.

**Project:** [GitHub repository](https://github.com/zaim-tech/flet-webview-all) ·
**Install:** [PyPI package](https://pypi.org/project/flet-webview-all/) ·
**Issues:** [GitHub Issues](https://github.com/zaim-tech/flet-webview-all/issues)

## Why FletWebviewAll

FletWebviewAll wraps the `webview_all` Flutter package so a single Python
control renders web content the same way across every Flet target. Instead
of branching your app code per platform, you configure one
`FletWebviewAll` control and let the extension handle the underlying
Android, iOS, macOS, Windows, and Web WebView implementations.

- **Cross-platform** — one control, five platforms
- **URL or HTML** — load remote pages or render inline HTML
- **Two-way JavaScript** — run scripts, read results, and receive messages
  back through named channels
- **Full navigation & history control** — back/forward, reload, navigation
  policies
- **Built for debugging** — console capture, per-platform DevTools, and
  Playwright/WebView2 CDP attachment on Windows

## Get started

<div class="grid cards" markdown>

- :material-download:{ .lg .middle } **Install & run your first webview**

    ---

    Add the dependency and load your first page in a few lines.

    [:octicons-arrow-right-24: Getting started](getting-started/installation.md)

- :material-cog:{ .lg .middle } **Browse the FletWebviewAll control**

    ---

    Every property, event, and controller method, organized into focused
    pages.

    [:octicons-arrow-right-24: Control reference](controls/fletwebviewall/index.md)

- :material-lightbulb-on:{ .lg .middle } **Copy a working recipe**

    ---

    Navigation bars, JavaScript bridges, permission flows, and debugging
    setups you can paste in directly.

    [:octicons-arrow-right-24: Guides](guides/examples.md)

- :material-book-open-variant:{ .lg .middle } **Look something up**

    ---

    Platform notes, best practices, troubleshooting, and project links.

    [:octicons-arrow-right-24: Reference](reference/platform-notes.md)

</div>
