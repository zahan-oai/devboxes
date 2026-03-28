# AGENTS.md — Agent workflow rules (Codex)

This file defines how automated agents (including Codex) must work in the ~/code/codex-1 (and other ~/code/codex-*) respositories

## Non-negotiable rules

1. **Use `jj` only. Do not run `git` commands.**

   * Never run: `git status`, `git diff`, `git add`, `git commit`, `git push`, `git checkout`, `git switch`, `git merge`, `git rebase`, etc.
   * If you think you need a git command, find the `jj` equivalent instead.

2. **Never modify history in the human workspace.**

   * Work only in the agent workspace (see “Workspace model” below).
   * Keep changes isolated to your own working copy commit(s).

3. **Commit early, commit small (jj-style).**

   * Prefer a short stack of small commits that are easy to review and selectively integrate.

4. **If a command is blocked/rejected, immediately retry using `jj`.**

   * Do **not** stop or give up after a blocked command.
   * Re-plan and continue with the `jj`-only approach.

## Workspace model

* The human works in their primary `jj` workspace (named `default`).
* You (Codex) must work in a dedicated agent workspace, named **`codex-1`**.
* You will already likely be on a new empty change that you can work with.

You can check if it's empty with

```bash
jj log
```

If you need to start a new change (if it's non-empty), then use

```bash
jj new
```

## Required working loop (for each logical step)

1. Make edits.
2. Inspect what changed (jj only):

```bash
jj status
jj diff --git
```

3. Describe the current working-copy commit (with your “commit message”), this also creates a fresh commit for the next step:

```bash
jj commit -m "codex: <concise summary>"
```

If a commit got too large, split it:

```bash
jj split
```

If you accidentally made multiple commits that should be one, squash them:

```bash
jj squash
```

## Review / logging

Use these commands for review:

```bash
jj log
jj log -r 'master..@'
jj diff --git --from master
```

When asked “what did you change?”, summarize based on:

* `jj status`
* `jj diff --git`
* `jj log` (relevant range)

## Common tasks cheat sheet (jj equivalents)

Do not do any of these repo-changing operations unless the human requests you to. They like managing the repo themselves.

### Run local lint checks

Run `ruff` to check any lint issues before committing.

```
ruff check --fix <file or directory>
ruff format <file or directory>
```

### Abandon a bad commit or stack (discard work)

```bash
jj abandon @
# or abandon a stack:
jj abandon -r 'master..@'
```

## Running commands locally

If you need to run commands for tests, or codegen, or anything that uses OpenAI's python modules,
you'll need to run this to set up the environment.

```
export WORKTREE=$(basename `pwd`)
export MONOREPO_VENV=$HOME/.virtualenvs/openai-$WORKTREE
source monorepo_setup.sh
venv_setup_build
source $MONOREPO_VENV/bin/activate
```

Run it (once per session / shell) before you run "applied something" or python tests etc.

## Safety rails

* Do not run destructive filesystem commands unless explicitly asked.
* Do not change formatting/linting repo-wide unless requested.
* Prefer minimal diffs and targeted fixes.
