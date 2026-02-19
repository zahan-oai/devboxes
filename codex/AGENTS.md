# AGENTS.md — Agent workflow rules (Codex)

This file defines how automated agents (including Codex) must work in my ~/code respositories.

## Working loop

Before you start writing new code, make sure that you're on a clean commit, no changes in the working directory.

Then, switch to master and fetch upstream changes (fast-forward local master). Then, make a new branch from master following the naming convention I outline later.

Once you're done with the changes, commit them with a message like "codex: {concise summary}". Then wait for me to tell you to push it upstream.

### Branch name

Use this template: "dev/zahan/codex-{feature}"
Make a short slug for {feature} that's likely to be unique

### Terms

I sometimes refer to origin/master as "upstream", because that's what that's basically what it is in the monorepo.

### Updating the Branch

If I ask you to merge upstream changes (from master typically), do that separate from any other feature changes I ask you to make on the branch. Generally I like a clean merge commit, then other commits for feature changes.

### Inheritance

I prefer explicit type declarations (say a union type) over inheritance. Avoid inheritance unless the existing code needs it.

## Monorepo and Python Packaging (oaipkg)

- If a project isn’t set up yet (e.g. `ModuleNotFoundError`), run `oaipkg install {pkg name}` to pull dependencies. Example: `oaipkg install oai_protection_client`
- Monorepo has a magic "auto import" feature that will typically auto install any monorepo packages. Running python modules with `oaipkg run ` instead of `python -m ` will run these installs first and is recommended. But if that doesn't work, fall back to "oaipkg install {module name}". Do NOT use `pip`.
- Monorepo is huge; rely on `rg` (ripgrep) for navigation: `rg "symbol" path/` is much faster than `grep`.
- For quick file snippets: `sed -n 'start,endp' file`. Example: `sed -n '60,140p file.py'` shows specific sections—handy before editing.
- Generally I will be working in only ONE MODULE in the repository at a time. You should not make edits to other projects in the same request unless it is clear that I wanted you to do so.
- To determine which module you're in, it's the directory that has a `pyproject.toml`; walk up from the file or test in question till you hit one.

## JavaScript Tooling

If you're modifying files in chatgpt/web , like TypeScript or JS - you'll need to work with OpenAI's JavaScript tool setup.

If you're running into missing commands or missing modules, run these in the chatgpt/web folder
```
js install
pnpm install
```

`js install` sets up OAI-specific utils, and `pnpm` is used regularly from there on out. Run the `format:fix` script before committing.

## Code Style

Do not use overly defensive code, like `except (Base)Exception` and `getattr`. They are anti-patterns unless there's a very good reason to use them.

## Lint / Format

We don’t install `pre-commit` as a Git hook in this repo, so run it manually to verify linting/formatting after creating a commit. If it modifies files, amend or commit them too otherwise CI will reject the change. 
Use `--files` to limit it to the ones you changed, or `--from-ref` and `--to-ref` to specify the commit range. (Do NOT use `--all-files`, it would time out in this repo.)

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
applied bazel test //chatgpt/av-app-service:mypy
```
For instance, this runs the `mypy` check for the `av-app-service`, located in `chatgpt/av-app-service`.

When you make python changes, typecheck it with `mypy`.

### Bazel

Note that in my invocation above, I prefixed `bazel` with `applied`. That's because in the monorepo we do not manage `BUILD` files by hand generally, and with the prefix, we first regenerate those files before attempting to build / run a Bazel target.

### Test-only functionality

Gating functionality with `oai_env.is_test_environment()` is not okay. If needed, fix the tests rather than putting test-only logic into prod codepaths.

### Test Manager

Tests that have been failing lately, or are flakey are "quarantined" by automation in CI. If you need to check the status of quarantined tests, try the quarantine-context skill. But if that doesn't work, just look at `az://appliedciblobdata/test-manager-data/labelstatuslist.json`

## Buildkite / CI

Once we make a PR, CI is run using Buildkite. You should have a MCP configured which let's you see the status for that PR, which jobs fail, logs for failures etc. Use this information to fix issues with the code changes we made.

Once you push a PR up, monitor the Buildkite job. It's green if all tests pass. But soft-failures are fine: these are tests that are failing on master, or are non-deterministic.

If the Buildkite MCP needs reauthentication, stop and let me know.

## Github

The `gh` CLI should be installed locally, use that to interact with Github. Primaily to work with PRs in this case: create, checkout, check status, view, etc.
