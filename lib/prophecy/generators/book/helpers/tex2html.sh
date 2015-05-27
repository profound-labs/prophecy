#!/bin/bash

for i in ./tex/*.tex
do
    sed -f sed_tex2uni $i |\
    # for dumb E-book readers, problematic characters with latin
    # No longer necessary.
    # sed -f sed_dumb_ebook |\
    sed -f sed_chars > tmp/`basename $i`
done

for i in ./tmp/*.tex
do
    echo "## File: $i"
    echo ""
    
    sed -i -e 's/^ *//; s/ *$//; /^%/d' $i
    cat $i | sed -e '/^\\looseness=-*[0-9] *$/d; /^\\index[[][^]]\+[]][{].\+[}] *$/d;' |\
    sed -e 's/\(\w\)\\-\(\w\)/\1\2/g; s/\([[:alnum:]]\)~\+\([[:alnum:]]\)/\1 \2/g; s/\\noindent//g; s/\\clearpage//g; s/\\\\/<br \/>/g; s/\\linebreak\\//g; s/\\linebreak[{][}]\\//g; s/\\linebreak//g; s/\\thinspace//g;' |\
    sed 's/\\textsuperscript[{]\([^}]\+\)[}]/<span class="superscript">\1<\/span>/g' |\
    # sed -e 's/\\ldots\\/\&hellip;/g; s/\\ldots[{][}]/\&hellip;/g;' |\ 
    sed -e 's/\\ldots\\/.../g; s/\\ldots[{][}]/.../g;' |\
    sed 's/\\section[*]*[{]\([^}]\+\)[}]/<h3 class="section">\1<\/h3>/g' |\
    sed 's/\\subsection[*]*[{]\([^}]\+\)[}]/<h3 class="subsection">\1<\/h3>/g' |\
    sed '/^\\vspace[*][{][^}]\+[}] *$/d' |\
    sed -e '1{/./{s/^/<p>\n/}}; 1{/^$/{s/^/<p>/}};' |\
    sed -e '${/./{s/$/\n<\/p>/}}; ${/^$/{s/$/<\/p>/}};' |\
    sed 's/\\mbox[{]\([^}]\+\)[}]/\1/g' |\
    # sed 's/\\glsdisp[{]\([^}]\+\)[}][{]\([^}]\+\)[}]/<a class="glslink" href="glossary.html#\1">\2<\/a>/g' |\ 
    sed 's/\\glsdisp[{]\([^}]\+\)[}][{]\([^}]\+\)[}]/\2/g' |\
    # sed 's/\\glslink[{]\([^}]\+\)[}][{]\([^}]\+\)[}]/<a class="glslink" href="glossary.html#\1">\2<\/a>/g' |\ 
    sed 's/\\glslink[{]\([^}]\+\)[}][{]\([^}]\+\)[}]/\2/g' |\
    sed 's/\\qaitem[{]\([^}]\+\)[}]/<i>\1<\/i>/g' |\
    sed -e 's/\\dropcaps[{]\([^}]\+\)[}][{]\([^}]\+\)[}]/\1\2/; s/\\pali[{]\([^}]\+\)[}]/<i>\1<\/i>/g; s/\\textit[{]\([^}]\+\)[}]/<i>\1<\/i>/g;' |\
    # sed 's/\\footnote[{]\([^}]\+\)[}]/<span class="footnote">\1<\/span>/g' |\ 
    sed -e 's/\\begin[{]verse[}]/<blockquote>/g; s/\\end[{]verse[}]/<\/blockquote>/g;' |\
    sed 's/^$/<\/p><p>/' > "$i.tmp"
    
    # process footnotes
    
    FN=1
    remains=-1
    prev_rem=-2
    
    echo -n "" > "$i.tmp.footnotes"
    
    while [ ! $remains -eq 0 ]
    do
        
        if [ $remains -eq $prev_rem ]; then
            echo -e "\n* WARNING! Remainin footnotes? $remains lines\n"
            grep -nE '\\footnote[{][^}]+[}]' "$i.tmp" | sed -e 's/^/    /; s/$/\n/'
            echo ""
            break
        fi
        
        # for now, dealing with one-liner footnotes only
        
        converted_lines=""
        line=$(grep -noE '\\footnote[{][^}]+[}]' "$i.tmp" | sed -e '1!d; s/^\([0-9]\+\):.*/\1/')
        
        while [ "$line" != "" ]
        do
            converted_lines="$converted_lines $line"
            cat "$i.tmp" | sed -e ''$line'!d; s/^.*\\footnote[{]\([^}]\+\)[}].*$/<p><a href="#ref'$FN'" id="fn'$FN'"><span class="superscript">'$FN'<\/span>:<\/a> \1<\/p>/; ' >> "$i.tmp.footnotes"
            
            sed -i -e "$line"'{ s/\\footnote[{]\([^}]\+\)[}]/<a href="#fn'$FN'" id="ref'$FN'"><span class="superscript">'$FN'<\/span><\/a>/ }' "$i.tmp"
            
            ((FN++))
            line=$(grep -noE '\\footnote[{][^}]+[}]' "$i.tmp" | sed -e '1!d; s/^\([0-9]\+\):.*/\1/')
        done
        
        prev_rem="$remains"
        remains=$(grep -cE '\\footnote[{][^}]+[}]' "$i.tmp")
    done
    
    if [ "$converted_lines" != "" ]; then
        echo "Converted footnotes on lines: $converted_lines"
    fi
    
    echo ""
    
    echo -e -n "\n\n" >> "$i.tmp"
    cat "$i.tmp.footnotes" >> "$i.tmp"
    rm "$i.tmp.footnotes"
    
    # check for remaining commands, braces, and other chars
    
    c=$(grep -cE '\\[a-zA-Z]' "$i.tmp")
    if [ ! $c -eq 0 ]; then
        echo -e "* WARNING! Remaining commands? $c lines\n"
        grep -nE '\\[a-zA-Z]' "$i.tmp" | sed -e 's/^/    /; s/$/\n/'
        echo ""
    fi
    
    c=$(grep -cE '[{}]' "$i.tmp")
    if [ ! $c -eq 0 ]; then
        echo -e "* WARNING! Remaining braces? $c lines\n"
        grep -nE '[{}]' "$i.tmp" | sed -e 's/^/    /; s/$/\n/'
        echo ""
    fi
    
    chars="~%"
    c=$(grep -cE '['$chars']' "$i.tmp")
    if [ ! $c -eq 0 ]; then
        echo -e "* WARNING! Remaining $chars ? $c lines\n"
        grep -nE '['$chars']' "$i.tmp" | sed -e 's/^/    /; s/$/\n/'
        echo ""
    fi
    
    mv "$i.tmp" "$i.html"
    
done
