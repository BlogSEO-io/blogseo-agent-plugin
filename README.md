# BlogSEO agent plugin

The [BlogSEO](https://www.blogseo.io) MCP server packaged as an [Agent Plugin](https://agent-plugins.org): one folder that Cursor, Claude Code, Codex CLI and any other conformant client can load. It connects the assistant to `https://mcp.blogseo.io/mcp`, 60 tools to research keywords, plan the calendar, write, score and publish articles to your CMS, and build backlinks, and ships three skills that teach the assistant the workflows.

Sign-in is OAuth: the first tool call opens the BlogSEO consent page, where you choose which websites the assistant may use. No API key. A BlogSEO account with at least one website is required.

## Install

**Cursor.** Install from the [Cursor Directory](https://cursor.directory/plugins/blogseo), or open Customize in the sidebar, find BlogSEO in the marketplace and click Install. One-click server install without the plugin: [Add to Cursor](cursor://anysphere.cursor-deeplink/mcp/install?name=blogseo&config=eyJ1cmwiOiJodHRwczovL21jcC5ibG9nc2VvLmlvL21jcCJ9). For local testing, clone this repo into `~/.cursor/plugins/local`.

**Claude Code.**

```bash
claude plugin marketplace add BlogSEO-io/blogseo-agent-plugin
claude plugin install blogseo@blogseo
```

**Any Agent Plugins client.** Point it at a clone of this repository.

**Without a plugin.** Add the server URL to your client directly: `https://mcp.blogseo.io/mcp`. The [setup guide](https://www.blogseo.io/docs/integrations/mcp) covers every client.

## What is inside

| Path | Purpose |
| --- | --- |
| `plugin.json` | Agent Plugins manifest |
| `mcp.json` | The BlogSEO remote MCP server (Streamable HTTP) |
| `skills/blogseo-seo-workflows` | Playbooks for keywords, calendar, articles, scores, backlinks and multi-site accounts |
| `skills/blogseo-plug-website` | Connecting a custom-built site: hosted blog or custom webhook |
| `skills/blogseo-article-images` | Replacing images from local files or URLs, alt text |
| `.cursor-plugin/`, `.claude-plugin/`, `.mcp.json` | Client-specific manifests for Cursor and Claude Code |

## Links

- [SEO MCP landing page](https://www.blogseo.io/seo-mcp)
- [Documentation](https://www.blogseo.io/docs/integrations/mcp)
- Support: support@blogseo.io
