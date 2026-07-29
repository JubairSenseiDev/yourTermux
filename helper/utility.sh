#!/usr/bin/env bash
# yourTermux - Author: JubairSenseiDev - https://github.com/JubairSenseiDev/yourTermux

function utility() {

  cp ~/.fonts/JetBrains\ Mono\ Medium\ Nerd\ Font\ Complete.ttf $PREFIX/share/fonts/TTF/ 2> /dev/null
  
  chsh -s zsh

  if [[ -f $PREFIX/etc/motd ]]; then
    
    mkdir $HOME/motd/
    mv $PREFIX/etc/motd $HOME/motd/motd.backup

  fi

}
