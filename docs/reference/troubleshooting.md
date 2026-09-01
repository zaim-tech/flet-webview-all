# Troubleshooting

## Webview not loading

- Check that the URL is valid and accessible
- For local files, use the `file://` scheme
- Verify network connectivity

## JavaScript not working

- Ensure `javascript_enabled=True`
- Check the browser console for errors (enable debugging) — see
  [Console capture](../guides/console.md)
- Verify the JavaScript code is correct

## Performance issues

- Consider disabling zoom if not needed
- Disable JavaScript if not required
- Use smaller HTML content when possible

## A setting appears unchanged

See
[If a setting appears unchanged](../controls/fletwebviewall/properties.md#runtime-property-updates)
for the difference between Python property changes (take effect on
`page.update()`) and native rebuilds (require rebuilding the extension).
