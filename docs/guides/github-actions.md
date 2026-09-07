# GitHub Actions builds

The workflow below builds the example application for Linux, macOS, Windows,
Android, iOS, and Web, then uploads each result as a GitHub Actions artifact.
Save it as `.github/workflows/build-example.yml` in your application or fork.

The example's working directory is set explicitly so Flet finds its
`pyproject.toml`, source, and local extension path dependency.

```yaml
name: Build Flet App
on:
  push:
  pull_request:
  workflow_dispatch:
env:
  UV_PYTHON: 3.12
  PYTHONUTF8: 1
  # https://flet.dev/docs/reference/environment-variables
  FLET_CLI_NO_RICH_OUTPUT: 1
jobs:
  build:
    name: Build ${{ matrix.name }}
    runs-on: ${{ matrix.runner }}
    strategy:
      fail-fast: false
      matrix:
        include:
          # -------- Desktop --------
          - name: linux
            runner: ubuntu-latest
            build_cmd: "flet build linux"
            artifact_path: build/linux
            needs_linux_deps: true
          - name: macos
            runner: macos-26
            build_cmd: "flet build macos"
            artifact_path: build/macos
            needs_linux_deps: false
          - name: windows
            runner: windows-latest
            build_cmd: "flet build windows"
            artifact_path: build/windows
            needs_linux_deps: false
          # -------- Android --------
          - name: aab
            runner: ubuntu-latest
            build_cmd: "flet build aab"
            artifact_path: build/aab
            needs_linux_deps: false
          - name: apk
            runner: ubuntu-latest
            build_cmd: "flet build apk"
            artifact_path: build/apk
            needs_linux_deps: false
          # -------- iOS --------
          - name: ipa
            runner: macos-26
            build_cmd: "flet build ipa"
            artifact_path: build/ipa
            needs_linux_deps: false
          - name: ios-simulator
            runner: macos-26
            build_cmd: "flet build ios-simulator"
            artifact_path: build/ios-simulator
            needs_linux_deps: false
          # -------- Web --------
          - name: web
            runner: ubuntu-latest
            build_cmd: "flet build web"
            artifact_path: build/web
            needs_linux_deps: false
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
      - name: Setup uv
        uses: astral-sh/setup-uv@v6
      - name: Install Linux dependencies
        if: matrix.needs_linux_deps
        shell: bash
        run: |
            sudo apt update --allow-releaseinfo-change
            LINUX_DEPS="$(uv run flet --version --json | jq -r '.linux_dependencies | join(" ")')"
            sudo apt-get install -y --no-install-recommends $LINUX_DEPS
            # Required by the webview_all Flutter plugin (not covered by flet's own dependency list)
            sudo apt-get install -y --no-install-recommends \
              libwebkit2gtk-4.1-dev \
              libgtk-3-dev
            sudo apt-get clean
      - name: Build app
        shell: bash
        run: |
          uv run ${{ matrix.build_cmd }} --yes --verbose
      - name: Upload Artifact
        uses: actions/upload-artifact@v5.0.0
        with:
          name: ${{ matrix.name }}-build-artifact
          path: ${{ matrix.artifact_path }}
          if-no-files-found: error
          overwrite: false
```

## Notes

- `setup-uv` provides Python 3.12 and resolves the example dependencies.
- Linux installs the WebKitGTK/GTK development libraries needed by Flet.
- iOS builds run on macOS runners. Add signing certificates and provisioning
  profiles for App Store-ready artifacts.
- The matrix uses independent jobs, so one platform failure does not cancel the
  others.
- `remote_debugging_port` is for local testing only and should not be enabled
  in production builds.

See Flet's [environment variable reference](https://flet.dev/docs/reference/environment-variables/)
for additional CI configuration options.
