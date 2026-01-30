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

  target="$HOME/$name"
  # If it already exists, delete it and replace with the symlink.
  if [[ -e "$target" || -L "$target" ]]; then
    rm "$target"
  fi

  # Make the symlink
  if ! ln -s "$src" "$target" 2>/dev/null; then
    echo "Failed to symlink $src -> $target" >&2
    exit 1
  fi
  print -r -- "$src -> $target"
done

# install gh (if needed)
if ! command -v gh >/dev/null 2>&1; then
    if ! command -v curl >/dev/null 2>&1; then
        sudo apt-get update
        sudo apt-get install -y curl
    fi

    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg

    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
        | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null

    sudo apt-get update
    sudo apt-get install -y gh
fi

# link AGENTS.md in the right place
mkdir -p "$HOME/.codex"
src="$DOTFILES_DIR/codex/AGENTS.md"
target="$HOME/.codex/AGENTS.md"
if [[ -e "$target" || -L "$target" ]]; then
    rm "$target"
fi
if ! ln -s "$src" "$target" 2>/dev/null; then
    echo "Failed to symlink $src -> $target" >&2
    exit 1
fi
print -r -- "$src -> $target"

# Set up the monorepo
pushd "$HOME/code/openai/" >/dev/null
git config --unset-all remote.origin.fetch
git config --add remote.origin.fetch 'refs/heads/master:refs/remotes/origin/master'
git config --add remote.origin.fetch 'refs/heads/dev/zahan/*:refs/remotes/origin/dev/zahan/*'
popd >/dev/null
