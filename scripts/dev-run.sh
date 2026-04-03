#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

"${repo_root}/scripts/dev-build.sh"

echo "[dev-run] Killing any existing SuperboardMacApp instances..."
killall SuperboardMacApp 2>/dev/null || true
killall Superboard 2>/dev/null || true
pkill -f "${repo_root}/.devbuild/SuperboardMacApp" 2>/dev/null || true
pkill -f "SuperboardMacApp" 2>/dev/null || true
sleep 1

echo "[dev-run] Launching menubar app..."
exec "${repo_root}/.devbuild/SuperboardMacApp"
