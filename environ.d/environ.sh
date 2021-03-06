#! /bin/bash

Welcome_to $BASH_SOURCE

set_paths () {
    OLD_PATH=$PATH
    if [[ -d ~/jab ]]; then
        . ~/jab/src/bash/add_to_a_path.sh
        PATH=$(dirname_ $(which python))
        add_to_a_path PATH --start $HOME/bin
        add_to_a_path PATH --index 1 ~/jab/bin
        add_to_a_path PATH --index 2 ~/hub/pysyte/bin
        add_to_a_path PATH --index 3 $HOME/.local
        add_to_a_path PATH --index 4 $HOME/.local/bin
        [[ -d "${VIRTUAL_ENV:-xxx}"/bin ]] && add_to_a_path --index 5 PATH ${VIRTUAL_ENV}/bin
        add_to_a_path PATH /usr/local/gnu
        add_to_a_path PATH /usr/local/bin
        add_to_a_path PATH /bin
        add_to_a_path PATH /usr/bin
        add_to_a_path PATH /usr/local/sbin
        add_to_a_path PATH $HOME/git/bin
        add_to_a_path PATH /opt/local/bin
        add_to_a_path PATH /sbin
        add_to_a_path PATH /usr/sbin
        add_to_a_path PATH /usr/local/go/bin
    else
        echo ~/jab is not a directory
    fi
}

set_bucket () {
    local _src=~/src
    GIT_BUCKET=no_bucket; [[ -d $_src/git/bucket ]] && GIT_BUCKET=$( readlink -f $_src/git/bucket); export GIT_BUCKET
    HG_BUCKET=no_bucket; [[ -d $_src/hg/bucket ]] && HG_BUCKET=$( readlink -f $_src/hg/bucket); export HG_BUCKET
    BUCKET=no_bucket
    if [[ -d $HG_BUCKET ]]; then
        BUCKET=$HG_BUCKET
    elif [[ -d $GIT_BUCKET ]]; then
        BUCKET=$GIT_BUCKET
    fi
    export BUCKET
}

show_dir_colors () {
    local _dircolors=$(which dircolors 2>/dev/null)
    [[ -z $_dircolors ]] && return 1
    local _dircolours=$(realpath $_dircolors)
    [[ -z $_dircolours ]] && return 1
    eval $($_dircolours ~/.dir_colors | sed -e "s/setenv LS_COLORS /export LS_COLORS=/")
}

export_symbols () {
    export EX_OK=0
    export EX_BAD=1
    export EXITSTATUS="$?"
    export FIGNORE=.pyc:.swp:~:.o
    export RE_IP="\<\([0-9]\{1,3\}\.\)\{3\}[0-9]\{1,3\}\>"
    export LOG_LINES_ON_CD_GIT_DIR=7
    if [[ -x /usr/local/bin/which ]]; then
        export WHICH=/usr/local/bin/which
    else
        export WHICH=/usr/bin/which
    fi
    export EDITOR=vim
}

_source_jab_environ () {
    [[ -f ~/jab/environ.d/jab.sh ]] && . ~/jab/environ.d/jab.sh

    # set -x
    set_paths
    # echo $PATH | tr ':' '\n'
    # set +x
    export_symbols
    set_bucket
    # set -x
    show_dir_colors
    # set +x
    shopt -s cdspell
    shopt -s autocd   #Use dir name as a "cd command"
    set -o vi
}

_source_jab_environ

Bye_from $BASH_SOURCE
