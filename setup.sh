#!/usr/bin/env zsh
set -euo pipefail

# install prezto (if needed)
ZPREZTO_DIR="${ZDOTDIR:-$HOME}/.zprezto"
if [[ ! -d "$ZPREZTO_DIR" ]]; then
  git clone --recursive https://github.com/sorin-ionescu/prezto.git "$ZPREZTO_DIR"
fi

# symlink dotfiles in this directory into $HOME
DOTFILES_DIR="${0:A:h}/dotfiles"
for src in "$DOTFILES_DIR"/.*(N); do
  name="${src:t}"
  [[ "$name" == "." || "$name" == ".." ]] && continue

  link="$HOME/$name"
  # Make the symlink
  if ! ln -fs "$src" "$link" 2>/dev/null; then
    echo "Failed to symlink $src -> $link" >&2
    exit 1
  fi
  print -r -- "$src -> $link"
done

# link AGENTS.md in the right place
mkdir -p "$HOME/.codex"
CODEX_DIR="${0:A:h}/codex"
src="$CODEX_DIR/AGENTS.md"
link="$HOME/.codex/AGENTS.md"
if ! ln -fs "$src" "$link" 2>/dev/null; then
    echo "Failed to symlink $src -> $link" >&2
    exit 1
fi
print -r -- "$src -> $link"

# Set up the monorepo
pushd "$HOME/code/openai/" >/dev/null
git config --unset-all remote.origin.fetch
git config --add remote.origin.fetch 'refs/heads/master:refs/remotes/origin/master'
git config --add remote.origin.fetch 'refs/heads/dev/zahan/*:refs/remotes/origin/dev/zahan/*'
popd >/dev/null

print -r -- "Setup complete, set up your MCPs now: (see README)"
print -r -- "> codex mcp login buildkite"
print -r -- "Then you can run 'codex-prime' to start the Codex agent"
