# FFmpeg Snippets

FFmpeg and FFmpeg-adjacent snippets.


## List available codecs

```sh
ffmpeg -codecs | rg nvenc
```



## List available filters

```sh
ffmpeg -filters | rg scale
```



## Extract audio tracks to Matroska audio container

```sh
ffmpeg \
-i "in.mkv" \
-map 0:a:0 \
-map 0:a:2 \
-map 0:a:4 \
-c copy \
-map_metadata 0 \
-movflags +faststart
"out.mka"
```

- `-map 0:a:0` <br/> first input, first audio track (OBS combined audio)
- `-map 0:a:2` <br/> first input, third audio track (OBS mic audio)
- `-map 0:a:4` <br/> first input, fifth audio track (OBS discord audio)
- `-c copy` <br/> do not re-encode
- `-map_metadata 0` <br/> use applicable metadata from first input



## Batch audio extraction (for batch audio transcription)

```sh
for file in *.mkv; do \
ffmpeg \
-i "${file}" \
-map 0:a:0 \
-c:a copy \
-map_metadata 0 \
-movflags +faststart
"temp/${file}"; \
done
```

- `-map 0:a:0` <br/> first input, first audio track (combined audio)



## Remux D&D recording for reshare

### 1. Generate transcription

```sh
whisper "recording.mkv" \
--device cuda \
--task transcribe \
--language English
```

### 2. Mux output

Combines recorded audio, transcribed subtitles, and generated black-frame video into single output.

```sh
ffmpeg \
-i "recording.mkv" \
-i "subtitles.srt" \
-f lavfi -i color=c=black:s=720x480:r=1 -shortest \
-map 2:v:0 \
-map 0:a:0 \
-map 1:s:0 \
-c:a copy \
-c:s copy \
-map_metadata 1 \
-metadata:s:a:0 "title=" \
-metadata:s:a:0 "language=eng" \
-metadata:s:s:0 "language=eng" \
-movflags +faststart
"/g/marked for deletion/out.mkv"
```

- `-f lavfi -i color=c=black:s=720x480:r=1 -shortest` <br/> generates a low resolution all-black video track at 1fps with the same duration as the specified recording file.
- `-map 2:v:0` <br/> third input, first video track (all-black)
- `-map 0:a:0` <br/> first input, first audio track (OBS combined audio)
- `-map 1:s:0` <br/> second input, first subtitle track (transcribed audio via whisper)

Modifying metadata so audio track and subtitle track auto-selection in media players plays nicely.
- `-metadata:s:a:0 title=""` <br/> metadata > track selection > audio tracks > first audio track - erase track's title
- `-metadata:s:a:0 language=eng` <br/> metadata > track selection > audio tracks > first audio track - set track's language to english
- `-metadata:s:s:0 language=eng` <br/> metadata > track selection > subtitle tracks > first subtitle track - set track's language to english



## Concatenate multiple files

For greatest chance of success, all files should have same codecs and ideally same fps.

```sh
ffmpeg \
-f concat \
-safe 0 \
-i concat.txt \
-map 0 \
-c copy \
-map_metadata 0 \
-movflags +faststart
"concatenated.mkv"
```

Contents of `concat.txt`:

```
file 'input1.mkv'
file 'input2.mkv'
```



## Re-encode video to lower framerate

> ℹ Note <br/>
> May not need to specify video codec, or may want to specify a different codec.

```sh
ffmpeg \
-i "input.mkv" \
-map 0 \
-c:v h264_nvenc \
-c:a copy \
-vf fps=1 \
-movflags +faststart
"out.mkv"
```



## Check *.mkv files for excess video tracks (thumbnail embeded multiple times?)

One-liner. Really just fantastic to read. Even better copying into the terminal.

> ⚠ TODO <br/>
> Test `>=` works (previously was `==`).

```sh
for file in *.mkv; do \
if [ $(ffprobe -v quiet -print_format json -select_streams v -show_streams -i "${file}" | jq -r '.streams | length') >= 2 ]; \
then echo "❌ ${file}"; \
fi done;
```

- Loops over all `*.mkv` files in folder, stores current file name in `$file` variable.
- Use `ffprobe` and `jq` to count number of video streams.
- Echoes current file to console if two or more video tracks, the not-first track(s) likely being thumbnail "video" tracks...



## Check *.mkv files if streams are ordered correctly

It probably doesn't matter but I think video stream should come first, then audio, then anything else. This simply checks if the first stream is a video stream.

```sh
for file in *.mkv; do \
if [ $(ffprobe -v quiet -print_format json -select_streams v -show_streams -i "${file}" | jq -r '.streams.[0].codec_type') != "video" ]; \
then echo "❌ ${file}"; \
fi done;
```

