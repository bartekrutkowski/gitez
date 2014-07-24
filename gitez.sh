#!/bin/sh

#
# Gitez.sh - easy tool for synchronizing gitolite hosted git repositories
# Copyright Bartek Rutkowski <contact+gitez.sh at robakdesign dot com>
#

#
# functions
#

printc () {
# $1 - msg is obligatory, $2 - color (red/green)of the message, default if not passed
    if [ -t 1 ]; then
        if [ $# -eq 2 ]; then
            if [ $2 == "red" ]; then
                echo -e "\033[1;31m$1\033[m"
            elif [ $2 == "green" ]; then
                echo -e "\033[1;32m$1\033[m"
            else
                echo "$1"
            fi
        fi
    else
        echo $1
    fi
}


#
# main loop
#

execute=0
uri=
dir=

while [ $# -gt 0 ]
do
    case "$1" in
        -e) execute=1;;
        -u) uri="$2"; shift;;
        -d) dir="$2"; shift;;
        --) shift; break;;
        -*) echo >&2 \
            "Gitez usage: $0 -u uri [-d dir] [-e]"
            exit 1;;
        *) break;;
    esac
    shift
done

repos=`ssh git@github.com -n 2> /dev/null | grep "^\ R\ W" | \
    awk '{ print $3 }'`

if [ $# -lt 1 ]
then
    path=`pwd`
    msg="No path specified, using $path as repositories location."
    printc "$msg" "red"
else
    path=$1
    msg="Using $path as repositories location."
    printc "$msg" "green"
fi

for repo in $repos
do
    cd $path
    if [ -d "$repo" ]
    then
        echo "Found existing $repo repository, updating."
        git -C $repo pull
    else
        echo "*** Repository $repo is missing, cloning."
        git clone git@git.tsg.bskyb.com:$repo
    fi
done
