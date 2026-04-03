Superboard is a macOS menu bar clipboard history app.

Copy something, press Command Shift V, pick an item, and it pastes into the focused app.

This project is early and macOS first. It focuses on a fast picker, support for text, images, and files, and a keyboard first workflow.

Downloads and docs

You can build from source, or download a DMG from GitHub Releases if one is available.

Documentation lives in docs/README.md, with Korean and Japanese versions linked there.

Build and run

SwiftPM commands should work on a typical macOS dev setup.

swift test
swift run SuperboardMacApp

If SwiftPM is broken on your machine, there are scripts that build with xcrun swiftc.

scripts/dev-run.sh

Packaging

scripts/build-zip.sh produces dist/Superboard-macos.zip.
scripts/build-dmg-pretty.sh produces dist/Superboard.dmg.

Permissions

Superboard uses Accessibility so it can paste into the currently focused app.
