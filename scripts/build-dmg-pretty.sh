#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
dist_dir="${repo_root}/dist"
app_name="Superboard"
dmg_path="${dist_dir}/${app_name}.dmg"
zip_path="${dist_dir}/${app_name}-macos.zip"
module_cache_dir="${repo_root}/.build/ModuleCache"
target_triple="arm64-apple-macosx14.0"

cd "${repo_root}"

mkdir -p "${dist_dir}"
mkdir -p "${module_cache_dir}"

echo "[build-dmg-pretty] Build .app bundle (via build-zip)..."
"${repo_root}/scripts/build-zip.sh" >/dev/null

if [[ ! -f "${zip_path}" ]]; then
  echo "[build-dmg-pretty] Missing zip: ${zip_path}" >&2
  exit 1
fi

tmp_dir="$(mktemp -d)"
trap 'rm -rf "${tmp_dir}"' EXIT

stage_dir="${tmp_dir}/${app_name}"
mkdir -p "${stage_dir}"

echo "[build-dmg-pretty] Stage app + Applications link..."
unzip -oq "${zip_path}" -d "${tmp_dir}"
app_bundle="${tmp_dir}/${app_name}.app"
if [[ ! -d "${app_bundle}" ]]; then
  echo "[build-dmg-pretty] Missing unzipped app bundle: ${app_bundle}" >&2
  exit 1
fi

cp -R "${app_bundle}" "${stage_dir}/"
ln -s "/Applications" "${stage_dir}/Applications"

echo "[build-dmg-pretty] Prepare volume icon (same as app icon)..."
app_icon_icns="${tmp_dir}/AppIcon.icns"
unzip -p "${zip_path}" "Superboard.app/Contents/Resources/AppIcon.icns" >"${app_icon_icns}" 2>/dev/null || true
if [[ ! -f "${app_icon_icns}" ]]; then
  echo "[build-dmg-pretty] WARNING: AppIcon.icns not found in zip; volume icon will be default." >&2
fi

raw_dmg="${tmp_dir}/${app_name}-raw.dmg"
rw_dmg="${tmp_dir}/${app_name}-rw.dmg"

echo "[build-dmg-pretty] Create raw DMG (hybrid)..."
hdiutil makehybrid \
  -o "${raw_dmg}" \
  "${stage_dir}" \
  -hfs \
  -hfs-volume-name "${app_name}" \
  -ov >/dev/null

echo "[build-dmg-pretty] Convert raw DMG to writable..."
hdiutil convert "${raw_dmg}" -format UDRW -o "${rw_dmg}" >/dev/null

echo "[build-dmg-pretty] Resize writable DMG (space for .DS_Store)..."
hdiutil resize -size +20m "${rw_dmg}" >/dev/null 2>&1 || hdiutil resize -size 64m "${rw_dmg}" >/dev/null 2>&1 || true

