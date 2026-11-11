#!/bin/bash
set -euo pipefail
project_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$project_root"
godot_bin="${GODOT_BIN:-/Applications/Godot.app/Contents/MacOS/Godot}"
mkdir -p .build docs
if [ ! -f .build/web_nothreads_release.zip ] || [ ! -f .build/web_nothreads_debug.zip ]; then
  godot_version="$("$godot_bin" --version | cut -d. -f1-3)"
  curl -L --fail --retry 2 "https://github.com/godotengine/godot-builds/releases/download/${godot_version}-stable/Godot_v${godot_version}-stable_export_templates.tpz" -o .build/templates.tpz
  unzip -o -j .build/templates.tpz 'templates/web_nothreads_debug.zip' 'templates/web_nothreads_release.zip' -d .build
fi
"$godot_bin" --headless --path . --editor --import --quit
"$godot_bin" --headless --path . --export-release Web docs/index.html
touch docs/.nojekyll
