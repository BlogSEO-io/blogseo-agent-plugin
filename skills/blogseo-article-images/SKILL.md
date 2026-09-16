---
name: blogseo-article-images
description: Change the cover image or inline images of a BlogSEO article from a local file or a URL, and set the cover alt text. Use when the user wants to replace, upload or describe an article image through BlogSEO.
---

# Article images with BlogSEO

Two image tools accept either a public `image_url` or an `upload_id` for a file on the user's machine.

## Local file (Claude Code, Cursor, Codex, any client with a shell)

1. `create_image_upload` with the file name and MIME type. It returns an `upload_id`, an `upload_url` valid for 2 hours, and a ready-to-run command.
2. Run the command from the shell, substituting the file's real path:

```bash
curl -sS -f -X PUT -H "Content-Type: image/jpeg" --data-binary @"cover.jpg" "<upload_url>"
```

   A non-zero exit means the file was refused: larger than 10 MB or not an image (JPEG, PNG, WebP, GIF, AVIF).
3. `set_article_cover_image` with the `upload_id` and an `alt_text` describing the image, or `upload_article_image` to host an inline image and get its URL for the markdown.

Uploaded files are deleted the moment they are used, and after 6 hours if they are not. At most 10 unused uploads per connection.

## Public URL

Pass `image_url` directly to the same tools, 4 MB max.

## Alt text

- Cover: `update_article_cover_alt_text`, or `alt_text` on `set_article_cover_image`. Stored once per article and shared by every language.
- Inline images: the alt lives in the markdown as `![alt](url)`; edit the body with `update_article_content`.

Replacing images on a published article marks it Out of Sync: offer `sync_article_to_cms`.
