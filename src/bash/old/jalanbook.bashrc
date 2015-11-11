#! /bin/bash -x

# echo Welcome to $JAB/bashrc

_show_status () {
    if [[ -d "$JAB"/.svn ]]; then
        svn stat "$JAB"
    elif [[ -d "$JAB"/.git ]]; then
        git -C "$JAB" status | \
        grep -v "nothing to commit, working directory clean" | \
        sed -e s:Your.branch:\$JAB: | \
        grep --color 'up-to-date.*'
    fi
    local jab_src_bash=$JAB/src/bash
    require $JAB/src/bash/git/functions
    require $JAB/src/bash/subversion/aliases
    require $JAB/src/bash/subversion/functions
}

source_path () {
    local __doc__='Local function in case cannot find the real one'
    [[ -f "$1" ]] && source "$@"
}

_get_source_path_from_what () {
    GITHUB=${GITHUB:-~/src/git/hub}
    local what_script=$(readlink -f $GITHUB/what/what.sh)
    if [[ -f "$what_script" ]]; then
        source "$what_script"
    else
        echo "$what_script is not a file" >&2
        return 1
    fi
}

_source_jab_scripts () {
    require "$JAB/environ"
    require "$JAB/python-environ"
    require "$JAB/envirok/environ"
    require "$JAB/envirok/python-environ"
    require "$JAB/local/network"
    require "$JAB/aliases"
    require "$JAB/functons"
    require "$JAB/prompt"
    requite "$HUB/kd/kd.sh"
    requite "$HUB/ack2vim/ack2vim"
}

_if_not_python_try_home_bin () {
    PYTHON=${PYTHON:-no_python}
    if [[ $PYTHON == no_python ]]; then
        local python_in_home=$HOME/bin/python
        [[ -x "$python_in_home" ]] && PYTHON=$python_in_home
    fi
    export PYTHON
}

_remove_jab_tmp_files () {
    /bin/rm -rf "$JAB"/tmp/*
}

_show_todo () {
    builtin cd "$JAB/src/python"
    if python2.7 -c"a=0" >/dev/null 2>&1; then
        [[ -f "todo.py" ]] && mython todo.py
    else
        local version=$(mython -V 2>&1)
        echo "Python version is old ($version)"
    fi
    builtin cd - >/dev/null 2>&1
}

_show_welcome () {
    _show_todo
    if pgrep -fl vim > /dev/null; then
        echo
        echo --------------------
        echo vim sessions running
        echo --------------------
        pgrep -fl vim | grep -v -e YouCompleteMe -e bash.*vim.sh
    fi
    _show_status
    _remove_jab_tmp_files
    echo
    echo "Welcome jab, to $HOSTNAME"
    echo
}

_set_up_symbols () {
    unset JAB
    local github_jab_dir=$(readlink -f ~/src/git/hub/dotjab)
    local myhome_jab_dir=$(readlink -f ~/.jab)
    bash_jab_dir=$(dirname $(readlink -f "$BASH_SOURCE"))
    if [[ $bash_jab_dir == $github_jab_dir ]]; then
        JAB=$github_jab_dir
    elif [[ $bash_jab_dir == $myhome_jab_dir ]]; then
        if [[ -f "$github_jab_dir/bashrc" ]]; then
            echo "Warn: Using $myhome_jab_dir/bashrc, while $github_jab_dir/bashrc exists" >&2
        fi
        JAB=$myhome_jab_dir
    fi
    if [[ -n $JAB ]]; then
        export JAB
    else
        echo "Could not find this script in" $myhome_jab_dir $github_jab_dir
        unset JAB
        return 1
    fi
    return 0
}

_jab_bashrc () {
    _get_source_path_from_what
    _source_jab_scripts
    _if_not_python_try_home_bin
}

_bashrc () {
    _jab_bashrc
    _show_welcome
}

_no_symbols () {
    echo "i am lost because \$JAB ($JAB) is not a directory" >&2
}

run_interactively () {
    _set_up_symbols || _no_symbols
    [[ -d "$JAB" ]] && _bashrc
}

#set -x
[[ $- =~ i ]] && run_interactively
#set +x
builtin cd $JAB