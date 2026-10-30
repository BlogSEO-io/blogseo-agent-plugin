#!/usr/bin/env bash
# Builds the ZIP for the OpenAI plugin portal ("Upload new version").
# The package mirrors the release ZIP the portal generated for 1.0.0: a .codex-plugin/plugin.json manifest whose
# name is the package name the portal assigned (app-...), the listing under "interface", and the skills. Every
# upload rebuilds the listing from that manifest, so the listing fields live in extensions.com.openai.interface
# of the root plugin.json and are copied over here. The original package declared no MCP server (the portal holds
# that connection itself) and the portal refused a package that declared one while the MCP app was unpublished.
# WITH_MCP=1 declares it anyway, under MCP_SERVER_NAME. Review test cases and release notes come from the review and
# publication objects of extensions.com.openai and land under extensions.com.openai of the packaged manifest.
set -euo pipefail

PACKAGE_NAME="${1:?usage: scripts/package-openai.sh <openai-package-name> [output.zip]}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="$(python3 -c 'import json, sys; print(json.load(open(sys.argv[1]))["version"])' "$ROOT/plugin.json")"
OUTPUT="${2:-$ROOT/dist/blogseo-openai-$VERSION.zip}"
STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/.codex-plugin"
cp -R "$ROOT/skills" "$ROOT/assets" "$STAGE/"
python3 - "$ROOT/plugin.json" "$STAGE" "$PACKAGE_NAME" "${WITH_MCP:-0}" "${MCP_SERVER_NAME:-BlogSEO}" "$ROOT/mcp.json" <<'PY'
import json
import os
import sys

source, stage, name, with_mcp, server_name, mcp_source = sys.argv[1:7]
with open(source) as manifest_file:
    portable = json.load(manifest_file)
interface = portable["extensions"]["com.openai"]["interface"]
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
openai_settings = {
    key: portable["extensions"]["com.openai"][key]
    for key in ("review", "publication")
    if key in portable["extensions"]["com.openai"]
}
review = openai_settings.get("review", {})
test_cases = review.get("test_cases", {})
positive_cases = test_cases.get("positive", [])
negative_cases = test_cases.get("negative", [])
if review and (len(positive_cases) != 5 or len(negative_cases) != 3):
    problems.append(f"review needs exactly 5 positive and 3 negative test cases, has {len(positive_cases)} and {len(negative_cases)}")
for case in positive_cases:
    for field in ("description", "prompt", "tools_triggered", "expected_behavior"):
        if not case.get(field):
            problems.append(f"positive test case without {field}: {case.get('description', case)}")
for case in negative_cases:
    for field in ("description", "prompt"):
        if not case.get(field):
            problems.append(f"negative test case without {field}: {case.get('description', case)}")
for field in ("test_credentials", "reviewer_instructions"):
    if field in review:
        problems.append(f"review.{field} is rejected by the portal: enter it in the dashboard")
if review.get("demo_recording_url") and not review["demo_recording_url"].startswith("https://"):
    problems.append("review.demo_recording_url must be an HTTPS URL")
if problems:
    sys.exit("Listing metadata is not ready for the OpenAI portal:\n- " + "\n- ".join(problems))
manifest = {
    "author": {"name": interface["developerName"]},
    "description": interface["longDescription"],
    "interface": interface,
    "name": name,
    "skills": "./skills",
    "version": portable["version"],
}
if openai_settings:
    manifest["extensions"] = {"com.openai": openai_settings}
if with_mcp == "1":
    with open(mcp_source) as mcp_file:
        servers = json.load(mcp_file)["mcpServers"]
    url = next(iter(servers.values()))["url"]
    manifest["mcpServers"] = "./.mcp.json"
    with open(os.path.join(stage, ".mcp.json"), "w") as mcp_file:
        json.dump({"mcpServers": {server_name: {"url": url}}}, mcp_file, indent=2)
        mcp_file.write("\n")
with open(os.path.join(stage, ".codex-plugin", "plugin.json"), "w") as manifest_file:
    json.dump(manifest, manifest_file, indent=2, ensure_ascii=False, sort_keys=True)
    manifest_file.write("\n")
PY
mkdir -p "$(dirname "$OUTPUT")"
rm -f "$OUTPUT"
(cd "$STAGE" && zip -q -r "$OUTPUT" . -x '*.DS_Store')
echo "$OUTPUT"
