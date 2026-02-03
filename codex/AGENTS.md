# AGENTS.md — Agent workflow rules (Codex)

This file defines how automated agents (including Codex) must work in my ~/code respositories.

## Working loop

Before you start writing new code, make sure that you're on a clean commit, no changes in the working directory.

Then, if you're making adding to work that's already on that branch, great. Otherwise, make a new branch from master following the naming convention I outline later.

Once you're done with the changes, commit them with a message like "codex: {concise summary}". I'll inspect, and ask you to push to origin / Github if needed.

### Branch name

Use this template: "dev/zahan/codex-{feature}"
Make a short slug for {feature} that's likely to be unique

## Environment

### Monorepo and Python Packaging (oaipkg)

- If a project isn’t set up yet (e.g. `ModuleNotFoundError`), run `oaipkg install {pkg name}` to pull dependencies. Example: `oaipkg install oai_protection_client`
- Monorepo has a magic "auto import" feature that will typically auto install any monorepo packages. Running python modules with `oaipkg run ` instead of `python -m ` will run these installs first and is recommended.
- Monorepo is huge; rely on `rg` (ripgrep) for navigation: `rg "symbol" path/` is much faster than `grep`.
- For quick file snippets: `sed -n 'start,endp' file`. Example: `sed -n '60,140p file.py'` shows specific sections—handy before editing.
- Generally I will be working in only ONE MODULE in the repository at a time. You should not make edits to other projects in the same request unless it is clear that I wanted you to do so.
- To determine which module you're in, it's the directory that has a `pyproject.toml`; walk up from the file or test in question till you hit one.
