---
layout: notes 
title: Software Configuration Management
---


## Software Configuration Management

Git is the main version control system I am using currently.

### Git
Configuration commands are:

```bash
git config --global user.name
git config --global user.email
git config --global --list
```

Here the log to show all the branches

```bash
git log --oneline --all --graph --decorate
```

configure alias global level

```bash
git config --global alias.lg "log --oneline --all --graph --decorate"
```

To see the commit history

```bash
git reflog
```

Set the push limited only to the current branch:

```bash
git config --global push.default simple
```

List all the master branches:

```bash
git branch -a
```

Rename a file:

```bash
git mv index.html home.htm
```

Delete the file:

```bash
git rm index.html
```

Push only the tags:

```bash
git push --tags
```

Fetch without merging:

```bash
# currently in the master branch
git fetch
git checkout orign/master
cat test.com
git checkout master
git merge origin/master
```

rebasing

```bash
git pull --rebase
```

After commit and push if need to revert back due to the mistakes, follow the following command with SHA1

```bash
git revert <SHA1>
```

However, with the git lg above will show the history of the revert and the mistake.

To get rid of the last two commits:

-   completely throw away including files: `hard`
-   files back to the staging area from commit: `soft`
-   default will blow away the commits, remove the files from the staging area but leave the files: `mixed`

```shell
git reset HEAD~2
```

if you need to get back the ``` git reset --hard HEAD~2``` back use the SHA as follows

```shell
git reset --hard <SHA>
```

How to insert multiple commits:

```bash
# add new file
touch test.html
git add .
git commit -m "Add the test html file"
```

Now one way to insert SHA from another branch is cherry-pick as explained. The second way is (check the commit history if there is no new branch but recovering pervious commit and select that SHA)

```bash
# based on your SHA
# then create a new branch from that
git checkout SHA

#from the above checkout branch create a tmp branch
git checkout -b tmp

#now you can check with the "git lg", you will see new branch
#now rebase against master
git rebase master
```

Interactive rebase last 5 commits:

```bash
git rebase -i HEAD~5
```

find the commit from log message:

```bash
git log --all --grep='prepare release 1.0.12' 
```

find all the branches where commit is available:

```bash
git branch -r --contains 833187d69f6a776b715ddb5c0a1806d06e8159cb
#if need to checkout the commit
git checkout 833187d69f6a776b715ddb5c0a1806d06e8159cb
```

#### Alias 

(alias#git_alias)
Some important alias to **~/.gitconfig** :

```git
[alias]
	  show-last-commit = !sh -c 'git log $1@{1}..$1@{0} "$@"'
	  del-tag = !sh -c 'git tag -d $1 && git push origin :$1' -
	  del-branch = !sh -c 'git branch -d $1 && git push origin :$1' -
	  pt = !sh -c 'git tag $1 && git push origin $1' -	
```

the `git new` command shows the latest commit. I used this to find the change id for gerrit specially. The commands `git dt <tag name>` and `git db <branch name>` respectively delete the tag and the branch. if need to tag and push that tag with one command use: `git pt <tag name>`.

**Grog** 

to show the log

```git
git config --global alias.grog 'log --graph --abbrev-commit --decorate --all --format=format:"%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(dim white) - %an%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n %C(white)%s%C(reset)"'
```

**Shorty**

Show the short status

```Shell
git config --global alias.shorty 'status --short --branch'
```

**Amend**

Amend the forget files after add

```git
git config --global alias.commend 'commit --amend --no-edit'
```

Here the short cut review command for the Gerrit:

```git
	  review = !sh -c 'git push origin HEAD:refs/for/develop%topic=$1,r=Easthope.Michael' -
```

#### Store password
Store Gerrit password in local workspace 

Instead of type password each time when you push or pull from the gerrit, you can store the password permanently:

```git
git config credential.helper store
```

Then issue the command and provide the password first time. Then after git will never ask the password until you unset as follows

```git
git config --unset credential.helper
```

Only once you have to do this.

#### Abort merge

In the new git,

```git
	git merge --abort
```

#### cherry pick

Apply one commit to another branch. Say you have a commit in the *WORK* branch and you need to bring this commit to the *DEVE* branch. First move to the *DEVE* branch. Then see the tree;

```git
	git checkout DEVE
	git log -n10 --oneline --graph WORK
	* 95d21d6 Changed the driver.
	*   a238007 release-1.42.0 - Resolved
	*  ... 
```

Then select the commit hash from the tree graph. Say commit hash is *95d21d6*

```git
	git cherry-pick 95d21d6
```

Now check the cherry pick has been applied ?

```git
	git log -n10 --oneline --graph DEVE
	* 5e7ee1a Changed the driver.
	*   9607ea0 Merge branch 'DEVE...
	* ...
```

Although commit has changed, from the comment you can find that changes are applied. For example, change commit 9607ea0 is the commit before the cherry pick. To diff 

```git
	git diff 9607ea0..HEAD
		...
		...
	git diff 9607ea0..HEAD --name-only
		...
		...
```

if you need to find the detail of the branch differences

```git
git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%Creset' --abbrev-commit --date=relative develop..release-1.42.3-develop
```

If you need to revert the cherry-pick due to the merge confilicts

```git
git reset --merge
```

#### Important 

Here the important information such as references and tutorials.

| topic            | Link                                                        |
| ---------------- | ----------------------------------------------------------- |
| Merge and Rebase | https://www.atlassian.com/git/tutorials/merging-vs-rebasing |

### Gerrit

#### Setup
Before commit for the review, Gerrit need to be enable for review. The change-id has to be attached with each and every commit.  Two steps to follow

- Make the hook

```bash
curl -Lo ABCID/.git/hooks/commit-msg http://<user>@<gerrit server>/gerrit/tools/hooks/commit-msg
```

- make the hook executable

```bash
chmod +x .git/hooks/commit-msg
```

 Now you are ready to do the first commit in the Gerrit.

#### Review

Gerrit is based on Git server, but support more features such as review because there is embedded workflow in the Gerrit.

```bash
git push origin HEAD:refs/for/<target branch>%topic=<topic to show in the dashboard>,r=<reviewer>
```

is the review command to run in Git prompt.
