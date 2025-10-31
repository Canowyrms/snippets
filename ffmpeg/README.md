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
-movflags +faststart \
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
-movflags +faststart \
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
-movflags +faststart \
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
-movflags +faststart \
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
-movflags +faststart \
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
-movflags +faststart \
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
-movflags +faststart \
"${file%.opus}.mka"; \
done;
```



## Remux different audio and video sources, preserving metadata

This example has a more complex stream and metadata mapping than other examples.

```sh
ffmpeg -y \
-i "in.mkv" \
-i "in.mka" \
-map 0:v \
-map 1:a:1 \
-map 0:s \
-c copy \
-map_metadata 0 \
-map_metadata:s:a:0 1:s:a:1 \
-map_metadata:s:s:0 0:s:s:0 \
-movflags +faststart \
"out.mkv"
```

- -map 0:v <br/> Video tracks from input 0.
- -map 1:a:1 <br/> Audio track 1 from input 1.
- -map 0:s <br/> Subtitle tracks from input 0.
- `map_metadata 0` <br/> Should copy global and video track metadata from input 0.
- `map_metadata:s:a:0 1:s:a:1` <br/> Maps metadata from input 1, stream selection > audio track 1 to output, stream selection > audio track 0.
- `map_metadata:s:s:0 0:s:s:0` <br/> Maps metadata from input 0, stream selection > subtitle track 0 to output, stream selection > subtitle track 0.



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



## Trim and scale video, re-encoding (10-bit H265 to 8-bit H264)

Was using this as part of a workflow to clip a title/credit sequence from an H265 source.

Sometimes we need exact segments (i.e. start and end times), and to avoid black frames before/after, we can re-encode.

```sh
ffmpeg -i "h265_10bit_input.mkv" \
-map 0 \
-ss "00:00:02.112" -to "00:01:17.060" \
-c:v h264_nvenc -pix_fmt yuv420p -preset p7 -profile high \
-vf scale=1280:-2 \
-c:a libopus -b:a 320k \
-af "channelmap=channel_layout=5.1" \
-movflags +faststart \
"output.720p.h264.mp4"
```

Optional swaps:

```sh
# H265 NVENC 10,000Kbps
-c:v hevc_nvenc -preset slow -profile:v main10 -rc vbr -b:v 10000k -maxrate 13000k -bufsize 20000k -temporal-aq 1 -spatial-aq 1 -rc-lookahead 98 -2pass true -multipass 2 \
# Downmix audio to stereo; don't use -af flag if using this.
-c:a libopus -b:a 120k -ac 2 \
```

- `-ss "00:00:02.112" -to "00:01:17.060"` <br/> **S**pecific **S**egment from in_time to out_time; can quickly get values from LosslessCut.
- `-c:v h264_nvenc -pix_fmt yuv420p` <br/> Converts down to 8-bit colour format (H264 doesn't support 10-bit).
- `-vf scale=1280:-2` <br/> Scale video down, maintaining aspect ratio. `-1` may work, but some codecs require height or width to be a multiple of `n`, in which case, `-2` works (see: https://trac.ffmpeg.org/wiki/Scaling#KeepingtheAspectRatio).
- `-c:a libopus -b:a 320k` <br/> Re-encode audio into opus format for space efficiency.
- `-af "channelmap=channel_layout=5.1"` <br/> Opus doesn't automatically remap channels, so if input media is 5.1, pass this in manually (see: https://trac.ffmpeg.org/ticket/5718).



## Apply filters to an audio track before combining multiple tracks into a single track

In one of my D&D recordings, my mic had fallen back to a more basic processing chip, something to that effect. Windows usually detects the mic as a Yeti Blue, but this time, the mic was recognized as a generic mic. That is the long way to say, it sounded like garbage, and was extremely loud at times.

This snippet demonstrates applying an audio filter to one track before merging it with another for final output.

```sh
ffmpeg -i "input.mkv" \
-filter_complex "[0:a:2]acompressor=threshold=0.05:ratio=10:attack=200:release=1000[mic]; \
[0:a:4][mic]amix=inputs=2[aout]" \
-map "[aout]" \
-c:a libopus \
-b:a 320k \
-map_metadata 0 \
-movflags +faststart \
"out.fixed.mka"
```

- `-filter_complex "[0:a:2]...[mic]"` <br/> Selects the 3rd audio track (0-indexed) for filtering; maps result to "mic" for subsequent operations.
- `[0:a:4][mic]amix=inputs=2[aout]` <br/> Selects the 5th audio track (0-indexed) and the "mic" track from previous step for filtering; maps result to "aout" for subsequent operations.
- `-map "[aout]"` <br/> Select "aout" track from previous step for output.



## Combine audio tracks of varying length, aligned to the end

In the situation you have two or more audio tracks of different lengths, and want to pad the front of the audio so they all end at the same time, we can figure out the offset (in ms) and pad the audio in a `filter_complex` step.

Get the offset:

```sh
ffprobe -i "a1.mka" -show_entries format=duration -v quiet -of csv="p=0"
ffprobe -i "a2.mka" -show_entries format=duration -v quiet -of csv="p=0"
```

Subtract the shorter from the longer, and take note of the number. I believe the output format here is `X.YYY`, where `X` is seconds, and `YYY` is ms. The `adelay` filter accepts ms, not sure if it accepts seconds.

```sh
ffmpeg \
-i "a1.mka" \
-i "a2.mka" \
-filter_complex " \
[0]adelay=750|750[padded]; \
[padded][1]amix=inputs=2:duration=longest" \
"out.mp3"
```

- `[0]...[padded]` <br/> Selects the first input (0-indexed) for filtering; maps result to "padded" for subsequent operations.
- `adelay=750|750` <br/> Adds 750ms of delay to the front of the current audio item being filtered.



## Clip a segment to MP3

Mostly used for quickly extracting funnies from longer session recordings.

```sh
ffmpeg -y \
-i "in.mkv" \
-map 0:a:0 -map_metadata 0 \
-ss "hh:mm:ss.000" -to "hh:mm:ss.000" \
"funny.mp3"
```

- `-ss "00:00:02.112" -to "00:01:17.060"` <br/> **S**pecific **S**egment from in_time to out_time; can quickly get values from LosslessCut.



## List certain properties of certain tracks; JSON output via `jq`

```sh
for file in *.mkv; do
	echo "📄 ${file}"

	# Limited to audio tracks only.
	ffprobe -v quiet -print_format json -show_streams "${file}" | jq -c '.streams[] | select(.codec_type == "audio") | {index, title: .tags.title}'

	echo ""
done
```

Example output:

```log
📄 2025-10-29.mkv
{"index":1,"title":"Main (Game, Mic, Music, Discord)"}
{"index":2,"title":"Mic"}
{"index":3,"title":"Discord"}
{"index":4,"title":"Desktop"}
```