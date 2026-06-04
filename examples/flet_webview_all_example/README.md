# FletWebviewAll Example App

A comprehensive example demonstrating the FletWebviewAll control features.

## Features Demonstrated

- Loading websites from URLs
- Displaying HTML content directly
- URL input and loading
- JavaScript enable/disable
- Zoom control enable/disable
- Navigation control enable/disable
- Quick-load buttons for popular websites

## Running the Example

### Development Mode

```bash
# Using uv
uv run flet run

# Using pip
pip install -r requirements.txt
flet run
```

### Building for Distribution

Build for your target platform:

```bash
# macOS
flet build macos -v

# Windows
flet build windows -v

# Android
flet build apk -v

# iOS
flet build ipa -v

# Web
flet build web -v
```

## Quick-Load Examples

The app includes quick-load buttons for:
- **Google** - Search engine
- **GitHub** - Code repository
- **Flutter** - Flutter documentation
- **HTML Example** - Custom HTML content

## Features

### URL Input
Enter any URL and press Enter or click the check icon to load it.

### Settings Panel
Control various webview settings:
- **Allow Navigation**: Toggle link navigation on/off
- **Zoom Enabled**: Toggle zoom controls
- **JavaScript Enabled**: Toggle JavaScript execution

### Responsive Layout
- Top control panel with settings
- Full-screen webview below
- Accessible on all platforms

## Customization

Edit `src/main.py` to:
- Add more quick-load URLs
- Customize the HTML example
- Change colors and styling
- Add additional controls

## Requirements

- Python 3.10+
- Flet >= 0.85.2
- flet-webview-all extension

## Platform Notes

### Android & iOS
- First build takes longer due to compilation
- Subsequent changes don't require full rebuild
- Test on physical device for best results

### macOS & Windows
- WebView2 runtime required on Windows
- Debugging features available via DevTools

### Web
- Some URLs may fail due to CORS policies
- Custom User-Agent may not be fully supported

## Troubleshooting

### App won't build
1. Clear cache: `flet clean`
2. Delete build folder: `rm -rf build`
3. Try again: `flet build macos -v`

### Webview blank
- Check URL format (should include http:// or https://)
- Verify network connectivity
- Enable debugging for console output

### JavaScript not working
- Check `javascript_enabled` is True
- Verify JavaScript code syntax
- Check browser console for errors

## Support

For issues:
1. Check [FletWebviewAll documentation](../docs/)
2. Review [main README](../README.md)
3. File an issue on the project repository

To run the app whenin using `pip`:

```
flet run [app_directory]
```