- Loops over all `*.mkv` files in folder, stores current file name in `$file` variable.
- Use `ffprobe` and `jq` to check if first stream is video or not.
- Echoes current file to console if first stream is not video.



## Extract thumbnail from *.opus

```sh
for file in *.opus; do \
ffmpeg -y \
-i "${file}" \
-an \
-c:v copy \
"${file%.opus}.jpg"; \
done;
```

- `-an` <br/> disables audio streams
- `-c:v` <br/> copies video codec (does not re-encode)



## Extract thumbnail from *.mkv

```sh
for file in *.mkv; do \
ffmpeg -y \
-i "${file}" \
-an \
-map 0:v:1 \
-c copy \
"${file%.mkv}.jpg"; \
done;
```

- `-an` <br/> disables audio streams
- `-map 0:v:1` <br/> first input, second video track (most likely thumbnail "video" track)
- `-c` <br/> do not re-encode



## Attach thumbnail to *.mka or *.mkv

```sh
ffmpeg -y \
-i "in.mkv" \
-map 0 \
-c copy \
-map_metadata 0 \
-attach "thumb.jpg" \
-metadata:s:t "mimetype=image/jpeg" \
-metadata:s:t "filename=cover.jpg" \
-movflags +faststart
"out.mkv"
```



## Remux audio from *.mkv to *.mka

This is a rudimentary solution... For a more robust solution, see [make_mka.sh](files/make_mka.sh).

```sh
for file in *.mkv; do \
ffmpeg -y \
-i "${file}" \
-map 0:a \
-c:a copy \
-map_metadata 0 \
-attach "${file%.mkv}.jpg" \
-metadata:s:t "mimetype=image/jpeg" \
-metadata:s:t "filename=cover.jpg" \
-movflags +faststart \
"${file%.mkv}.mka"; \
done;
```

- `-attach "${file%.mkv}.jpg"` <br/> It's just easier to attach a standalone file as coverart...
- `%.mkv` <br/> a bash thing that trims `.mkv` from the end of the string.



## Remux audio from *.opus to *.mka

> ⚠ TODO <br/>
> Check how necessary the metadata flags are... <br/>
> I seem to recall *.opus metadata mapping to *.mka's audio track (instead of mapping to "global" metadata).

```sh
for file in *.opus; do \
ffmpeg -y \
-i "${file}" \
-map 0:a \
-c:a copy \
-map_metadata 0 \
-attach "${file%.opus}.jpg" \
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
-movflags +faststart
"${file%.opus}.mka"; \
done;
```



## Batch VMAF comparison

Contents of [batch_vmaf_comparison.sh](files/batch_vmaf_comparison.sh):

```sh
#!/bin/bash

reference=(
	"ref1.mkv"
)

compare=(
	"comp1.mkv"
)

length=${#reference[@]}

for (( i=0; i<${length}; i++ ));
do
	#printf "Current index %d with value %s\n" $i "${reference[$i]}"
	ffmpeg \
	-i "${compare[$i]}" \
	-i "${reference[$i]}" \
	-filter_complex " \
	[0:v]scale=1920:1080:flags=bicubic[comp]; \
	[1:v]scale=1920:1080:flags=bicubic[ref]; \
	[comp][ref]libvmaf=log_fmt=json:log_path=vmaf_scores_${i}.json" \
	-f null -
done
```

- `[0:v]scale=1920:1080:flags=bicubic[comp]` <br/> Ensure first video dimensions are 1080p; output labelled 'comp' for use in other filters.
- `[1:v]scale=1920:1080:flags=bicubic[ref]` <br/> Ensure second video dimensions are 1080p; output labelled 'ref' for use in other filters.
- `[comp][ref]libvmaf=log_fmt=json:log_path=vmaf_scores_${i}.json` <br/> Take `comp` and `ref` inputs and run them through `libvmaf`; log in json format and save log to disk, using corresponding array index.



## Detect certain attachments

Contents of [detect_attachments.sh](files/detect_attachments.sh):

```sh
#!/bin/bash

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
```



## Hardware-accelerated Scaling on NVIDIA GPU

See: https://docs.nvidia.com/video-technologies/video-codec-sdk/ffmpeg-with-nvidia-gpu/index.html

I don't remember why I needed this but archiving in case.

```sh
ffmpeg -y \
-vsync 0 \
-hwaccel cuda \
-hwaccel_output_format cuda \
-i "input.mkv" \
-vf scale_cuda=X:Y \
-c:a copy \
-c:d copy \
-c:s copy \
-c:t copy \
-c:v hevc_nvenc \
"output.mkv"
```
