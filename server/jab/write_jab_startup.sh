#! /bin/bash

cat > ~/.profile << EOB
# ~/.profile: executed by the command interpreter for login shells.

[[ \$- != *i* ]] && return
[[ -n $WELCOME_BYE ]] && echo Welcome to $(basename $BASH_SOURCE) in $(dirname $(readlink -f $BASH_SOURCE)) on $(hostname -f)
[[ -n "\$BASH_VERSION" ]] && source ~/.bashrc
[[ -n $WELCOME_BYE ]] && echo Bye from $(basename $BASH_SOURCE) in $(dirname $(readlink -f $BASH_SOURCE)) on $(hostname -f)
echo Bye from /home/jab/.profile
EOB

cat > ~/.bashrc << EOB
# ~/.bashrc: executed by bash(1) for non-login shells.

[[ -n $WELCOME_BYE ]] && echo Welcome to $(basename $BASH_SOURCE) in $(dirname $(readlink -f $BASH_SOURCE)) on $(hostname -f)
if [[ \$- == *i* ]]; then
    [[ -f "~/jab/login.sh" ]] && cd ~/jab && . login.sh && cd >/dev/null 2>&1
fi
[[ -n $WELCOME_BYE ]] && echo Bye from $(basename $BASH_SOURCE) in $(dirname $(readlink -f $BASH_SOURCE)) on $(hostname -f)
echo Bye from /home/jab/.bashrc
EOB

echo "# ~/.bash_logout: executed by bash(1) when login shell exits" > ~/.bash_logout
