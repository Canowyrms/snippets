# RegExp Snippets

## Negative lookahead with a capture group zero-indexed??

```regexp
^(?!(.*)=.*$).*$
```

Works on things like the following (scene group's encoder settings):

```log
cpuid=2
frame-threads=3
wpp
no-pmode
no-pme
no-psnr
no-ssim
```

It matches lines that do not have `=x` in them, so that `=1` can be appended to them via:

```regexp
$0=1
```

I have never seen regexp index from zero before but here we are. Documenting because this is a weird-as-hell regexp.



## Negative lookahead for non-wildcard attribute values

```regexp
property="(?!\*).+?"
```

Works on things like the following (Backblaze exclude rules aka XML):

```xml
<excludefname_rule plat="win" osVers="*"  ruleIsOptional="t" skipFirstCharThenStartsWith=":\ProgramData\Jellyfin" contains_1="*" contains_2="*" doesNotContain="jellyfin.db" endsWith="*" hasFileExtension="*" />
<excludefname_rule plat="win" osVers="*"  ruleIsOptional="t" skipFirstCharThenStartsWith=":\ProgramData\Jellyfin" contains_1="*" contains_2="*" doesNotContain="library.db" endsWith="*" hasFileExtension="*" />
<excludefname_rule plat="win" osVers="*"  ruleIsOptional="t" skipFirstCharThenStartsWith=":\ProgramData\Jellyfin" contains_1="*" contains_2="*" doesNotContain="library.db-shm" endsWith="*" hasFileExtension="*" />
<excludefname_rule plat="win" osVers="*"  ruleIsOptional="t" skipFirstCharThenStartsWith=":\ProgramData\Jellyfin" contains_1="*" contains_2="*" doesNotContain="library.db-wal" endsWith="*" hasFileExtension="*" />
```

Helps to uncover usage of specific, seldom-used properties.
