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
