#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
dist_dir="${repo_root}/dist"
app_name="Superboard"
dmg_path="${dist_dir}/${app_name}.dmg"
zip_path="${dist_dir}/${app_name}-macos.zip"

cd "${repo_root}"

# Ensure the .app bundle exists (also rebuilds the binary).
"${repo_root}/scripts/build-zip.sh" >/dev/null

if [[ ! -f "${zip_path}" ]]; then
  echo "[build-dmg] Missing zip: ${zip_path}" >&2
  exit 1
fi

tmp_dir="$(mktemp -d)"
trap 'rm -rf "${tmp_dir}"' EXIT

stage_dir="${tmp_dir}/${app_name}"
mkdir -p "${stage_dir}"

echo "[build-dmg] Unzip app bundle..."
unzip -oq "${zip_path}" -d "${tmp_dir}"
app_bundle="${tmp_dir}/${app_name}.app"
if [[ ! -d "${app_bundle}" ]]; then
  echo "[build-dmg] Missing unzipped app bundle: ${app_bundle}" >&2
  exit 1
fi

echo "[build-dmg] Staging app..."
rm -rf "${stage_dir}/${app_name}.app"
cp -R "${app_bundle}" "${stage_dir}/"

if [[ ! -e "${stage_dir}/Applications" ]]; then
  ln -s "/Applications" "${stage_dir}/Applications"
fi

rm -f "${dmg_path}"
echo "[build-dmg] Creating DMG (hybrid -> UDZO)..."
raw_dmg="${tmp_dir}/${app_name}-raw.dmg"

hdiutil makehybrid \
  -o "${raw_dmg}" \
  "${stage_dir}" \
  -hfs \
  -hfs-volume-name "${app_name}" \
  -ov >/dev/null

hdiutil convert \
  "${raw_dmg}" \
  -format UDZO \
  -o "${dmg_path}" >/dev/null

echo "[build-dmg] Output: ${dmg_path}"
