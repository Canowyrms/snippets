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
