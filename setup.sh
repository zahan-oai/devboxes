#!/usr/bin/env zsh
set -euo pipefail

log() {
  printf '[setup] %s\n' "$*"
}

warn() {
  printf '[setup][warn] %s\n' "$*" >&2
}

have() {
  command -v "$1" >/dev/null 2>&1
}

setup_shell() {
  # install prezto (if needed)
  ZPREZTO_DIR="${ZDOTDIR:-$HOME}/.zprezto"
  if [[ ! -d "$ZPREZTO_DIR" ]]; then
    git clone --recursive https://github.com/sorin-ionescu/prezto.git "$ZPREZTO_DIR"
  fi
}

link_dotfiles() {
  # symlink dotfiles in this directory into $HOME
  DOTFILES_DIR="${0:A:h}/dotfiles"
  for src in "$DOTFILES_DIR"/.*(N); do
    name="${src:t}"
    [[ "$name" == "." || "$name" == ".." ]] && continue

    link="$HOME/$name"
    # Make the symlink
    if ! ln -fs "$src" "$link" 2>/dev/null; then
      warn "Failed to symlink $src -> $link"
      exit 1
    fi
    log "$src -> $link"
  done
}

install_ubi_if_needed() {
  if have ubi; then
    return 0
  fi

  if have cargo; then
    log "Installing ubi-cli with cargo"
    cargo install ubi-cli --root "$HOME/.local"
    # Ensure ~/.local/bin is in the PATH for future commands in this script
    [[ ":$PATH:" != *":$HOME/.local/bin:"* ]] && export PATH="$PATH:$HOME/.local/bin"
    return 0
  fi

  warn "ubi is not installed and cargo is unavailable; skipping ubi installation"
  return 1
}

install_git_spice() {
  if have gs || have git-spice; then
    return 0
  fi

  mkdir -p "$HOME/bin"

  if have brew; then
    log "Installing git-spice with Homebrew"
    brew install git-spice
  else
    install_ubi_if_needed || true
    if have ubi; then
      log "Installing git-spice via ubi"
      ubi --project abhinav/git-spice --exe git-spice
    else
      warn "Unable to install git-spice automatically"
      return 1
    fi
  fi
}

setup_codex() {
  # link AGENTS.md in the right place
  mkdir -p "$HOME/.codex"
  CODEX_DIR="${0:A:h}/codex"
  src="$CODEX_DIR/AGENTS.md"
  link="$HOME/.codex/AGENTS.md"
  if ! ln -fs "$src" "$link" 2>/dev/null; then
      warn "Failed to symlink $src -> $link"
      exit 1
  fi
  log "$src -> $link"
}

setup_monorepo() {
  # Set up the monorepo
  pushd "$HOME/code/openai/" >/dev/null
  git remote set-url origin "https://github.com/openai/openai.git"
  git config --unset-all remote.origin.fetch
  git config --add remote.origin.fetch 'refs/heads/master:refs/remotes/origin/master'
  git config --add remote.origin.fetch '+refs/heads/dev/zahan/*:refs/remotes/origin/dev/zahan/*'
  touch project/pre-commit/.disable-dev-branch-check
  popd >/dev/null
}

configure_codex_mcps() {
  # set up MCPs
  mcps=$(codex mcp list --json | jq -r '.[].name')
  # outdated MCPs
  if grep -qF "ologs" <<< "$mcps"; then
    codex mcp remove ologs
    log "Removed outdated ologs MCP"
  fi
  if grep -qF "notion" <<< "$mcps"; then
    codex mcp remove notion
    log "Removed outdated notion MCP"
  fi
  # MCPS we want
  if ! grep -qF "observability" <<< "$mcps"; then
    oaipkg install aw
    aw mcp codex install
  fi
  if ! grep -qF "kepler" <<< "$mcps"; then
    codex mcp add kepler -- oaipkg run kepler_mcp.mcp.cli
  fi
  if ! grep -qF "nexus" <<< "$mcps"; then
    codex mcp add nexus --url https://nexus.gateway.deploy-0.internal.api.openai.org/api/v1/mcp
  fi
  if ! grep -qF "deploy_manager" <<< "$mcps"; then
    codex mcp add deploy_manager --env OPENAI_API_KEY=${OPENAI_API_KEY} -- python $HOME/code/openai/lib/applied/connectors/openai_mcp_servers/scripts/mcp_identity_proxy.py deploy_manager=https://openai-mcp-servers.gateway.unified-0.internal.api.openai.org/internal/deploy_manager/mcp
  fi
  if ! grep -qF "buildkite" <<< "$mcps"; then
    log "TODO: codex mcp add buildkite --url https://mcp.buildkite.com/mcp"
  fi
  if ! grep -qF "datadog" <<< "$mcps"; then
    log "TODO: codex mcp add datadog --url https://mcp.datadoghq.com/api/unstable/mcp-server/mcp" 
  fi

  # Deprecated ologs custom MCP setup
  # if ! grep -qF "ologs" <<< "$mcps"; then
  #   codex mcp add ologs -- mcp-proxy --transport streamablehttp "https://obs-mcp-default-internal.gateway.obs-1.internal.api.openai.org/ologs/mcp"
  # fi
  # if ! grep -qF "notion" <<< "$mcps"; then
  #   print -r -- "TODO: codex mcp add notion --url https://mcp.notion.com/mcp"
  # fi
}

check_gh_auth() {
  if ! gh auth status | grep -qF "zahan-oai"; then
    log "TODO: gh auth login"
    log "Then run oai_gh --code {code} locally"
  fi
}

print_next_steps() {
  cat <<EOF

Setup complete.

Manual follow-ups:
  1. Restart your shell or run: exec zsh -l
  2. Authenticate GitHub if needed: gh auth login
  3. Authenticate Codex if needed: codex login
  4. Refresh Azure/devbox auth if needed: applied devbox az-login

Notes:
  - ~/.codex/config.toml is not managed here; applied devbox setup already syncs it and patches OAuth callback fields.

Run 'codex-prime' to start the Codex agent!
EOF
}

main() {
  setup_shell
  link_dotfiles
  install_git_spice
  setup_codex
  setup_monorepo
  configure_codex_mcps
  check_gh_auth

  print_next_steps
}

main "$@"
