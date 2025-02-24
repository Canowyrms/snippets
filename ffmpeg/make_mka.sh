#!/bin/bash

# This script is intended to take a music video as input and output a *.mka file with
# all the same data, minus the video tracks.
#
# This script is intended to work with videos downloaded with yt-dlp. It requires
# an info.json file for metadata and a .jpg for embedding thumbnail.
#
# Can be called via:
# ./make_mka.sh "in.mkv"
#
# Can be called in a loop via:
# for file in *.mkv; do ./make_mka.sh "${file}"; done

echo "[make_mka.sh] Entering script. Incoming file name: \"${1}\""


# Setup variables...

in_mkv="${1}"
basename="${1%.mkv}"
infojson="${basename}.info.json"
thumb="${basename}.jpg"
out_mka="${basename}.mka"


# Run checks...

if [ ! -f "${thumb}" ]; then
	echo "[make_mka.sh] warn - Thumbnail does not exist (tried \"${thumb}\")."
	thumb="extra/${thumb}"
fi
if [ ! -f "${thumb}" ]; then
	echo "[make_mka.sh] ERROR! Thumbnail does not exist (tried \"${thumb}\"). Make sure to include --write-thumbnail or --skip-download in the yt-dlp command."
	exit 1
fi

if [ ! -f "${infojson}" ]; then
	echo "[make_mka.sh] warn - info.json does not exist (tried \"${infojson}\")."
	infojson="extra/${infojson}"
fi
if [ ! -f "${infojson}" ]; then
	echo "[make_mka.sh] ERROR! info.json does not exist (tried \"${infojson}\"). Make sure to include --write-info-json or --skip-download in the yt-dlp command."
	exit 1
fi


# Reassure...

#echo "[make_mka.sh] info.json file: \"${infojson}\""
#echo "[make_mka.sh] Thumbnail file: \"${thumb}\""
#echo "[make_mka.sh] Output file:    \"${out_mka}\""
echo "[make_mka.sh] infojson: \"${out_mka}\" | thumbnail: \"${thumb}\" | output: \"${out_mka}\""


# Collect metadata...

metadata_title=$(cat "${infojson}" | jq -r '.title')
metadata_description=$(cat "${infojson}" | jq -r '.description')
metadata_comment=$(cat "${infojson}" | jq -r '.webpage_url')
metadata_artist=$(cat "${infojson}" | jq -r '.channel')
metadata_date=$(cat "${infojson}" | jq -r '.meta_date')
metadata_year=$(cat "${infojson}" | jq -r '.meta_year')
metadata_purl=$(cat "${infojson}" | jq -r '.webpage_url')

#echo "${metadata_title}"
#echo "${metadata_description}"
#echo "${metadata_comment}"
#echo "${metadata_artist}"
#echo "${metadata_date}"
#echo "${metadata_year}"
#echo "${metadata_purl}"


# Build the output file...
# This assumes the *.mkv file contains a video stream and an audio stream and that both are good for reuse.
# Probably don't need all the metadata flags but better safe than sorry...

#echo "The command will be:"
#echo "ffmpeg -y -i \"${in_mkv}\" -ignore_unknown -map 0 -map -0:v -map -0:t -c copy -map_metadata 0 -attach \"${thumb}\" -metadata:s:t \"mimetype=image/jpeg\" -metadata:s:t \"filename=cover.jpg\" -metadata:g \"title=${metadata_title}\" -metadata:g \"description=${metadata_description}\" -metadata:g \"comment=${metadata_comment}\" -metadata:g \"artist=${metadata_artist}\" -metadata:g \"date=${metadata_date}\" -metadata:g \"year=${metadata_year}\" -metadata:g \"purl=${metadata_purl}\" -metadata:s:a \"filename=\" -metadata:s:a \"mimetype=\" -metadata:s:a \"title=\" -metadata:s:a \"description=\" -metadata:s:a \"comment=\" -metadata:s:a \"artist=\" -metadata:s:a \"date=\" -metadata:s:a \"year=\" -metadata:s:a \"purl=\" -movflags +faststart \"${out_mka}\";"

ffmpeg -y \
-i "${in_mkv}" \
-ignore_unknown \
-map 0 \
-map -0:v \
-map -0:t \
-c copy \
-map_metadata 0 \
-attach "${thumb}" \
-metadata:s:t "mimetype=image/jpeg" \
-metadata:s:t "filename=cover.jpg" \
-metadata:g "title=${metadata_title}" \
-metadata:g "description=${metadata_description}" \
-metadata:g "comment=${metadata_comment}" \
-metadata:g "artist=${metadata_artist}" \
-metadata:g "date=${metadata_date}" \
-metadata:g "year=${metadata_year}" \
-metadata:g "purl=${metadata_purl}" \
-metadata:s:a "filename=" \
-metadata:s:a "mimetype=" \
-metadata:s:a "title=" \
-metadata:s:a "description=" \
-metadata:s:a "comment=" \
-metadata:s:a "artist=" \
-metadata:s:a "date=" \
-metadata:s:a "year=" \
-metadata:s:a "purl=" \
-movflags +faststart \
"${out_mka}";
