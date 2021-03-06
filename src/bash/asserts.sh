#! /bin/cat

Welcome_to $BASH_SOURCE

_trapped="$BASH_SOURCE"

_trace () {
    (set -x; $("$@"))
}

_trap () {
    _trapped=$1
    local _method=$2
    local _args=$*
    (set -e; $_method "$_args")
}

_trap_file () {
    (set -e; _assert_is_file "$@")
}

_test () {
    local _truthiness=$1; shift
    test $_truthiness "$*"
}

_assert () {
    _trap $1 _test "$@"
}

_assert_string () {
    _assert string -n "$*"
}

_assert_is_path () {
    test $1 $2
}

_assert_is_file () {
    _assert_is_path -f $1
}

_assert_path_executable () {
    test -x $1
}

_assert_env_executable () {
    test -x /usr/bin/env $1
}

_assert_which_executable () {
    test -x which $1
}


_assert_executable () {
    _assert_path_executable
    _assert_env_executable
    _assert_which_executable
    _assert_what_executable
}


_assert_path () {
    set -e
    local _result=0
    local _option=$1; shift
    local _name=$2; shift
    local _path=
    test $_option $_name && _path=_name
    if ! test $_option $_path; then
        echo "$_path is not a $_name" >&2
        _result=1
    fi
    set +e
    return $_result
}


_assert_file () {
    [[ -d "$@" ]] || _assert_path -f file "$@" && touch
}

_assert_directory () {
    if  ! _assert_path -d directory "$@"; then
        if [[ -f "$@" ]]; then
            cp "$@" /assertions/$(basename_ "$@")
        fi
        rm -rf "$@"
        mkdir -p "$@"
    fi
    local _base_name=
    if [[ -f "$@" ]]; then
        _base_name=$(basename_ "$@")
        local _temp=/assertions/$_base_name
        rm -rf $_temp
        mv "$@" $_temp
    fi
    [[ -d "$@" ]]
    if _assert_path -d directory "$@"; then
        local _file=
        [[ -f "$@" ]] && _file=$_base_name
    fi
}

# _assert_directory /assertions

_assert_github () {
    _assert_directory ~/hub
    while [[ -n $1 ]]; do
        _assert_directory ~/hub/$1
        echo ~/hub/$1
        shift
    done
}

_assert_what_executable () {
    whype -q $1
}

_assert_which_executable () {
    test -x which $1
}

_assert_env_executable () {
    test -x env $1
}

_assert_env_executable

_assert_path_executable () {
    _trap _trace _assert_path -x $1
}

_assert_executable () {
    _assert_what_executable "$@"  || _assert_env_executable "$@" || _assert_which_executable "$@" || _assert_path_executable "$@"
}

source_script () {
    source-whyp $1
}

_assert_source_script () {
    local _function_name="$1"; shift
    _is_existing_function $_function_name && $_function_name $1
# conditional binary operator expected
    local _script="$1"; shift
    _assert_is_file $_script
    ! _is_existing_function $_function_name || source $_script
# conditional binary operator expected
}

_assert_source_function () {
    local _source_path="$1"; shift
    local _function_name="$1"; shift
    _assert_source_script  $_function_name $_source_path
    _is_existing_function $_function_name  || source_script $_source_path
}

_assert_is_function () {
    _trap function _is_existing_function $1
    _assert_source_function "$@"
# conditional binary operator expected
    set -e
}

_assert_source () {
    _assert_file "$@"
    _assert_is_function source-whyp
    source-whyp "$@"
}

_assert_source-whyp () {
    local _what=$(_assert_github whyp)
    local _what=~/hub/whyp/whyp.sh
    _assert_file $_what
    source $_what
    _assert_source $_what
    _assert_is_function whyp
}


Bye_from $BASH_SOURCE
