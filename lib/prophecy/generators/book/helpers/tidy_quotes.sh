#!/bin/bash

for i in ./*.tex
do
	cp "$i" "$i.bak1"
	cat "$i" | sed -f tidy_quotes > "$i.tmp"
	mv "$i.tmp" "$i"
done
