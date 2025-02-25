# SCP Snippets

## Basic usage

Sometimes it's been a while and you just need a refresher on the basics...

```sh
scp "source" "destination"

# Local to Remote
scp path/to/local/file username@server:path/to/remote/file

# Remote to Local
scp username@server:path/to/remote/file path/to/local/file

# Remote to Local - Multiple Files
# 'phoenix' is an ssh alias
scp phoenix:/srv/log/fail2ban.log* .

# Remote to Remote
# -3 - ??? I forget what this does
scp -3 username@server:path/to/remote/file username@server:path/to/remote/file

# Local to Remote - Recursive Directory Copy
# -r - ???
# -p - ???
scp -rp sourcedirectory username@server:/path
```