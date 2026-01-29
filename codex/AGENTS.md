# AGENTS.md — Agent workflow rules (Codex)

This file defines how automated agents (including Codex) must work in the ~/code/openai respository

## Working loop

1. Make a new branch

2. Make edits

3. Inspect what changed

```bash
git status
git diff
```

4. Describe the current working-copy commit (with your “commit message”), and commit

```bash
git commit -A -m "codex: <concise summary>"
```

5. (If done) push the branch to "origin" (Github)

### Branch name

Use this template: "dev/zahan/codex-{feature}"
Make a short slug for {feature} that's likely to be unique

### Resuming work

If you're making edits to code on a branch, make the changes, add new commits, then push.

### Review

You can use these commands for review, for example when asked “what did you change?”

```bash
git log
git log master..HEAD
git diff master..HEAD
git show {rev}
```
