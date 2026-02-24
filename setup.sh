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

# set up MCPs
mcps=$(codex mcp list --json | jq -r '.[].name')
if ! grep -qF "ologs" <<< "$mcps"; then
  codex mcp add ologs -- mcp-proxy --transport streamablehttp "https://obs-mcp-default-internal.gateway.obs-1.internal.api.openai.org/ologs/mcp"
fi
if ! grep -qF "kepler" <<< "$mcps"; then
  codex mcp add kepler -- oaipkg run kepler_mcp.mcp.cli
fi
if ! grep -qF "nexus" <<< "$mcps"; then
  codex mcp add nexus --url https://nexus.gateway.deploy-0.internal.api.openai.org/api/v1/mcp
fi
if ! grep -qF "deploy_manager" <<< "$mcps"; then
  codex mcp add deploy_manager -- python $HOME/code/openai/lib/applied/connectors/openai_mcp_servers/scripts/mcp_identity_proxy.py deploy_manager=https://openai-mcp-servers.gateway.unified-0.internal.api.openai.org/internal/deploy_manager/mcp --env OPENAI_API_KEY=${OPENAI_API_KEY}
fi
if ! grep -qF "buildkite" <<< "$mcps"; then
  print -r -- "TODO: codex mcp add buildkite --url https://mcp.buildkite.com/mcp"
fi
if ! grep -qF "notion" <<< "$mcps"; then
  print -r -- "TODO: codex mcp add notion --url https://mcp.notion.com/mcp"
fi
if ! grep -qF "datadog" <<< "$mcps"; then
  print -r -- "TODO: codex mcp add datadog --url https://mcp.datadoghq.com/api/unstable/mcp-server/mcp" 
fi

if ! gh auth status | grep -qF "zahan-oai"; then
  print -r -- "TODO: gh auth login"
  print -r -- "Then run oai_gh --code {code} locally"
fi

print
print -r -- "Setup complete"
print -r -- "Then you can run 'codex-prime' to start the Codex agent"
