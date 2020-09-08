# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# # set variable identifying the chroot you work in (used in the prompt below)
# if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
#     debian_chroot=$(cat /etc/debian_chroot)
# fi
#
# # set a fancy prompt (non-color, unless we know we "want" color)
# case "$TERM" in
#     xterm-color) color_prompt=yes;;
# esac
#
# # uncomment for a colored prompt, if the terminal has the capability; turned
# # off by default to not distract the user: the focus in a terminal window
# # should be on the output of commands, not on the prompt
# #force_color_prompt=yes
#
# if [ -n "$force_color_prompt" ]; then
#     if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
# 	# We have color support; assume it's compliant with Ecma-48
# 	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
# 	# a case would tend to support setf rather than setaf.)
# 	color_prompt=yes
#     else
# 	color_prompt=
#     fi
# fi
#
# if [ "$color_prompt" = yes ]; then
#     PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
# else
#     PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
# fi
# unset color_prompt force_color_prompt
#
# # If this is an xterm set the title to user@host:dir
# case "$TERM" in
# xterm*|rxvt*)
#     PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
#     ;;
# *)
#     ;;
# esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi


# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi


#
# added by Mine
#
export EDITOR='vim'
alias nano='vim'
alias emacs='vim'

# for vimrc C-s remap
stty -ixon

# cd
alias ..='cd ..'
alias ...='cd ../..'

# ls
alias ls='ls --color=auto --show-control-chars --time-style=long-iso -FH'
alias la='ls -A'
cdls ()
{
    \cd "$@" && ls
}
alias cd="cdls"

# some more aliases
# apt
alias install='sudo apt-get install'
alias reinstall='sudo apt-get install --reinstall'
alias update='sudo apt-get update'
alias upgrade='sudo apt-get upgrade'
alias dupgrade='sudo apt-get dist-upgrade'
alias autoremove='sudo apt-get autoremove'
# figure
alias eps2pdf='for fig in *.eps; do magick -density 300 $fig ${fig%.*}.pdf ; done'
# git
alias ga='git add '
alias gaa='git add .'
alias gcm='git commit -m '
alias gstt='git status'
alias gss='git stash save'
alias gpuo='git push -u origin '
alias gpl='git pull'
# Drive
alias ggldrv='fusermount -u ~/GoogleDrive; google-drive-ocamlfuse ~/GoogleDrive'
# Mendeley
alias mendeley='mendeleydesktop'

# add branch name
# color, host, color, :, color, pwd, color, branch, color, $, color
PS1='\[\e[1;36m\]\u\[\e[00m\]:\[\e[1;35m\]\W\[\e[1;33m\] $(__git_ps1)\[\e[1;33m\]$ \[\e[00m\]'
# git-completion.bash / git-prompt.sh
if [ -f /path/to/git-completion.bash ]; then
    source /path/to/git-completion.bash
fi
if [ -f /path/to/git-prompt.sh ]; then
    source /path/to/git-prompt.sh
fi
GIT_PS1_SHOWDIRTYSTATE=true
GIT_PS1_SHOWUNTRACKEDFILES=true
GIT_PS1_SHOWSTASHSTATE=true
GIT_PS1_SHOWUPSTREAM=auto

if [ "$(expr substr $(uname -s) 1 5)" == 'Linux' ]; then
  echo "You Are in Linux"
  # source /opt/ros/melodic/setup.bash
  # source ~/catkin_ws/devel/setup.bash

  alias cw='cd ~/catkin_ws'
  alias cs='cd ~/catkin_ws/src'
  alias cm='cd ~/catkin_ws && catkin_make'

  export ROS_IP=`hostname -I | cut -d' ' -f1`

  alias cmatlab='matlab -nojvm -nodisplay -nosplash'
  export PYTHONPATH=$PYTHONPATH:$HOME/LeapSDK/lib:$HOME/LeapSDK/lib/x64

  alias grsimMain='~/SSL/grSim/bin/grSim'
  alias grsimClient='~/SSL/grSim/bin/client'
  alias sslRefbox='cd ~/SSL/ssl-refbox && ./sslrefbox'

  export TERMINAL=xfce4-terminal
#  export DISPLAY=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}'):0
else
  echo "You Are in MSYS2 or Git-Bash"
  export PATH=$PATH:mingw64/bin
  export PATH=$PATH:mingw32/bin

  # anti Windows garbling
  function wincmd()
  {
      CMD=$1
      shift
      $CMD $* 2>&1 | iconv -f CP932 -t UTF-8
  }
  alias cmd='winpty cmd'
  alias psh='winpty powershell'
  alias ipconfig='wincmd ipconfig'
  alias netstat='wincmd netstat'
  alias netsh='wincmd netsh'
fi

if [[ $(ps -e| grep i3 | grep -v grep |wc -l) -eq 0 ]] ;then
	/mnt/c/Program\ Files/VcXsrv/vcxsrv.exe -ac &
	i3 &
fi

