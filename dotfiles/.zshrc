
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# START OpenAI shrc

autoload -U compinit; compinit -i -C

# OpenAI shrc (if customising, comment out to prevent it getting readded)
for file in "/home/dev-user/.openai/shrc"/*; do
    source "$file"
done

. "$HOME/.local/bin/env"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
export HISTFILE=/home/dev-user/.commandhistory/.zsh_history
export HISTSIZE=1000000
export SAVEHIST=1000000
setopt INC_APPEND_HISTORY_TIME
setopt EXTENDED_HISTORY

# Try and use the link created by applied_devbox_cli/cli.py
if [ -S "/tmp/ssh-$USER.sock" ]; then
    export SSH_AUTH_SOCK="/tmp/ssh-$USER.sock"
fi
export API_REPO_PATH="/home/dev-user/code/openai/api"
source ~/.api_shell_include
source /home/dev-user/code/openai/api/applied-devtools/completions/applied_completions.zsh

# END OpenAI shrc

# User configuration
# In an anonymous function to avoid leaking the local variables to the shell
function() {

  # add rust binaries to path
  rust_bin="$HOME/.cargo/bin"
  [[ -d $rust_bin ]] && PATH="$PATH:$rust_bin"

  pybase=$(python -m site --user-base)
  [[ -d "$pybase/bin" ]] && PATH="$PATH:$pybase/bin"

  # POWERLEVEL10K
  # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
  [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

  export LSCOLORS='GxFxCxDxBxegedabagaced'
  export EDITOR='vi'

  . "$HOME/.cargo/env"

}
