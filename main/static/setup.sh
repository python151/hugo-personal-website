# Installs zsh
sudo apt-get install zsh -y

# Installs the Nix package manager
yes | sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --daemon

# Sets up zsh config
cat << EOF > ~/.zshrc
autoload -U colors && colors
PS1="%{\$fg[red]%}%n%{\$reset_color%}@%{\$fg[blue]%}%m %{\$fg[yellow]%}%~ %{\$reset_color%}%% "
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word
EOF
