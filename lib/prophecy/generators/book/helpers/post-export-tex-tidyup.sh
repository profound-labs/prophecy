#!/bin/bash

SRC="$1"

if [ -z "$1" ]; then
    echo "First argument missing: .tex file to tidy."
    exit 2
fi

cat "$1" |\
# Replace {\textbackslash}{\textbackslash} with \\
sed -e 's/[{]\\textbackslash[}][{]\\textbackslash[}] */\\\\\n/g' |\
# Remove =\textcolor[model]{values}{...}=
# Remove =\textcolor{color}{...}=
# First with no inner braces, then up to three inner pair of braces, then just remove the command and leave the brace.
sed -e \
's/\\textcolor[[][^]]\+[]][{][^{}]\+[}][{]\([^{}]\+\)[}]/\1/g;
s/\\textcolor[[][^]]\+[]][{][^{}]\+[}][{]\([^{]*[{][^{}]\+[}][^}]*\)[}]/\1/g;
s/\\textcolor[[][^]]\+[]][{][^{}]\+[}][{]\([^{]*[{][^{]*[{][^{}]\+[}][^}]*[}][^}]*\)[}]/\1/g;
s/\\textcolor[[][^]]\+[]][{][^{}]\+[}][{]\([^{]*[{][^{]*[{][^{]*[{][^{}]\+[}][^}]*[}][^}]*[}][^}]*\)[}]/\1/g;
s/\\textcolor[[][^]]\+[]][{][^{}]\+[}][{]/{/g;
s/\\textcolor[{][^{}]\+[}][{]\([^{}]\+\)[}]/\1/g;
s/\\textcolor[{][^{}]\+[}][{]\([^{]*[{][^{}]\+[}][^}]*\)[}]/\1/g;
s/\\textcolor[{][^{}]\+[}][{]\([^{]*[{][^{]*[{][^{}]\+[}][^}]*[}][^}]*\)[}]/\1/g;
s/\\textcolor[{][^{}]\+[}][{]\([^{]*[{][^{]*[{][^{]*[{][^{}]\+[}][^}]*[}][^}]*[}][^}]*\)[}]/\1/g;
s/\\textcolor[{][^{}]\+[}][{]/{/g;' |\
# Remove =\textstyle*=, no inner braces, then up to three inner pair of braces, then just remove the command and leave the brace.
sed -e \
's/\\textstyle[a-zA-Z]*[{]\([^{}]\+\)[}]/\1/g;
s/\\textstyle[a-zA-Z]*[{]\([^{]*[{][^{}]\+[}][^}]*\)[}]/\1/g;
s/\\textstyle[a-zA-Z]*[{]\([^{]*[{][^{]*[{][^{}]\+[}][^}]*[}][^}]*\)[}]/\1/g;
s/\\textstyle[a-zA-Z]*[{]\([^{]*[{][^{]*[{][^{]*[{][^{}]\+[}][^}]*[}][^}]*[}][^}]*\)[}]/\1/g;
s/\\textstyle[a-zA-Z]*[{]/{/g;' |\
# Replace =[1E43?]= character subs.
sed -e \
's/[[]1E6D?[]]/ṭ/g;
s/[[]1E47?[]]/ṇ/g;
s/[[]1E45?[]]/ṅ/g;
s/[[]1E41?[]]/ṁ/g;
s/[[]1E43?[]]/ṃ/g;
s/[[]1E0D?[]]/ḍ/g;
s/[[]1E37?[]]/ḷ/g;' |\
# TODO Replace non-breaking space and zero-width space.
# Remove commands with empty braces
sed -e 's/\\[a-zA-Z]\+[{] \+[}]/ /g' |\
# Remove spaces from beginning and end of braces
sed -e \
's/\(\\[a-zA-Z]\+[{]\) \+/ \1/g;
s/\(\\[a-zA-Z]\+[{][^{}]\+\) \+[}]/\1} /g;' |\
# Fix tricky accent commands that trip up =pandoc=.
sed 's/\\=\\i/ī/g' |\
# =\MakeUppercase= and =\MakeLowercase= is swallowed by =pandoc=.
# Remove the command and leave the empty braces.
sed -e 's/\\MakeUppercase//g; s/\\MakeLowercase//g;' |\
tee "$1".tidy.tex |\
# === Converting to markdown ===
pandoc -f latex -t markdown --no-wrap |\
tee "$1".md |\
# Remove ​, conversion artefact
sed 's/​//g' |\
# Remove <span> tags, these remain from removing the \textcolor and \textstyle commands.
sed 's/<\/*span>//g' |\
# Normalize bold and italics
sed 's/\(\*\*[^\*]\+\)\*\* \+\*\*\([^\*]\+\*\*\)/\1 \2/g' |\
sed 's/\(\*[^\*]\+\)\* \+\*\([^\*]\+\*\)/\1 \2/g' |\
tee "$1".tidy.md |\
# === Converting to LaTeX ===
pandoc -f markdown -t latex --no-wrap |\
# Linebreaks
sed 's/\\\\/&\n/g' |\
# Remove double nbsp (tabs are exported as two escaped spaces from ODT).
sed 's/~~//g' > "$1".md.tex
