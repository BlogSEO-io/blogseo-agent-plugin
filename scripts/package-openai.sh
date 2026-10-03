#!/usr/bin/env bash
# Builds the ZIP for the OpenAI plugin portal ("Upload new version").
# The portal identifies a plugin by the package name it assigned (app-...) and rejects any other manifest name,
# so the name is swapped in the packaged copy only. The MCP server is managed in the portal's MCPs tab, which is
# why mcp.json stays out of the archive.
set -euo pipefail

PACKAGE_NAME="${1:?usage: scripts/package-openai.sh <openai-package-name> [output.zip]}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="$(python3 -c 'import json, sys; print(json.load(open(sys.argv[1]))["version"])' "$ROOT/plugin.json")"
OUTPUT="${2:-$ROOT/dist/blogseo-openai-$VERSION.zip}"
STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT

cp -R "$ROOT/skills" "$ROOT/LICENSE" "$STAGE/"
python3 - "$ROOT/plugin.json" "$STAGE/plugin.json" "$PACKAGE_NAME" <<'PY'
import json
import sys

source, target, name = sys.argv[1:4]
with open(source) as manifest_file:
    manifest = json.load(manifest_file)
manifest["name"] = name
with open(target, "w") as manifest_file:
    json.dump(manifest, manifest_file, indent=4)
    manifest_file.write("\n")
PY
mkdir -p "$(dirname "$OUTPUT")"
rm -f "$OUTPUT"
(cd "$STAGE" && zip -q -r "$OUTPUT" plugin.json LICENSE skills -x '*.DS_Store')
echo "$OUTPUT"
