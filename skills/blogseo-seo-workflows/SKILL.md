---
name: blogseo-seo-workflows
description: Run SEO work end to end with the BlogSEO MCP server (keywords, content calendar, article writing and scoring, publishing to the CMS, rankings and backlinks). Use when the user asks for anything SEO on a website connected to BlogSEO, for example page-2 keywords, traffic drops, cannibalization, scheduling articles, fixing an article, or checking backlinks.
---

# BlogSEO SEO workflows

BlogSEO exposes 60 tools over MCP. You never have to name a tool to the user: pick them from what they ask.

## Ground rules

1. Call `get_account` first. It lists the websites the connection may use, their `website_id`, roles, credits and plan.
2. When the account has several websites, pass `website_id` on every call. Name the site in your answer.
3. Reading is free. Tools that spend AI brain credits say so in their description and, for data-changing actions (keyword research, AI rewrites, credit conversion), return the price and balance first: confirm with the user before calling again with `confirm: true`.
4. Editing a published article marks it Out of Sync until `sync_article_to_cms` or `publish_article` runs. Say so when you edit, and offer to sync.
5. Long actions (AI rewrites, competitor benchmarks) take one to three minutes. Prefer the background pair `run_advanced_seo_check` then `get_advanced_seo_report` when the client times out.

## Playbooks

**Page-2 keywords to page 1.** `get_keyword_rankings` filtered to positions 5 to 15 and at least 200 impressions, sorted by impressions. For each keyword report the ranking page, its CTR, and one on-page change. Apply the change with `update_article_content` only when the user agrees.

**Catch traffic loss.** `get_keyword_trends` comparing the last 28 days to the 28 before, rolled up by page. For the biggest losers, read the article with `get_article`, state the likely cause, propose one fix.

**Stop pages from competing.** `find_keyword_cannibalization`. For each pair, recommend consolidate or differentiate and which URL should win.

**Plan the calendar.** `list_scheduled_articles` for free slots, then `schedule_article` with the date, keyword, headline and brief. If the day is full for the site's publishing frequency, the tool answers with the next free date: ask before using it. `schedule_articles_for_keywords` fills several slots from the highest-opportunity keywords.

**Fix an underperforming article.** `check_article_seo_score` for the free score, `run_advanced_seo_check` to benchmark against the pages that rank for its keyword, then `improve_article_seo` (1 credit) to apply the recommendations, or edit the markdown yourself with `update_article_content`.

**Backlinks.** `get_backlinks_overview` for what the exchange placed and verified, `check_backlinks` (1 credit) for any domain's profile, `check_domain_rating` free for any domain.

**Agencies and several sites.** Loop over the websites from `get_account` and present one table. Portfolio prompts like "which client lost the most clicks this month" are `get_keyword_trends` per site.

## Scoring caveat

`check_seo_score` and `improve_content_seo` score pasted text against the keyword you pass. The article page in the dashboard scores against the article's registered target keyword, with its competitor benchmark. When the two numbers differ, that is why: say which keyword you scored.
