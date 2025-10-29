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
