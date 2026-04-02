#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
out_dir="${repo_root}/.devbuild"
module_cache_dir="${repo_root}/.build/ModuleCache"
target_triple="arm64-apple-macosx14.0"

mkdir -p "${out_dir}"
mkdir -p "${module_cache_dir}"

tmp_dir="$(mktemp -d)"
trap 'rm -rf "${tmp_dir}"' EXIT

core_sources=(
  "${repo_root}/Sources/SuperboardCore/CoreBootstrap.swift"
  "${repo_root}/Sources/SuperboardCore/Models/Workspace.swift"
  "${repo_root}/Sources/SuperboardCore/Models/ClipboardContent.swift"
  "${repo_root}/Sources/SuperboardCore/Support/ContentPreviewBuilder.swift"
  "${repo_root}/Sources/SuperboardCore/Models/ClipboardItem.swift"
  "${repo_root}/Sources/SuperboardCore/Services/HistoryStore.swift"
  "${repo_root}/Sources/SuperboardCore/Services/FileHistoryStore.swift"
  "${repo_root}/Sources/SuperboardCore/Services/PastePickerSession.swift"
)

app_sources=(
  "${repo_root}/Sources/SuperboardMacApp/App/SuperboardApp.swift"
  "${repo_root}/Sources/SuperboardMacApp/App/AppCoordinator.swift"
  "${repo_root}/Sources/SuperboardMacApp/MenuBar/MenuBarController.swift"
  "${repo_root}/Sources/SuperboardMacApp/Platform/Hotkey/GlobalHotKeyMonitor.swift"
  "${repo_root}/Sources/SuperboardMacApp/Platform/Permissions/AccessibilityPermissionManager.swift"
  "${repo_root}/Sources/SuperboardMacApp/Platform/Clipboard/MacPasteboardReader.swift"
  "${repo_root}/Sources/SuperboardMacApp/Platform/Clipboard/MacClipboardWatcher.swift"
  "${repo_root}/Sources/SuperboardMacApp/Platform/Positioning/FocusedContextLocator.swift"
  "${repo_root}/Sources/SuperboardMacApp/Platform/Paste/MacPasteExecutor.swift"
  "${repo_root}/Sources/SuperboardMacApp/Picker/PastePickerView.swift"
  "${repo_root}/Sources/SuperboardMacApp/Picker/PastePickerPanelController.swift"
)

echo "[dev-build] Typecheck SuperboardCore..."
xcrun swiftc \
  -parse-as-library \
  -target "${target_triple}" \
  -module-cache-path "${module_cache_dir}" \
  -typecheck \
  "${core_sources[@]}"

echo "[dev-build] Build SuperboardCore module..."
(
  cd "${tmp_dir}"
  xcrun swiftc \
    -parse-as-library \
    -target "${target_triple}" \
    -module-cache-path "${module_cache_dir}" \
    -module-name SuperboardCore \
    -emit-module \
    -emit-module-path "${tmp_dir}/SuperboardCore.swiftmodule" \
    -c \
    "${core_sources[@]}"
)

echo "[dev-build] Typecheck SuperboardMacApp..."
xcrun swiftc \
  -target "${target_triple}" \
  -module-cache-path "${module_cache_dir}" \
  -typecheck \
  -I "${tmp_dir}" \
  "${app_sources[@]}"

echo "[dev-build] Build SuperboardMacApp executable..."
(
  cd "${tmp_dir}"
  xcrun swiftc \
    -target "${target_triple}" \
    -module-cache-path "${module_cache_dir}" \
    -I "${tmp_dir}" \
    -c \
    "${app_sources[@]}"

  xcrun swiftc \
    -target "${target_triple}" \
    -module-cache-path "${module_cache_dir}" \
    -o "${out_dir}/SuperboardMacApp" \
    -framework AppKit \
    -framework ApplicationServices \
    -framework Carbon \
    ./*.o
)

echo "[dev-build] Output: ${out_dir}/SuperboardMacApp"
