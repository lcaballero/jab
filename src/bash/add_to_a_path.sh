#! /bin/bash
#
# Based on a file found at https://github.com/jalanb/jab.sh/blob/master/add_to_a_path.sh
# See also ./add_to_path.py and ./add_to_path.test
#

#
# Gonna need python
#
. ~/jab/src/bash/run_python.sh
#
# Once sourced there is one major command:
#
add_to_a_path () {
    if [[ -z $1 ]]; then
        echo "Usage: add_to_a_path <SYMBOL> <new_path>"
        echo "  e.g. add_to_a_path PYTHONPATH /dev/null"
    else
        DOT_PY=~/jab/src/python/add_to_a_path.py
        local new_paths=$(_run_python $DOT_PY "$@")
        if [[ -n $new_paths ]]; then
            eval $1=$new_paths
            export $1
        else
            echo $?
            echo $new_paths
        fi
    fi
}

show_value () {
    local name=${1-SHELL}
    local value=${!name}
    if [[ -z "$value" ]]; then
        echo \$$name is not set
    else
        local where=${2-bash}
        printf "$where has set \$$name to\n\t$value\n"
    fi
}

show_a_path () {
    local setter=${2:-bash}
    local name=${1:-PATH}
    echo "$setter has set \$$name to:"
    local old_ifs=$IFS
    IFS=":"
    local path=
    local paths=${!name}
    for path in $paths
    do
        echo "  $path"
    done
    IFS=$old_ifs
}

show_path () {
    show_a_path PATH "$@"
}

show_ppath () {
    show_a_path PYTHONPATH "$@"
}