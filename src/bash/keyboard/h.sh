#! /usr/bin/env kat -n

. ~/bash/history.sh

Welcome_to $BASH_SOURCE

# _
# x

h () {
    local __doc__="tail history"
    local _options=$(( $LINES / 2 ))
    history_tail "$@" $_options
}

# _x
# xx

alias HG=$(which hg) # With apologies, but don't really use it

h1 () {
    history_tail 2 | head -n 1
}

hg () {
    local __doc__="grep in history"
    history_parse | grep -v '^hg ' | grep --color "$@"
}

alias hh="history_head"

hl () {
    h "$@" | less
}

alias ht="history_tail"

hv () {
    local __doc__="edit history"
    history_parse "$@" > ~/tmp/history.tmp
    local _vim_suffix=+
    if [[ -n $* ]]; then
        _vim_suffix=+/"$@"
        [[ "$@" =~ ^+ ]] && _vim_suffix="$@"
    fi
    vim ~/tmp/history.tmp $_vim_suffix
}

# xxx

hgt () {
    local __doc__="grep and tail history"
    hg "$@" | tail
}

Bye_from $BASH_SOURCE
hgv () 
{ 
    local __doc__="edit history";
    local _vim_suffix=+
    if [[ -n $* ]]; then
        _vim_suffix=+/"$@";
        [[ "$@" =~ ^+ ]] && _vim_suffix="$@";
    fi
    h "$@" > ~/tmp/history.tmp
    vim ~/tmp/history.tmp $_vim_suffix;
    rr ~/tmp/history.tmp
}


# premature abbreviations

alias hn=history_count
alias hnh="history_count head"
alias hnt=history_count

# history_xxxx+


history_parse () {
    HISTTIMEFORMAT= history "$@" | sed -e "s/^ *[0-9]*  //"  | grep -v "\<\(history\|[tg]h\)\>" 
}

history_count () {
    history_view "$@" | cat -n
}

history_view () {
    local __doc__="view history"
    local _viewer=
    whyp-executable "$1" && _viewer="$1"
    [[ $_viewer ]] && shift || _viewer=tail
    local _options="-n $(( $LINES - 7 ))"
    [[ $1 == -n ]] && shift
    if [[ $1 =~ ^[0-9] ]]; then
        _options="-n $1"
        shift
    fi
    history_parse "$@" | $_viewer $_options
}

history_head () {
    history_view head "$@"
}

history_tail () {
    history_view tail "$@"
}
