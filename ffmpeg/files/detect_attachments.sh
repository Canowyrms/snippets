#!/bin/bash

# Sometimes yt-dlp attaches info.json when I don't want/need it to.
# Sometimes yt-dlp attaches thumbnails in webp format when I don't want it to.
# This script simply checks if a given input file contains either.
#
# Each method of gathering files (i.e. `for file ...` and `find . ...`) has its strengths and weaknesses.
# I find `for file ...` is more reliable, especially with funky path/file names, but isn't as convenient for traversing nested directories.
# I find `find . ...` is more convenient for traversing nested directories, but isn't as reliable, especially with funky path/file names.

#for file in **/*/*.mk*; do
find . -type f -name "*.mk*" -print0 | while IFS= read -r -d '' file; do
	#echo "🔎 checking ${file}"

	if ffprobe -v quiet -print_format json -show_streams "${file}" | jq -e '.streams[] | select(.codec_type == "attachment" and .tags.mimetype == "application/json")' > /dev/null; then
		echo "📄 infojson ${file}"
	fi
	if ffprobe -v quiet -print_format json -show_streams "${file}" | jq -e '.streams[] | select(.codec_type == "attachment" and .tags.mimetype == "image/webp")' > /dev/null; then
		echo "🖼  webp     ${file}"
	fi
done
