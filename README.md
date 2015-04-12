Cheatsheet for regex syntaxes
=============================

Many software use regular expression to find & replace text. However, they tend
to come with their own different flavor.

You can probably expect most modern software and programming languages to be
using the Perl flavor, "PCRE"; however command-line tools (grep, less, ...)
often use the POSIX flavor (sometimes with an extended variant, e.g. `egrep` or
`sed -r`). ViM also comes with its own syntax (a superset of what Vi accepts).

This cheatsheet lists the respective syntax they each use.

If you spot errors or missing data, or just want to make this prettier/more
accurate, don't hesitate to open an [issue][is] or a [pull request][pr].

The rendered cheatsheet is available here: [regex cheatsheet][cc]

Note that this is still a work in progress; a lot of entries need some details
in some kind of tooltip.


[cc]: http://htmlpreview.github.io/?https://github.com/remram44/regex-cheatsheet/blob/master/regex.html
[is]: https://github.com/remram44/regex-cheatsheet/issues/new
[pr]: https://github.com/remram44/regex-cheatsheet/compare/
