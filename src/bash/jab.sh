#! /bin/cat

# x


# j () { cj; "$@"; }

# xx

# xx

ar () { acquire_require; }

# "r*" could mean "require ...", but it already means means "rm ..."
# so, I'll use "q*"

qh () { ar; [[ -z $1 ]] || require ~/hub/$1; }

qj () { [[ -z $1 ]] && return; ar; [[ -z $1 ]] || require ~/jab/$1; }

# xxx


cjb () { cd ~/jab/src/bash/$1; }

# "rh." means "require ... in ~/hub"

qh0 () { . ~/jab/../what/what.sh; }
qh1 () { . ~/jab/src/bash/hub.sh; }
qha () { . ~/hub/vimack/ackvim.sh; . ~/hub/vimack/grep_vim.sh; }
qhk () { . ~/hub/cde/cde.sh; }
qhw () { . ~/hub/what/what.sh; }


jjl () { (        set -e;         set -n;         date; cj; "$@") >> ~/jab/log/jjj.log 2>&1;
         (set -a; set -e; set -h;         set -x; date; cj; "$@"; echo jjj; date;) >> ~/jab/log/jjj.log 2>&1; }

# "rj." means "require ... in ~/jab"

qja () { require_jab_sh aliases; }
qje () { require_jab_sh environ; }
qjf () { require_jab_sh functons; }
qjh () { require_jab_sh history; }
qjo () { require_jab_sh repo; }
qjr () { require_jab_sh rf; }
qjt () { require_jab_sh prompt; }
qjx () { require_jab_sh x; }
qjs () { qj src/$1; }
qjb () { qjs bash/$1 ; }
qjp () { qjs python/$1; }
qjg () { qjsb git/$1; }


# xxxx

qjbg () { qjsb git/$1; }
qjed () { qj environ.d/$1; }
qjgc () { require_jab_git_sh completion; }
qjgf () { require_jab_git_sh functons; }
qjgs () { require_jab_git_sh source; }
qjsb () { qjs bash/$1; }
qjsp () { qjs python/$1; }

# xxxxx

qjsbg () { qjbg $1; }
qjsps () { qjsp site/$1; }

qjedc () { require_jab_env colour; }
qjedo () { require_jab_env company; }
qjedp () { require_jab_env python; }

# xxxxxx
REQUIRE_ACQUIRED=
acquire_require () {
    [[ -n $REQUIRE_ACQUIRED ]] && return;
    REQUIRE_ACQUIRED=$(date)
    . ~/hub/jab/src/bash/require.sh
}

# xxxxxxx
HUB_ACQUIRED=
require_scripts_under_hub () {
    [[ -n $HUB_ACQUIRED ]] && return;
    HUB_ACQUIRED=$(date)
    qh0; qh1; qha; qhk; qhw;
}

HAVE_ACQUIRED=
require_scripts_under_jab () {
set -x
    require_scripts_under_hub
    [[ -n ~/jab_ACQUIRED ]] && return;
    HAVE_ACQUIRED=$(date)
    acquire_require;
    qjedc; qjedo; qjedp;
    qja; qje; qjf; qjh; qjt; qjo; qjr; qjx;
    qjgc; qjgf; qjgs;
    cj;
set +x
}

require_jab_sh () {
    require_scripts_under_hub
    qjb $1
}

require_jab_git_sh () {
    require_scripts_under_hub
    qjg $1
}

require_jab_env () {
    require_scripts_under_hub
    qjed $1
}

require_jab_git_sh () {
    require_scripts_under_hub
    qjg $1
}

require_jab_git_sh () {
    require_scripts_under_hub
    qjg $1
}

require_jab_sh_all () {
    for f in $( (cj src/bash; ls *.sh;) ); do
        require_jab_sh $f
    done
}

