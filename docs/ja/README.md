Superboard is a macOS menu bar clipboard history app.

Copy something, press Command Shift V, pick an item, and it pastes into the focused app.

This project is still early and macOS first. It supports text, images, and files, and it is built around a fast keyboard first picker.

Build and run

On a typical macOS dev setup you can run it with SwiftPM.

swift test
swift run SuperboardMacApp

If SwiftPM is broken on your machine, there is a fallback build script based on xcrun swiftc.

scripts/dev-run.sh

Packaging

scripts/build-zip.sh creates dist/Superboard-macos.zip.
scripts/build-dmg-pretty.sh creates dist/Superboard.dmg.

Permissions

Superboard uses Accessibility so it can paste into the currently focused app.

