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
