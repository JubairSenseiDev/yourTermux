#!/usr/bin/env bash

# yourTermux - finish helper
# Author: JubairSenseiDev

YOURTERMUX_VERSION="1.0.0"

function alertFinish() {

  echo -e "‏‏‎‏‏‎\n    ‎‏‏‎⚠️ Installation Finish, but you need restart Termux to clear setup\n"

}

function alertNotification() {

  termux-notification --sound -t "yourTermux v${YOURTERMUX_VERSION} has been installed"

}

function alertTorch() {

  termux-toast -b "#A8D7FE" -c "#373E4D" -g middle "yourTermux v${YOURTERMUX_VERSION} has been installed"

}

function mainAlert() {

  alertFinish
  alertNotification
  alertTorch

}
