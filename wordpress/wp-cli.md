# WP-CLI Snippets

## Dump database with WP-CLI and mysqldump

> ⚠ TODO <br/>
> I forget why `--set-gtid-purged=OFF` and `--no-tablespaces` were necessary. Need to research and document.

```sh
mysqldump \
-h $(wp config get DB_HOST) \
-u $(wp config get DB_USER) \
-p$(wp config get DB_PASSWORD) \
$(wp config get DB_NAME) \
--set-gtid-purged=OFF \
--no-tablespaces \
> filename.sql
```



## Search-and-replace

The regexp `https?:(\/\/|\\\/\\\/)(www\.)?OLD\.TLD` should match four possible URL variations:
- `http://example.com`
- `http://www.example.com`
- `https://example.com`
- `https://www.example.com`

It should also match instances where the URL is stored with slashes escaped:
- `http:\/\/example.com`
- `http:\/\/www.example.com`
- `https:\/\/example.com`
- `https:\/\/www.example.com`

I forget where and why that happens but it's important to catch them, too.

> ℹ Note <br/>
> Need to refresh myself on the specifics of how these commands work/what to expect, their flags and implications, etc.
&nbsp;
> ⚠ TODO <br/>
> DO NOT JUST COPY PASTE THESE
> Confirm output templates are correct. Output templates are using match groups from the search regex.

```sh
# WWW to non-WWW
# --dry-run - Preview changes without committing.

wp search-replace "https?:(\/\/|\\\/\\\/)(www\.)?OLD\.TLD" "https:\1" \
--regex \
--all-tables-with-prefix \
--dry-run


# WWW to non-WWW
# --export - ??? Apply the search-and-replace results to a database export?

wp search-replace "https?:(\/\/|\\\/\\\/)(www\.)?OLD\.TLD" "https:\1" \
--regex \
--all-tables-with-prefix \
--export='newurl.tld_replaced_y-m-d.sql'


# WWW to non-WWW
# Runs against the DB specified in wp-config.php, committing changes in real-time.

wp search-replace "https?:(\/\/|\\\/\\\/)(www\.)?OLD\.TLD" "https:\1" \
--regex \
--all-tables-with-prefix \
--dry-run


# Maybe non-WWW to WWW on specific tables
# Commits changes in real-time; dry-run it or make a backup first...

wp search-replace "https?:(\/\/|\\\/\\\/)(www\.)?OLD\.TLD" "https:\1www.NEW.TLD" \
wp_posts wp_postmeta \
--regex \
--dry-run

#---

# Replace site path
# Runs against the DB specified in wp-config.php, committing changes in real-time.

wp search-replace "\/path\/to\/site" "/new/path/to/site" \
--regex \
--all-tables-with-prefix \
--dry-run
```