echo "[build-dmg-pretty] Detach any existing mounted volumes..."
for mp in /Volumes/"${app_name}"*; do
  [[ -d "${mp}" ]] || continue
  dev_slice="$(mount | awk -v mp="${mp}" 'index($0, " on " mp " (") { print $1; exit }' || true)"
  [[ -n "${dev_slice}" ]] || continue
  hdiutil detach "${dev_slice%s*}" >/dev/null 2>&1 || true
done

echo "[build-dmg-pretty] Mount writable DMG..."
attach_out="$(hdiutil attach "${rw_dmg}" -readwrite -noverify -noautoopen 2>/dev/null)"
mount_point="$(echo "${attach_out}" | awk -F $'\t' '/\/Volumes\//{print $NF}' | tail -1)"
new_volume_name="$(basename "${mount_point}")"
device="$(echo "${attach_out}" | awk '/^\/dev\//{print $1; exit}')"
device="${device%s*}"

if [[ -z "${mount_point}" || ! -d "${mount_point}" || -z "${device}" ]]; then
  echo "[build-dmg-pretty] ERROR: failed to mount DMG." >&2
  echo "${attach_out}" >&2
  exit 1
fi

# Verify writable mount (we need Finder to write .DS_Store into the image).
if ! (echo "test" >"${mount_point}/.superboard_write_test" 2>/dev/null); then
  echo "[build-dmg-pretty] ERROR: DMG did not mount writable: ${mount_point}" >&2
  hdiutil detach "${device}" -force >/dev/null 2>&1 || true
  exit 1
fi
rm -f "${mount_point}/.superboard_write_test" 2>/dev/null || true

if [[ -f "${app_icon_icns}" ]]; then
  echo "[build-dmg-pretty] Apply volume icon..."
  cp -f "${app_icon_icns}" "${mount_point}/.VolumeIcon.icns" 2>/dev/null || true
  if command -v SetFile >/dev/null 2>&1; then
    SetFile -a C "${mount_point}" >/dev/null 2>&1 || true
  fi
fi

bg_gen_bin="${tmp_dir}/generate-dmg-background"
echo "[build-dmg-pretty] Generate DMG background (png with arrow)..."
CLANG_MODULE_CACHE_PATH="${module_cache_dir}" \
  xcrun swiftc \
  -target "${target_triple}" \
  -module-cache-path "${module_cache_dir}" \
  -o "${bg_gen_bin}" \
  "${repo_root}/scripts/generate-dmg-background.swift"

mkdir -p "${mount_point}/.background" >/dev/null 2>&1 || true
bg_png="${mount_point}/.background/background.png"
# Slightly larger than the original (about +15%) to avoid excessive whitespace.
CLANG_MODULE_CACHE_PATH="${module_cache_dir}" "${bg_gen_bin}" "${bg_png}" 708 455

echo "[build-dmg-pretty] Customize Finder window (on mounted DMG)..."
osascript <<OSA
tell application "Finder"
  tell disk "${new_volume_name}"
    open
    delay 0.8
    set theWindow to container window
    set current view of theWindow to icon view
    set toolbar visible of theWindow to false
    set statusbar visible of theWindow to false
    set bounds of theWindow to {200, 200, 900, 670}
    delay 0.4

    set viewOptions to the icon view options of theWindow
    set arrangement of viewOptions to not arranged
    set icon size of viewOptions to 88
    set background picture of viewOptions to file ".background:background.png"

    set position of item "${app_name}.app" to {225, 260}
    set position of item "Applications" to {505, 260}

    delay 1.6
    close theWindow
  end tell
end tell
OSA

echo "[build-dmg-pretty] Hide DMG decoration files..."
if command -v SetFile >/dev/null 2>&1; then
  SetFile -a V "${mount_point}/.background" >/dev/null 2>&1 || true
else
  chflags hidden "${mount_point}/.background" >/dev/null 2>&1 || true
fi
chflags hidden "${mount_point}/.VolumeIcon.icns" >/dev/null 2>&1 || true
rm -rf "${mount_point}/.fseventsd" >/dev/null 2>&1 || true

echo "[build-dmg-pretty] Wait for Finder to write .DS_Store..."
for _ in {1..30}; do
  [[ -f "${mount_point}/.DS_Store" ]] && break
  sleep 0.2
done
sync >/dev/null 2>&1 || true

if [[ ! -f "${mount_point}/.DS_Store" ]]; then
  echo "[build-dmg-pretty] ERROR: Finder did not write .DS_Store (layout won't persist)." >&2
fi

echo "[build-dmg-pretty] Unmount DMG..."
osascript -e "tell application \"Finder\" to try" -e "eject disk \"${new_volume_name}\"" -e "end try" >/dev/null 2>&1 || true
for _ in {1..20}; do
  if hdiutil detach "${device}" >/dev/null 2>&1; then
    break
  fi
  hdiutil detach "${device}" -force >/dev/null 2>&1 || true
  sleep 0.5
done

for _ in {1..20}; do
  hdiutil info 2>/dev/null | grep -F "${rw_dmg}" >/dev/null 2>&1 || break
  sleep 0.5
done

echo "[build-dmg-pretty] Convert to compressed DMG..."
out_tmp="${tmp_dir}/${app_name}-udzo.dmg"
sleep 1.0
for _ in {1..20}; do
  if hdiutil convert "${rw_dmg}" -format UDZO -o "${out_tmp}" -ov >/dev/null 2>&1; then
    break
  fi
  # Wait for DiskImages to release the writable image after detach.
  hdiutil info 2>/dev/null | grep -F "${rw_dmg}" >/dev/null 2>&1 || true
  sleep 0.6
done

if [[ ! -f "${out_tmp}" ]]; then
  echo "[build-dmg-pretty] ERROR: failed to convert DMG (resource busy)." >&2
  exit 1
fi

cp -f "${out_tmp}" "${dmg_path}"

echo "[build-dmg-pretty] Output: ${dmg_path}"
