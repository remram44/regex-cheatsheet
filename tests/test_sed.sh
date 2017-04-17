#!/bin/bash

check_(){
    RESULT="$(echo "$3" | sed "$1" "$4")"
    if [ "$RESULT" != "$5" ]; then
        echo "Test failed: $2" >&2
        echo "----- expected -----
$5
----- returned -----"
        echo "$RESULT"
        exit 1
    fi
}

# Check BRE
checkb(){
    check_ "-e" "$@"
}
# Check ERE
checke(){
    check_ "-E" "$@"
}
# Check both
check(){
    checkb "$@"
    checke "$@"
}

# Basics

check 'Custom character class' \
'adn
aqv' 's/[b-eq]/x/g' \
'axn
axv'
