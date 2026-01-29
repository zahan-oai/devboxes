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
