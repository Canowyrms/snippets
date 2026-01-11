# Scoop Snippets

## Enable sqlite cache

This should honestly be the default. `scoop search` and `scoop shim` are significantly faster with this enabled:

```powershell
scoop config use_sqlite_cache true
```



## Going beyond basic executables with shims

Scoop shims are flexible - you can create shims to run custom commands - kind of like bash aliases, but shell-agnostic.

For example, you can create a shim of PHP calling a `*.phar` file:

```powershell
scoop shim add pie "php" "path\to\pie.phar"
```

You can shim PowerShell scripts, and as far as I can tell, you don't need to call `pwsh`:

```powershell
scoop shim add "psysh" "path\to\psysh.ps1"
```

Scoop's docs cover this but you can also pass flags into a shim, so long as they're after the first `"--"`. For example:

```powershell
scoop shim add "bash" "C:\Program Files\Git\bin\bash.exe" "--" "-l -i"
```