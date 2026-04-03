#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
dist_dir="${repo_root}/dist"
app_name="Superboard"
bundle_path="${dist_dir}/${app_name}.app"
module_cache_dir="${repo_root}/.build/ModuleCache"
target_triple="arm64-apple-macosx14.0"

cd "${repo_root}"

"${repo_root}/scripts/dev-build.sh"

mkdir -p "${module_cache_dir}"

tmp_dir="$(mktemp -d)"
trap 'rm -rf "${tmp_dir}"' EXIT
bundle_path_tmp="${tmp_dir}/${app_name}.app"

rm -rf "${bundle_path_tmp}"
mkdir -p "${bundle_path_tmp}/Contents/MacOS"
mkdir -p "${bundle_path_tmp}/Contents/Resources"

git_sha="$(git rev-parse --short HEAD 2>/dev/null || echo "dev")"
bundle_id="com.superboard.macos"
version="0.1.0"
build="git-${git_sha}"

icon_icns="${tmp_dir}/AppIcon.icns"
icon_png="${tmp_dir}/AppIcon-1024.png"
iconset_dir="${tmp_dir}/AppIcon.iconset"

echo "[build-zip] Generate app icon..."
rm -f "${icon_icns}" "${icon_png}"
rm -rf "${iconset_dir}"

# Render a 1024px base PNG (A1 + 3: minimal deck, slight tilt).
icon_gen_bin="${tmp_dir}/generate-app-icon"
CLANG_MODULE_CACHE_PATH="${module_cache_dir}" \
  xcrun swiftc \
  -target "${target_triple}" \
  -module-cache-path "${module_cache_dir}" \
  -o "${icon_gen_bin}" \
  "${repo_root}/scripts/generate-app-icon.swift"

CLANG_MODULE_CACHE_PATH="${module_cache_dir}" "${icon_gen_bin}" "${icon_png}" 1024

mkdir -p "${iconset_dir}"
cp -f "${icon_png}" "${iconset_dir}/icon_512x512@2x.png"
sips -z 512 512 "${icon_png}" --out "${iconset_dir}/icon_512x512.png" >/dev/null
sips -z 512 512 "${icon_png}" --out "${iconset_dir}/icon_256x256@2x.png" >/dev/null
sips -z 256 256 "${icon_png}" --out "${iconset_dir}/icon_256x256.png" >/dev/null
sips -z 256 256 "${icon_png}" --out "${iconset_dir}/icon_128x128@2x.png" >/dev/null
sips -z 128 128 "${icon_png}" --out "${iconset_dir}/icon_128x128.png" >/dev/null
sips -z 64 64 "${icon_png}" --out "${iconset_dir}/icon_32x32@2x.png" >/dev/null
sips -z 32 32 "${icon_png}" --out "${iconset_dir}/icon_32x32.png" >/dev/null
sips -z 32 32 "${icon_png}" --out "${iconset_dir}/icon_16x16@2x.png" >/dev/null
sips -z 16 16 "${icon_png}" --out "${iconset_dir}/icon_16x16.png" >/dev/null

if iconutil -c icns "${iconset_dir}" -o "${icon_icns}"; then
  :
else
  echo "[build-zip] iconutil failed; reusing previous AppIcon.icns if available..."
  rm -f "${icon_icns}"
  if [[ -f "${dist_dir}/Superboard.zip" ]]; then
    unzip -p "${dist_dir}/Superboard.zip" "Superboard.app/Contents/Resources/AppIcon.icns" >"${icon_icns}" 2>/dev/null || true
  fi
  if [[ ! -f "${icon_icns}" ]]; then
    echo "[build-zip] WARNING: could not generate AppIcon.icns; the app will use a default icon."
  fi
fi

cat >"${bundle_path_tmp}/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key>
  <string>en</string>
  <key>CFBundleExecutable</key>
  <string>${app_name}</string>
  <key>CFBundleIconFile</key>
  <string>AppIcon</string>
  <key>CFBundleIdentifier</key>
  <string>${bundle_id}</string>
  <key>CFBundleInfoDictionaryVersion</key>
  <string>6.0</string>
  <key>CFBundleName</key>
  <string>${app_name}</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>${version}</string>
  <key>CFBundleVersion</key>
  <string>${build}</string>
  <key>LSUIElement</key>
  <true/>
  <key>NSHighResolutionCapable</key>
  <true/>
</dict>
</plist>
PLIST

cp -f "${repo_root}/.devbuild/SuperboardMacApp" "${bundle_path_tmp}/Contents/MacOS/${app_name}"
chmod +x "${bundle_path_tmp}/Contents/MacOS/${app_name}"
if [[ -f "${icon_icns}" ]]; then
  cp -f "${icon_icns}" "${bundle_path_tmp}/Contents/Resources/AppIcon.icns"
fi

# Ad-hoc sign so the app bundle is structurally code-signed (not notarized).
if command -v codesign >/dev/null 2>&1; then
  codesign --force --deep --sign - "${bundle_path_tmp}" >/dev/null 2>&1 || true
fi

mkdir -p "${dist_dir}"
zip_path="${dist_dir}/${app_name}-macos.zip"
rm -f "${zip_path}"

# Use ditto for a Finder-friendly zip that preserves bundle structure.
ditto -c -k --sequesterRsrc --keepParent "${bundle_path_tmp}" "${zip_path}"

echo "[build-zip] Output: ${zip_path}"

# Best-effort: keep a .app in dist for convenience.
if rm -rf "${bundle_path}" 2>/dev/null; then
  cp -R "${bundle_path_tmp}" "${bundle_path}" 2>/dev/null || true
else
  echo "[build-zip] Note: could not replace ${bundle_path} (permissions). Zip output is unaffected."
fi
