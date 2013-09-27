#!/bin/sh
# check for typical typos in the body text

# find un-accented spelling of Pali
grep -iE -f pali_typos ./*.tex

# find - instead of -- 
grep -E '[^[:alpha:]-]-[^[:alpha:]-]' ./*.tex
# %s/\([^[:alpha:]-]\)-\([^[:alpha:]-]\)/\1--\2/gc

# find ... instead of \ldots{}
grep -E '\.\.\.' ./*.tex

# find un-smart double quotes
# find un-smart single quotes
grep -E " '{1,2}\w" ./*.tex
grep -E ' "{1,2}\w' ./*.tex
# %s/ '\{1,2\}\(\w\)/ `\1/gc
# sed -i 's/ '"'"'\(\w\)/ `\1/g' ./*.tex

# find wrong quote and puncuation placement
grep -E '['"'"'"]{1,2}[,;:.?!]' ./*.tex
# sed -i 's/\(['"'"'"]\)\([,;:.?!]\)/\2\1/g' ./*.tex

# will not match a footnote w/ {} inside
grep -E '\\footnote\{[^}]+\}[,;:.?!]' ./*.tex

