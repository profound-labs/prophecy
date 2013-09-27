#!/bin/bash

for i in ./src-tex_epub/*.tex
do
  outfile="./src-html/`basename $i`.html"
  echo $i
  pandoc --smart --normalize -f latex -t html -o "$outfile" "$i"
  sed -i 's/<\/*blockquote>//g' "$outfile"
done
