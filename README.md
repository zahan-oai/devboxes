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

### Buildkite

Need to add this to `~/.codex/config.toml` on the devbox

```toml
[mcp_servers.buildkite]
url = "https://mcp.buildkite.com/mcp"
```

Then run on the devbox

```zsh
codex mcp login buildkite
```
