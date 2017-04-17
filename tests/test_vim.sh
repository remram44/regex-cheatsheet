#!/bin/bash

check(){
    FILE="$(mktemp)"
    echo "$2" >"$FILE"
    exec 3<<<"$3
:w! $FILE
:q!"
    vi - <"$FILE" 2<&3-
    if [ "$(cat "$FILE")" != "$4" ]; then
        echo "Test failed: $1" >&2
        echo "----- expected -----
$4
----- returned -----"
        cat "$FILE"
        rm "$FILE"
        exit 1
    fi
    rm "$FILE"
}

# Basics

check 'Custom character class' \
'adn
aqv' ':%s/[b-eq]/x/g' \
'axn
axv'
