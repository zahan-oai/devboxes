#!/usr/bin/env zsh
set -euo
setopt pipefail

# install prezto (if needed)
ZPREZTO_DIR="${ZDOTDIR:-$HOME}/.zprezto"
if [[ ! -d "$ZPREZTO_DIR" ]]; then
  git clone --recursive https://github.com/sorin-ionescu/prezto.git "$ZPREZTO_DIR"

  # reload the shell
  exec zsh
fi

# symlink dotfiles in this directory into $HOME
DOTFILES_DIR="${0:A:h}"
for src in "$DOTFILES_DIR"/.*(N); do
  name="${src:t}"
  [[ "$name" == "." || "$name" == ".." ]] && continue

  target="$HOME/$name"
  # Ignore the "already exists" case (including existing symlinks)
  if [[ -e "$target" || -L "$target" ]]; then
    continue
  fi

  # Make the symlink
  if ! ln -s "$src" "$target" 2>/dev/null; then
    echo "Failed to symlink $src -> $target" >&2
    exit 1
  fi
done
