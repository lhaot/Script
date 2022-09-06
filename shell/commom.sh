#!/bin/zsh
# if not zsh use echo -e

_FONT_COLOR_RESET='\033[0m'
_FONT_COLOR_RED='\033[31m'
_FONT_COLOR_GREEN='\033[32m'
_FONT_COLOR_YELLOW='\033[33m'
_FONT_COLOR_BLUE='\033[34m'
_FONT_COLOR_GREY='\033[37m'

function echoRed() {
    echo "${_FONT_COLOR_RED}${1}${_FONT_COLOR_RESET}"
}

function echoGreen() {
    echo "${_FONT_COLOR_GREEN}""${1}""${_FONT_COLOR_RESET}"
}

function echoYellow() {
    echo "${_FONT_COLOR_YELLOW}""${1}""${_FONT_COLOR_RESET}"
}

function echoBlue() {
    echo "${_FONT_COLOR_BLUE}""${1}""${_FONT_COLOR_RESET}"
}

function echoGrey() {
    echo "${_FONT_COLOR_GREY}""${1}""${_FONT_COLOR_RESET}"
}
