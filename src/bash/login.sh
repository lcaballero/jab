#! /bin/bash

test -f ~/.local_login.sh && source ~/.local_login.sh

LOCAL=/usr/local
[[ -d $LOCAL/gnu ]] && LOCALS="$LOCAL/gnu:$LOCAL/bin" || LOCALS="$LOCAL/bin"
BINS=/usr/bin:/bin:/usr/sbin:/sbin
HOMES=$HOME/bin:$HOME/.local
export PATH=$LOCALS:$BINS:$HOMES
[[ -d $LOCAL/go/bin ]] && PATH=$PATH:$LOCAL/go/bin

SRC=~/src
HG=$SRC/hg
GIT=$SRC/git
HUB=$GIT/hub
export HUB

source $HUB/jab/bash.sh


vbb () {
    vim -p ~/.bashrc $HUB/jab/bash.sh +/bash
}

export PS1="\$? [\u@\h:\$PWD]\n$ "

# set -x
jj
# set +x
