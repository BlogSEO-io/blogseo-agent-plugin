#!/usr/bin/env bash
# Builds the ZIP for the OpenAI plugin portal ("Upload new version").
# The portal identifies a plugin by the package name it assigned (app-...) and rejects any other manifest name,
# so the name is swapped in the packaged copy only. Every upload rebuilds the listing from
# extensions.com.openai.interface in plugin.json. mcp.json stays out by default: while the plugin's MCP app is
# unpublished the portal refuses a package that declares the server again ("Keep the existing MCP connection").
# Set WITH_MCP=1 to include it.
set -euo pipefail

PACKAGE_NAME="${1:?usage: scripts/package-openai.sh <openai-package-name> [output.zip]}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="$(python3 -c 'import json, sys; print(json.load(open(sys.argv[1]))["version"])' "$ROOT/plugin.json")"
OUTPUT="${2:-$ROOT/dist/blogseo-openai-$VERSION.zip}"
STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT

cp -R "$ROOT/skills" "$ROOT/assets" "$ROOT/LICENSE" "$STAGE/"
if [ "${WITH_MCP:-0}" = "1" ]; then cp "$ROOT/mcp.json" "$STAGE/"; fi
python3 - "$ROOT/plugin.json" "$STAGE/plugin.json" "$PACKAGE_NAME" "$STAGE" <<'PY'
import json
import os
import sys

source, target, name, stage = sys.argv[1:5]
with open(source) as manifest_file:
    manifest = json.load(manifest_file)
manifest["name"] = name
interface = manifest["extensions"]["com.openai"]["interface"]
problems = []
for field, limit in (("displayName", 30), ("shortDescription", 30), ("longDescription", 4000), ("developerName", 80)):
    if not 0 < len(interface.get(field, "")) <= limit:
        problems.append(f"{field} must have 1 to {limit} characters, has {len(interface.get(field, ''))}")
for field in ("websiteURL", "supportURL", "privacyPolicyURL", "termsOfServiceURL"):
    if not interface.get(field, "").startswith("https://"):
        problems.append(f"{field} must be an HTTPS URL")
prompts = interface.get("defaultPrompt", [])
if len(prompts) > 3 or len(set(prompts)) != len(prompts):
    problems.append("defaultPrompt takes at most three unique prompts")
for prompt in prompts:
    if len(prompt) > 128:
        problems.append(f"prompt over 128 characters ({len(prompt)}): {prompt}")
for field in ("logo", "composerIcon"):
    if not os.path.isfile(os.path.join(stage, interface.get(field, "missing"))):
        problems.append(f"{field} points at a file that is not in the package: {interface.get(field)}")
if problems:
    sys.exit("Listing metadata is not ready for the OpenAI portal:\n- " + "\n- ".join(problems))
with open(target, "w") as manifest_file:
    json.dump(manifest, manifest_file, indent=4, ensure_ascii=False)
    manifest_file.write("\n")
PY
mkdir -p "$(dirname "$OUTPUT")"
rm -f "$OUTPUT"
(cd "$STAGE" && zip -q -r "$OUTPUT" . -x '*.DS_Store')
echo "$OUTPUT"
