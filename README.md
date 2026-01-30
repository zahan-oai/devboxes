# devboxes
Bootstrapping a devbox for codex and me

## Manual Setup

If `devbox new` fails, can do this manually

```
sudo apt install golang-go
cd ~/code
git clone https://github.com/zahan-oai/devboxes.git
cd devboxes
./setup.sh
cd ~/code/openai
codex login
gh auth login
```
