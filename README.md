# BlogSEO MCP server and agent plugin

[BlogSEO](https://www.blogseo.io) plans, writes and publishes SEO content for your website. Its remote MCP server lets an AI assistant do that work on your account: research keywords, read Google Search Console rankings, plan the content calendar, write and edit articles, score them against competitors, publish to your CMS and follow your backlinks.

- **Server URL:** `https://mcp.blogseo.io/mcp` (Streamable HTTP)
- **Authentication:** OAuth 2.1, no API key. The first connection opens the BlogSEO consent page, where you choose which websites the assistant may use.
- **Requirement:** a BlogSEO account with at least one website.

This repository also packages the server as an [Agent Plugin](https://agent-plugins.org) with three skills, and holds the client manifests for Cursor and Claude Code.

## What the server does

60 tools, grouped by job:

| Area | What the assistant can do |
| --- | --- |
| Keywords | List tracked keywords with volume, difficulty and Search Console positions, research new ones from seed keywords, refresh metrics, expand topic clusters, find cannibalization, compare rankings between two periods |
| Content calendar | Read the schedule, add articles with a brief and a target keyword, reschedule, edit or remove pending articles, suggest headlines |
| Articles | List and read articles, update the headline, slug, meta description, cover image and alt text, edit content with AI, publish or sync to the connected CMS |
| SEO checks | On-page SEO score for an article or pasted content, competitor benchmark, AI improvements, keyword density of any page |
| Backlinks | Links placed through the BlogSEO exchange, Domain Rating and backlink profile of any domain |
| Integrations | List connections, connect and test a custom webhook, set up a hosted blog, read the setup guides |
| Account | Websites the connection may use, credit balances, plan and website settings |

Reading data is free. Tools that spend credits (keyword research, AI edits, competitor benchmarks) answer with the cost first and only run after an explicit confirmation. Destructive tools are annotated, so the client asks before running them. Tokens, payment data and integration credentials are never returned.

## Configure

**VS Code and GitHub Copilot.** Add the server to `.vscode/mcp.json` in your workspace, or to your user MCP configuration:

```json
{
    "servers": {
        "blogseo": {
            "type": "http",
            "url": "https://mcp.blogseo.io/mcp"
        }
    }
}
```

Or from a terminal:

```bash
code --add-mcp '{"name":"blogseo","type":"http","url":"https://mcp.blogseo.io/mcp"}'
```

Start the server from the MCP view, sign in to BlogSEO in the browser window that opens, choose the websites and approve. The tools are then available to Copilot Chat in agent mode.

**Cursor.** Install from the [Cursor Directory](https://cursor.directory/plugins/blogseo), or open Customize in the sidebar, find BlogSEO in the marketplace and click Install. One-click server install without the plugin: [Add to Cursor](cursor://anysphere.cursor-deeplink/mcp/install?name=blogseo&config=eyJ1cmwiOiJodHRwczovL21jcC5ibG9nc2VvLmlvL21jcCJ9). For local testing, clone this repo into `~/.cursor/plugins/local`.

**Claude Code.**

```bash
claude plugin marketplace add BlogSEO-io/blogseo-agent-plugin
claude plugin install blogseo@blogseo
```

**Claude, ChatGPT and any other client.** Add `https://mcp.blogseo.io/mcp` as a remote MCP server or custom connector. The [setup guide](https://www.blogseo.io/docs/integrations/mcp) covers every client. Any Agent Plugins client can also load a clone of this repository.

**Access.** On the consent page you grant all the websites you administer or only some of them. Websites where you are a plain member are never available. Revoke a connection at any time under Settings > Security in the BlogSEO app.

## Use

Ask in plain language and the assistant picks the tools:

- "Show my keywords ranking between position 5 and 15 with the most impressions, and what to change on each page to reach page 1."
- "Compare my search clicks over the last 28 days with the 28 days before. Which pages lost traffic and why?"
- "Schedule an article for next Monday targeting 'cold email deliverability' and brief it to compare Gmail and Outlook filtering."
- "Score my latest article, apply the top three fixes and sync it to my CMS."
- "Which of my articles compete for the same keyword?"

With several websites on the account, name the website in the prompt or let the assistant ask which one.

## What is inside

| Path | Purpose |
| --- | --- |
| `plugin.json` | Agent Plugins manifest |
| `mcp.json` | The BlogSEO remote MCP server (Streamable HTTP) |
| `skills/blogseo-seo-workflows` | Playbooks for keywords, calendar, articles, scores, backlinks and multi-site accounts |
| `skills/blogseo-plug-website` | Connecting a custom-built site: hosted blog or custom webhook |
| `skills/blogseo-article-images` | Replacing images from local files or URLs, alt text |
| `.cursor-plugin/`, `.claude-plugin/`, `.mcp.json` | Client-specific manifests for Cursor and Claude Code |
| `assets/logo.png`, `assets/icon.png` | Listing logo with the wordmark, and the mark alone for small sizes |
| `scripts/package-openai.sh` | Builds the ZIP for the OpenAI plugin portal, whose listing is read from `extensions.com.openai` in `plugin.json` |

## Links

- [SEO MCP landing page](https://www.blogseo.io/seo-mcp)
- [Documentation](https://www.blogseo.io/docs/integrations/mcp)
- Support: support@blogseo.io
