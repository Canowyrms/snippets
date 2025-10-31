# Bash Snippets

Bash and Bash-adjacent snippets.

## Get remote URL for all repos in cwd

```sh
#!/bin/bash

for dir in */; do
	if [ -d "$dir/.git" ]; then
		echo "Dir: $dir"
		git -C "$dir" remote -v
		echo
	fi
done
```



## Track all remote branches locally for all repos in cwd

```sh
#!/bin/bash

for dir in */; do
	if [ -d "$dir/.git" ]; then
		echo "Dir: $dir"

		# Get all remote branches.
		git -C "$dir" fetch --all

		# Loop over all remote branches, creating local branches that track the remote branches.
		for branch in $(git -C "$dir" branch -r | grep -v '\->'); do
			git -C "$dir" branch --track ${branch#origin/} $branch
		done

		# Ensure everything is up-to-date.
		git -C "$dir" pull --all

		echo
	fi
done
```



## Do something in parallel (`xargs`)

Sometimes tasks are single-threaded. Sometimes you need to perform the same operation on multiple items. (Is this SIMD? SIMD-adjacent?)

Basic examples that can be expanded upon.

### Using `find`

Sometimes you can do the same operation on all items in the directory...

```sh
find . -name '*.mkv' -print0 | xargs -0 -P 6 -I {} ffmpeg -i {} -map 0:a:0 -ac 1 "{}.audio_0.flac
```

- `-print0` <br/> Handle filenames with spaces safely.
- `xargs -0` <br/> Read null-separated inputs to handle spaces.
- `-P 6` <br/> Run **6** parallel instances.
- `-I {}` <br/> Specifies replacement token for each filename.


### Using bash array and `printf`

Sometimes you need to work on a specific subset...

```sh
files=(1.mkv 2.mkv 3.mkv)

atrack=2

printf "%s\0" "${files[@]}" | xargs -0 -P 6 -I {} ffmpeg -i {} -map 0:a:${atrack} -ac 1 "{}.audio_${atrack}.flac"
```

- `printf "%s\0" "${files[@]}"` <br/> Safely prints all filenames separated by null characters.
- `xargs -0` <br/> Read null-separated inputs to handle spaces.
- `-P 6` <br/> Run **6** parallel instances.
- `-I {}` <br/> Specifies replacement token for each filename.
