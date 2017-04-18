#!/bin/bash

export LC_ALL=en_US.UTF-8

check_(){
    RESULT="$(echo "$4" | sed "$1" "$5")"
    if [ "$RESULT" != "$6" ]; then
        echo "Test failed: $3 ($2)" >&2
        echo "----- expected -----
$6
----- returned -----"
        echo "$RESULT"
        exit 1
    fi
}

# Check BRE
checkb(){
    check_ "-e" "BRE" "$@"
}
# Check ERE
checke(){
    check_ "-E" "ERE" "$@"
}
# Check both
check(){
    checkb "$@"
    checke "$@"
}

fail_(){
    if echo | sed "$1" "$4" &>/dev/null; then
        echo "Test didn't fail as expected: $3 ($2)" >&2
        exit 1
    fi
}

# Fail check BRE
failb(){
    fail_ "-e" "BRE" "$@"
}
# Fail check ERE
faile(){
    fail_ "-E" "ERE" "$@"
}
# Fail check both
fail(){
    failb "$@"
    faile "$@"
}

# Basics

check 'Custom character class' \
'adn
aqv' 's/[b-eq]/x/g' \
'axn
axv'

check 'Negated custom character class' \
'abcdefgh' \
's/[^b-dg-l]/x/g' \
'xbcdxxgh'

check 'Backslash not special in class' \
"a]\\b
a]\\b" \
"1s/[\\m-p]/x/g
2s/[]]/x/g" \
"a]xb
ax\\b"

check 'Ranges' \
'a-e-i
a-e-i' \
'1s/[d-f]/x/g
2s/[d-f-]/x/g' \
'a-x-i
axxxi'

checkb 'Alternation' \
'acd' \
's/b\|c/x/g' \
'axd'
checke 'Alternation' \
'acd' \
's/b|c/x/g' \
'axd'

check 'Escaped character' \
'abc' \
"s/\\061\\x62\\x(99)/x/g" \
'abc'

# Charater classes

check 'Any character' \
'a ;d
efg' \
's/./x/g' \
'xxxx
xxx'

check 'Word character' \
'hello w0r|_d!' \
's/\w/x/g' \
'xxxxx xxx|xx!'

fail 'Word class' \
's/[[:word:]]/x/g'

check 'Upper case' \
'Hell0 W0r|_D' \
's/[[:upper:]]/X/g' \
'Xell0 X0r|_X'

check 'Lower case' \
'Hell0 W0r|_D' \
's/[[:lower:]]/x/g' \
'Hxxx0 W0x|_D'

check 'Whitespace' \
'Hello world	!' \
's/\s/_/g' \
'Hello_world_!'

check 'Whitespace' \
'Hello world	!' \
's/[[:space:]]/_/g' \
'Hello_world_!'

check 'Non-whitespace' \
'Hello world	!' \
's/[^[:space:]]/x/g' \
'xxxxx xxxxx	x'

check 'Digit' \
'H3ll0 W0r|_D' \
's/[[:digit:]]/+/g' \
'H+ll+ W+r|_D'

check 'Hexadecimal digit' \
'H3ll0 W0r|_D' \
's/[[:xdigit:]]/+/g' \
'H+ll+ W+r|_+'

fail 'Octal digit' \
's/[[:odigit:]]/x/g'

check 'Punctuation' \
'+- 01: hello, world! ;) -+' \
's/[[:punct:]]/_/g' \
'__ 01_ hello_ world_ __ __'

check 'Alphabetical characters' \
'+- 01: hello, world! ;) -+' \
's/[[:alpha:]]/x/g' \
'+- 01: xxxxx, xxxxx! ;) -+'

check 'Alphanumerical characters' \
'+- 01: hello, world! ;) -+' \
's/[[:alnum:]]/x/g' \
'+- xx: xxxxx, xxxxx! ;) -+'

fail 'ASCII class' \
's/[[:ascii:]]/x/g'

check 'Character equivalents' \
'Rémi est prêt' \
's/[[=e=]]/_/g' \
'R_mi _st pr_t'

check 'Word boundary' \
'Hello, world' \
's/o\b/x/g' \
'Hellx, world'

check 'Not word boundary' \
'Hello, world' \
's/o\B/x/g' \
'Hello, wxrld'

check 'Begining of line' \
'testing tests' \
's/^t/r/g' \
'resting tests'

check 'End of line' \
'testing tests' \
's/s$/x/g' \
'testing testx'

# Captures and groups

checkb 'Capturing group' \
'Name is Remi!' \
's/^.*is \(.*\)!$/\1/' \
'Remi'
checke 'Capturing group' \
'Name is Remi!' \
's/^.*is (.*)!$/\1/' \
'Remi'

checkb 'Non-capturing parentheses' \
'Some (dumb)text' \
's/(.*)//g' \
'Some text'
checke 'Non-capturing parentheses' \
'Some (dumb)text' \
's/\(.*\)//g' \
'Some text'

checkb 'Backreference' \
'ab be cd cc df' \
's/\([a-z]\)\1/xx/g' \
'ab be cd xx df'
checke 'Backreference' \
'ab be cd cc df' \
's/([a-z])\1/xx/g' \
'ab be cd xx df'

# Look-around not supported in POSIX

# Multiplicity

checkb '0 or 1' \
'bb bab baab baa?b baaab' \
's/baa\?b/x/g' \
'bb x x baa?b baaab'
checke '0 or 1' \
'bb bab baab baa?b baaab' \
's/baa?b/x/g' \
'bb x x baa?b baaab'

checkb '0 or 1 (negative)' \
'bb bab baab baa?b baaab' \
's/baa?b/x/g' \
'bb bab baab x baaab'
checke '0 or 1 (negative)' \
'bb bab baab baa?b baaab' \
's/baa\?b/x/g' \
'bb bab baab x baaab'

checkb '1 or more' \
'bb bab baab ba+b baaab' \
's/ba\+b/x/g' \
'bb x x ba+b x'
checke '1 or more' \
'bb bab baab ba+b baaab' \
's/ba+b/x/g' \
'bb x x ba+b x'

checkb '1 or more (negative)' \
'bb bab baab ba+b baaab' \
's/ba+b/x/g' \
'bb bab baab x baaab'
checke '1 or more (negative)' \
'bb bab baab ba+b baaab' \
's/ba\+b/x/g' \
'bb bab baab x baaab'

checkb 'Specific number (1)' \
'bb bab baab baaab baaaab' \
's/ba\{2\}b/x/g' \
'bb bab x baaab baaaab'
checke 'Specific number (1)' \
'bb bab baab baaab baaaab' \
's/ba{2}b/x/g' \
'bb bab x baaab baaaab'

checkb 'Specific number (closed)' \
'bb bab baab baaab baaaab' \
's/ba\{1,3\}b/x/g' \
'bb x x x baaaab'
checke 'Specific number (closed)' \
'bb bab baab baaab baaaab' \
's/ba{1,3}b/x/g' \
'bb x x x baaaab'

checkb 'Specific number (open left)' \
'bb bab baaab baaaab' \
's/ba\{,3\}b/x/g' \
'x x x baaaab'
checke 'Specific number (open left)' \
'bb bab baaab baaaab' \
's/ba{,3}b/x/g' \
'x x x baaaab'

checkb 'Specific number (open right)' \
'bb bab baaab baaaab' \
's/ba\{2,\}b/x/g' \
'bb bab x x'
checke 'Specific number (open right)' \
'bb bab baaab baaaab' \
's/ba{2,}b/x/g' \
'bb bab x x'
