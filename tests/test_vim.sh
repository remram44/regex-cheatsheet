#!/bin/bash

export LC_ALL=en_US.UTF-8

check(){
    FILE="$(mktemp)"
    echo "$2" >"$FILE"
    exec 3<<<"$3
:w! $FILE
:q!"
    vi -u NONE - <"$FILE" 2<&3-
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

check 'Negated custom character class' \
'abcdefgh' \
':%s/[^b-dg-l]/x/g' \
'xbcdxxgh'

check 'Backslash not special in class' \
"a]\\b
a]\\b" \
":1s/[\\m-p]/x/g
:2s/[]]/x/g" \
"a]xb
ax\\b"

check 'Ranges' \
'a-e-i
a-e-i' \
':1s/[d-f]/x/g
:2s/[d-f-]/x/g' \
'a-x-i
axxxi'

check 'Alternation' \
'acd' \
':%s/b\|c/x/g' \
'axd'

check 'Escaped character' \
'abc' \
":%s/\\061\\x62\\x(99)/x/g" \
'abc'

# Charater classes

check 'Any character' \
'a ;d
efg' \
':%s/./x/g' \
'xxxx
xxx'

check 'Word character' \
'hello w0r|_d!' \
':%s/\w/x/g' \
'xxxxx xxx|xx!'

check 'Upper case' \
'Hell0 W0r|_D' \
':%s/[[:upper:]]/X/g' \
'Xell0 X0r|_X'

check 'Lower case' \
'Hell0 W0r|_D' \
':%s/[[:lower:]]/x/g' \
'Hxxx0 W0x|_D'

check 'Whitespace' \
'Hello world	!' \
':%s/\s/_/g' \
'Hello_world_!'

check 'Whitespace' \
'Hello world	!' \
':%s/[[:space:]]/_/g' \
'Hello_world_!'

check 'Non-whitespace' \
'Hello world	!' \
':%s/[^[:space:]]/x/g' \
'xxxxx xxxxx	x'

check 'Digit' \
'H3ll0 W0r|_D' \
':%s/[[:digit:]]/+/g' \
'H+ll+ W+r|_D'

check 'Hexadecimal digit' \
'H3ll0 W0r|_D' \
':%s/[[:xdigit:]]/+/g' \
'H+ll+ W+r|_+'

check 'Punctuation' \
'+- 01: hello, world! ;) -+' \
':%s/[[:punct:]]/_/g' \
'__ 01_ hello_ world_ __ __'

check 'Alphabetical characters' \
'+- 01: hello, world! ;) -+' \
':%s/[[:alpha:]]/x/g' \
'+- 01: xxxxx, xxxxx! ;) -+'

check 'Alphanumerical characters' \
'+- 01: hello, world! ;) -+' \
':%s/[[:alnum:]]/x/g' \
'+- xx: xxxxx, xxxxx! ;) -+'

check 'Character equivalents' \
'Rémi est prêt' \
':%s/[[=e=]]/_/g' \
'R_mi _st pr_t'

check 'Word boundary' \
'Hello, world' \
':%s/o\>/x/g' \
'Hellx, world'

check 'Begining of line' \
'testing tests' \
':%s/^t/r/g' \
'resting tests'

check 'End of line' \
'testing tests' \
':%s/s$/x/g' \
'testing testx'

# Captures and groups

check 'Capturing group' \
'Name is Remi!' \
':%s/^.*is \(.*\)!$/\1/' \
'Remi'

check 'Non-capturing parentheses' \
'Some (dumb)text' \
':%s/(.*)//g' \
'Some text'

check 'Backreference' \
'ab be cd cc df' \
':%s/\([a-z]\)\1/xx/g' \
'ab be cd xx df'

# Look-around not supported in POSIX

# Multiplicity

check '0 or 1' \
'bb bab baab baa?b baaab' \
':%s/baa\?b/x/g' \
'bb x x baa?b baaab'

check '0 or 1 (negative)' \
'bb bab baab baa?b baaab' \
':%s/baa?b/x/g' \
'bb bab baab x baaab'

check '1 or more' \
'bb bab baab ba+b baaab' \
':%s/ba\+b/x/g' \
'bb x x ba+b x'

check '1 or more (negative)' \
'bb bab baab ba+b baaab' \
':%s/ba+b/x/g' \
'bb bab baab x baaab'

check 'Specific number (1)' \
'bb bab baab baaab baaaab' \
':%s/ba\{2\}b/x/g' \
'bb bab x baaab baaaab'

check 'Specific number (closed)' \
'bb bab baab baaab baaaab' \
':%s/ba\{1,3\}b/x/g' \
'bb x x x baaaab'

check 'Specific number (open left)' \
'bb bab baaab baaaab' \
':%s/ba\{,3\}b/x/g' \
'x x x baaaab'

check 'Specific number (open right)' \
'bb bab baaab baaaab' \
':%s/ba\{2,\}b/x/g' \
'bb bab x x'
