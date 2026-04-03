# Superboard

![Superboard icon](docs/assets/icon.png)

Superboard is a macOS menu bar clipboard history app.

Copy something, press Cmd+Shift+V, pick an item, and it pastes into the focused app.

This project is still early and macOS-first. The goal is a fast picker with solid support for text, images, and files, built around a keyboard-first workflow.

## Documentation

- English: this README
- Korean: [docs/ko/README.md](docs/ko/README.md)
- Japanese: [docs/ja/README.md](docs/ja/README.md)

## Features

- Clipboard history for text, images, and files
- Global hotkey (default: Cmd+Shift+V)
- Keyboard navigation and immediate paste
- Settings for picker size, history size, shortcut, launch at login, and "virtual clipboard"

## Build and run

SwiftPM commands should work on a typical macOS dev setup.

```sh
swift test
swift run SuperboardMacApp
```

If SwiftPM is broken on your machine, there are scripts that build with `xcrun swiftc`.

```sh
scripts/dev-run.sh
```

## Packaging

```sh
scripts/build-zip.sh
scripts/build-dmg-pretty.sh
```

Output goes into `dist/` (ignored by git).

## Permissions

Superboard uses Accessibility so it can paste into the currently focused app.
