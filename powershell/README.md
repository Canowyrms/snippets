# PowerShell Snippets

## Find and remove empty directories

```powershell
(Get-ChildItem “D:\TV\” -r | Where-Object { $_.PSIsContainer -eq $True }) | Where-Object { $_.GetFileSystemInfos().Count -eq 0 } | remove-item
```



## Set Date Created and Date Modified properties from Date metadata tag

```powershell
$mp4Files = Get-ChildItem -Path . -Filter "*.mp4"

foreach ($file in $mp4Files) {
	Write-Host "Processing $($file.Name)"

	$date = & ffprobe -v quiet -print_format json -show_format $file.Name | jq -r '.format.tags.date'

	Write-Host "Metadata Date:     $date"
	Write-Host "Old Date Created:  $($file.CreationTime)"
	Write-Host "Old Date Modified: $($file.LastWriteTime)"

	$file.CreationTime  = $date
	$file.LastWriteTime = $date

	Write-Host "New Date Created:  $($file.CreationTime)"
	Write-Host "New Date Modified: $($file.LastWriteTime)"
	Write-Host ""
}
```



## Strip all \*.flac files in a directory (recursive) of the `description` and `comment` metadata tags

Requires [metaflac](https://xiph.org/flac/documentation_tools_metaflac.html).

```powershell
Get-ChildItem -Path "D:\Music\" -Recurse -Filter *.flac | ForEach-Object { metaflac --remove-tag="description" --remove-tag="Comment" "$($_.FullName)" }
```
