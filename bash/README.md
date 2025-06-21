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
