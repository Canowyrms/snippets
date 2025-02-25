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
