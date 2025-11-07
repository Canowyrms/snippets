# Git Snippets

## Rebase master onto feature branch

> ℹ Note <br/>
> Haven't used this yet but archiving just in case.

If you're working on a new feature branch, you can do the following to have the latest from master:
- commit all work in wip commit `git add . && git commit -m "WIP reset"`
- checkout + update master `git checkout master && git pull`
- checkout feature branch and update on master `git checkout <my-feature-branch> && git rebase origin/master`
- deal with any conflicts if any
- reset your WIP commit `git reset HEAD^`



## Git config for working with multiple orgs/accounts

TLDR: Conditional includes

In `.gitconfig`:

```gitconfig
[includeIf "hasconfig:remote.*.url:https://github.com/organization/**"]
	path = ~/.gitconfig-org
[includeIf "hasconfig:remote.*.url:git@github.com:organization/**"]
	path = ~/.gitconfig-org
[includeIf "hasconfig:remote.*.url:ssh://git@github.com/organization/**"]
	path = ~/.gitconfig-org
[includeIf "gitdir:~/Projects/Organization/"]
	path = ~/.gitconfig-org
```

and then, in `~/.gitconfig-org` (or whatever you decide to name the file):

```gitconfig
[user]
	name = Name Override
	email = email@example.org
	signingKey = F00F1234
[core]
	# You can point to a pub key to have it automatically select the right key in your SSH agent
	# if you don't use an SSH agent, point to your private key
	sshCommand = ssh -i ~/.ssh/email@example.org.pub
```
