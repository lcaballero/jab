#! /bin/bash

if [[ $- =~ i ]]; then
    test -d ~/.local_login.sh && source ~/.local_login.sh
    LOCAL=/usr/local
    [[ -d $LOCAL/gnu ]] && LOCALS="$LOCAL/gnu:$LOCAL/bin" || LOCALS="$LOCAL/bin"
    BINS=/usr/bin:/bin:/usr/sbin:/sbin
    HOMES=$HOME/bin:$HOME/.local
    export PATH=$LOCALS:$BINS:$HOMES
    [[ -d $LOCAL/go/bin ]] && PATH=$PATH:$LOCAL/go/bin

    source ~/jab/__init__.sh

    export PS1="\$? [\u@\h:\$PWD]\n$ "

    vbb () {
        vim -p ~/.bashrc ~/jab/__init__.sh "$@" +/bash
        ls -l ~/.bashrc ~/jab/__init__.sh
    }

    export PS1="\$? [\u@\h:\$PWD]\n$ "

    # set -x
    j
    # set +x
    sp
    # clock # fucks with terminal, leave off
fi
