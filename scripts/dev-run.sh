#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

"${repo_root}/scripts/dev-build.sh"

echo "[dev-run] Launching menubar app..."
exec "${repo_root}/.devbuild/SuperboardMacApp"
