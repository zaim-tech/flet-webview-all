# Best practices

1. **Always provide a fallback** — use the `html` property if `url` fails to
   load. See [`url` and `html`](../controls/fletwebviewall/properties.md#url-and-html).
2. **Handle JavaScript carefully** — disable it if not needed, for security.
3. **Test cross-platform** — behavior may vary; see
   [Platform notes](platform-notes.md).
4. **Use `expand=True`** — for a full-screen webview experience.
5. **Implement error handling** — monitor the console for JavaScript errors
   during debugging; see [Console capture](../guides/console.md).
