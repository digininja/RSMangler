RSMangler: Take a wordlist and mangle it
========================================

Copyright(c) 2012, RandomStorm Limited - www.randomstorm.com  
Robin Wood <robin@digininja.org>  
Version 1.4

RSMangler will take a wordlist and perform various manipulations on it similar
to those done by John the Ripper with a few extras. The main new feature is
permutations mode which takes each word in the list and combines it with the
others to produce all possible permutations (not combinations, order matters).
For example the words freds, fresh, fish will produce the following list:

```
freds
fresh
fish
fredsfresh
fredsfish
freshfreds
freshfish
fishfreds
fishfresh
fredsfreshfish
fredsfishfresh
freshfredsfish
freshfishfreds
fishfredsfresh
fishfreshfreds
```

It also creates an acronym from the words in order, for example the terms
```
proactive
security
management
```
would give the acronym "psm". This acronym is then added to the list of terms used
in the rest of the mangling.

Each of these new words is then subject to the other mangles, because of this I
strongly recommend with permutations mode enabled (default) you use a very small
wordlist, 3 start words create a final list containing 5345 words and 5 start
words creates a list containing 108557. As a test we tried it with a few hundred
words and gave up when the process memory usage hit 3G.

If you try to use a file with more than 5 words you will get a warning and the
option to abort.

Other mangles include adding the numbers 1 to 123 to the start and end, 01 to 09
to the start and end, various case manipulations, leet speak, word reversal, ed
and ing on the end and doubling words up.

New mangles in 1.1 are adding all years between 1990 and this year to the start
and end and adding sys, admin, pw and pwd to the start and end.

The initial wordlist can either be specified as a file or can be piped in
through STDIN.

Installation
============

Just make the script executable, it doesn't rely on any gems or anything
external.

Usage
=====

Note, all mangle options are ON by default, these parameters turn them OFF

```
rsmangler.rb [OPTION]

--help, -h: show help
--file, -f: the input file, use - for STDIN
--perms, -p: permutate all the words
--double, -d: double each word
--reverse, -r: reverser the word
--leet, -t: l33t speak the word
--full-leet, -T: all posibilities l33t
--capital, -c: capitalise the word
--upper, -u: uppercase the word
--lower, -l: lowercase the word
--swap, -s: swap the case of the word
--ed, -e: add ed to the end of the word
--ing, -i: add ing to the end of the word
--punctuation: add common punctuation to the end of the word
--pna: add 01 - 09 to the end of the word
--pnb: add 01 - 09 to the beginning of the word
--na: add 1 - 123 to the end of the word
--nb: add 1 - 123 to the beginning of the word
--years: add all years from 1990 to current year to start and end
--acronym: create an acronym based on all the words entered in order and add to word list
--common: add the following words to start and end: admin, sys, pw, pwd
--force: don't give the warning about list length
```

Change Log
==========

- 1.4 - Added full leetspeak option, thanks Felipe Molina (@felmoltor)
- 1.3 - Support for Ruby 1.9.x

Licence
=======

This project released under the Creative Commons Attribution-Share Alike 2.0
UK: England & Wales

( http://creativecommons.org/licenses/by-sa/2.0/uk/ )

Credits
=======

Full credit to Gavin Watson (h4nd13) who had the original idea for this project and
has helped test at every stage.

Bugs, Comments, Feedback
========================

Feel free to get in touch, robin.wood@randomstorm.com
