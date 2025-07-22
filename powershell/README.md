# PowerShell Snippets

## Find and remove empty directories

```powershell
(Get-ChildItem “D:\TV\” -r | Where-Object { $_.PSIsContainer -eq $True }) | Where-Object { $_.GetFileSystemInfos().Count -eq 0 } | remove-item
```
