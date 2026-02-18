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
git config --add remote.origin.fetch '+refs/heads/dev/zahan/*:refs/remotes/origin/dev/zahan/*'
popd >/dev/null

# set up MCP utils
if ! command -v mcp-proxy >/dev/null 2>&1; then
  echo "mcp-proxy not found, installing"
  uv tool install mcp-proxy
fi

# set up MCPs
mcps=$(codex mcp list --json | jq -r '.[].name')
if ! grep -qF "ologs" <<< "$mcps"; then
  codex mcp add ologs -- mcp-proxy --transport streamablehttp "https://obs-mcp-default-internal.gateway.obs-1.internal.api.openai.org/ologs/mcp"
  print -r -- "Added OLogs MCP"
fi
if ! grep -qF "kepler" <<< "$mcps"; then
  codex mcp add kepler -- oaipkg run kepler_mcp.mcp.cli
  print -r -- "Added Kepler MCP"
fi
if ! grep -qF "nexus" <<< "$mcps"; then
  codex mcp add nexus --url https://nexus.gateway.deploy-0.internal.api.openai.org/api/v1/mcp
  print -r -- "Added Nexus MCP"
fi
if ! grep -qF "buildkite" <<< "$mcps"; then
  codex mcp add buildkite --url https://mcp.buildkite.com/mcp
  print -r -- "Added Buildkite MCP"
fi
if ! grep -qF "notion" <<< "$mcps"; then
  codex mcp add notion --url https://mcp.notion.com/mcp
  print -r -- "Added Notion MCP"
fi
if ! grep -qF "datadog" <<< "$mcps"; then
  codex mcp add datadog --url https://mcp.datadoghq.com/api/unstable/mcp-server/mcp
  print -r -- "Added Datadog MCP"
fi

print
print -r -- "Setup complete"
print -r -- "Then you can run 'codex-prime' to start the Codex agent"
