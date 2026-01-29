
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
