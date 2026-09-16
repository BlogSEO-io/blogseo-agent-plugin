---
name: blogseo-plug-website
description: Connect the website in the current codebase to BlogSEO so generated articles get published on it, either as a hosted blog on a subdomain (one DNS record) or through a custom webhook wired into the codebase. Use when the user says plug, connect or integrate this site with BlogSEO, or asks how BlogSEO can publish to a custom-built site.
---

# Plug a custom-built website into BlogSEO

Sites built by hand (Next.js, Astro, Rails, anything without a supported CMS) have two ways to receive BlogSEO articles. Offer both with their trade-offs, ask which one the user wants, then set it up with the tools.

## Steps

1. `get_account`, then `get_website_setup_guide` for the website. The guide is the source of truth for both options and their current limits; follow it rather than this file when they disagree.
2. **Hosted blog on a subdomain** (no code): `create_hosted_blog` returns the DNS records to add. Tell the user exactly which records, then poll `get_hosted_blog_status` until it reports live. Note that the hosted blog is a CMS integration, so it cannot coexist with WordPress, Shopify or another CMS on the same website.
3. **Custom webhook into the codebase**: `get_webhook_contract` returns the payload BlogSEO sends and the signature scheme. Write the receiving endpoint in the user's stack, persist the article, then `connect_custom_webhook`. The shared secret is returned once: put it in the deployment's environment variables, never in the repo. Finish with `test_custom_webhook` and show the user the test payload landing.
4. Both paths end with auto-publish on. Confirm with `list_integrations` and tell the user the next generated article will be published automatically.

## When something fails

- Webhook test returns a non-2xx: read the endpoint's logs, fix, rerun `test_custom_webhook`.
- Endpoint answers 200 but nothing is stored: the payload has fields longer than the user's schema allows (alt texts can exceed 255 characters); relax the schema.
- Hosted blog stays pending: DNS propagation. Show the records again and check them with `dig`.
