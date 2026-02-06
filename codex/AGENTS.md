# AGENTS.md — Agent workflow rules (Codex)

This file defines how automated agents (including Codex) must work in my ~/code respositories.

## Working loop

Before you start writing new code, make sure that you're on a clean commit, no changes in the working directory.

Then, if you're making adding to work that's already on that branch, great. Otherwise, make a new branch from master following the naming convention I outline later.

Once you're done with the changes, commit them with a message like "codex: {concise summary}". I'll inspect, and ask you to push to origin / Github if needed.

## Branch name

Use this template: "dev/zahan/codex-{feature}"
Make a short slug for {feature} that's likely to be unique

## Monorepo and Python Packaging (oaipkg)

- If a project isn’t set up yet (e.g. `ModuleNotFoundError`), run `oaipkg install {pkg name}` to pull dependencies. Example: `oaipkg install oai_protection_client`
- Monorepo has a magic "auto import" feature that will typically auto install any monorepo packages. Running python modules with `oaipkg run ` instead of `python -m ` will run these installs first and is recommended. But if that doesn't work, fall back to "oaipkg install {module name}". Do NOT use `pip`.
- Monorepo is huge; rely on `rg` (ripgrep) for navigation: `rg "symbol" path/` is much faster than `grep`.
- For quick file snippets: `sed -n 'start,endp' file`. Example: `sed -n '60,140p file.py'` shows specific sections—handy before editing.
- Generally I will be working in only ONE MODULE in the repository at a time. You should not make edits to other projects in the same request unless it is clear that I wanted you to do so.
- To determine which module you're in, it's the directory that has a `pyproject.toml`; walk up from the file or test in question till you hit one.

## Lint / Format

We don’t install `pre-commit` as a Git hook in this repo, so run it manually to verify linting/formatting after creating a commit. If it modifies files, stage those changes and amend them into the same commit.

```zsh
# For example, run hooks on just the last commit’s changes
pre-commit run --from-ref HEAD~1 --to-ref HEAD
```

## Tests

Please run tests that seem relevant to your code changes, that verification builds confidence in them. Keep in mind the python packaging note above for `pytest`, you might need to install deps. It's normal for this to take a long time (minutes), be patient.

While a direct `pytest` invocation is often appropriate, you can also invoke all the tests in a given module (which is how they're run in CI).

```zsh
applied test --test-spec {module name} --backend local
```
This is the same module as in python packaging. This should be a superset of individual `pytest`s, and `mypy`.

### mypy

If `mypy` is set up in a module's `pyproject.toml`, then there will be a bazel target for it in the generated `BUILD` file.

```zsh
bazel test //chatgpt/av-app-service:mypy
```
For instance, this runs the `mypy` check for the `av-app-service`, located in `chatgpt/av-app-service`.

When you make python changes, typecheck it with `mypy`.

## Buildkite

Once we make a PR, CI is run using Buildkite. You should have a MCP configured which let's you see the status for that PR, which jobs fail, logs for failures etc. Use this to fix issues with the code changes we made.

## Github

The `gh` CLI should be installed locally, use that to interact with Github. Primaily to work with PRs in this case: create, checkout, check status, view, etc.
