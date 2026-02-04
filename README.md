# devboxes
Bootstrapping a devbox for codex and me

## Manual Setup

If `devbox new` fails, can do this manually

```
sudo apt install -y golang-go gh
cd ~/code
git clone https://github.com/zahan-oai/devboxes.git
cd devboxes
./setup.sh
cd ~/code/openai
codex login
gh auth login
```

## MCPs

Need to add these to `~/.codex/config.toml` on the devbox

```toml
[mcp_servers.buildkite]
url = "https://mcp.buildkite.com/mcp"

[mcp_servers.notion]
url = "https://mcp.notion.com/mcp"

[mcp_servers.datadog]
url = "https://mcp.datadoghq.com/api/unstable/mcp-server/mcp"

[mcp_servers.ologs]
command = "mcp-proxy"
args = ["--transport", "streamablehttp", "https://obs-mcp-default-internal.gateway.obs-1.internal.api.openai.org/ologs/mcp"]

[mcp_servers.kepler-api]
command = "oaipkg"
args = ["run", "kepler_mcp.mcp.cli"]
```

Then run on the devbox

```zsh
codex mcp login buildkite
codex mcp login notion
codex mcp login datadog
```

Copy the URL it spits out to your local browser, once that redirects to a `localhost` / `127.0.0.1` URL - take that back to another tab on your devbox and `wget` it.
