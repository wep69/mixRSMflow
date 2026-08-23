#!/usr/bin/env sh
set -eu
PKG="${1:-$(pwd)}"
command -v Rscript >/dev/null 2>&1 || { echo "Rscript not found" >&2; exit 1; }
Rscript "$PKG/inst/scripts/validate_local.R" "$PKG"
