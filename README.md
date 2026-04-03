English | [한국어](README_KO.md) | [日本語](README_JA.md)

<img src="assets/icon.png" alt="Superboard icon" width="72" />

# Superboard

Superboard is a macOS menu bar clipboard history app focused on a fast, keyboard-first paste workflow.

Copy something, press Cmd+Shift+V, pick an item, and it pastes into the focused app.

This project is still early and macOS-first. The goal is a fast picker with solid support for text, images, and files, built around a keyboard-first workflow.

## Requirements

- macOS 14+

## Installation

Download the latest `.dmg` (or `.zip`) from [GitHub Releases](https://github.com/HowToBeAHappyBoy/Superboard/releases).

If macOS blocks the first launch, use Finder → right-click the app → Open, or allow it in System Settings → Privacy & Security.
If you see “can’t be opened” warnings, you may need to click “Open Anyway” in System Settings → Privacy & Security.

## Features

### Core

- Clipboard history for text, images, and files
- Paste picker with global hotkey (default: Cmd+Shift+V)
- Keyboard navigation and immediate paste

### Settings

- Picker size and history size
- Shortcut and launch at login
- Virtual clipboard (restore original clipboard after paste)

## Usage

1. Launch Superboard.
2. Copy text, an image, or a file.
3. Press Cmd+Shift+V to open the picker.
4. Pick an item and it pastes into the currently focused app.

## Permissions

Superboard uses Accessibility so it can paste into the currently focused app.

If paste doesn’t work, check:

- System Settings → Privacy & Security → Accessibility → enable Superboard

## Data & privacy

Superboard runs locally.

- Clipboard history is stored at `~/Library/Application Support/Superboard/history.json`.
- Settings are stored in `UserDefaults`.

## Troubleshooting

- Picker opens, but paste does nothing: re-check Accessibility permission and restart the app.
- Hotkey doesn’t work: make sure Superboard is running, and try changing the shortcut in Settings.

## Development

Build scripts for maintainers:

```sh
scripts/build-zip.sh
scripts/build-dmg-pretty.sh
```

## License

MIT
