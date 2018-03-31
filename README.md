Cheatsheet for regex syntaxes
=============================

[![Say Thanks!](https://img.shields.io/badge/Say%20Thanks-!-1EAEDB.svg)](https://saythanks.io/to/remram44)

Many programs use regular expression to find & replace text. However, they tend
to come with their own different flavor.

You can probably expect most modern software and programming languages to be
using some variation of the Perl flavor, "PCRE"; however command-line tools
(grep, less, ...) often use the POSIX flavor (sometimes with an extended
variant, e.g. `egrep` or `sed -r`). ViM also comes with its own syntax (a
superset of what Vi accepts).

This cheatsheet lists the respective syntax they each use.

If you spot errors or missing data, or just want to make this prettier/more
accurate, don't hesitate to open an [issue][is] or a [pull request][pr].

The rendered cheatsheet is available here: [regex cheatsheet][cc]

Note that this is still a work in progress; a lot of entries need some details
in some kind of tooltip.


[cc]: https://remram44.github.io/regex-cheatsheet/regex.html
[is]: https://github.com/remram44/regex-cheatsheet/issues/new
[pr]: https://github.com/remram44/regex-cheatsheet/compare/
