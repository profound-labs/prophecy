% Anecdote Class
%
% A memoir-based documentclass with a contemporary style for books with a lighter content.
%
% https://github.com/profound-labs/anecdote
%
% http://profound-labs.github.io/projects/anecdote/
%
% (c) Gambhiro Bhikkhu, 2016
% gambhiro.bhikkhu.85@gmail.com
%
% LPPL LaTeX Pubic Project Licence
%

% TODO: document interfaces
% TODO: test document to compile

% ==============
% Identification
% ==============

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{anecdote}[2016/02/01 v0.9 A memoir-based documentclass with a contemporary style for books with a lighter content.]

% ========================
% Preliminary Declarations
% ========================

\newif\ifwebversion
\webversionfalse

% =======
% Options
% =======

\RequirePackage{pgfopts}
\RequirePackage{calc}

\pgfkeys{
  /BOOK/.cd,
  pagePreset/.default=largepage,% "largepage": 6x9in, "smallpage": 5.25x8in
  pagePreset/.store in=\BOOK@pagePreset,
  babelLanguage/.default=british,
  babelLanguage/.store in=\BOOK@babelLanguage,
  webversion/.code=\webversiontrue,
}

% Pass all unknown options to memoir
\DeclareOption*{%
  \PassOptionsToClass{\CurrentOption}{memoir}
}

\ProcessPgfOptions{/BOOK}
\ProcessOptions\relax

% ======================
% All Other Declarations
% ======================

\LoadClass[11pt,twoside]{memoir}

% === Book Core ===

\RequirePackage[\BOOK@babelLanguage]{babel}
\RequirePackage{nag}
\RequirePackage{xparse}
\RequirePackage{soul}
\RequirePackage{textcomp}
\RequirePackage[cmyk]{xcolor}
\RequirePackage{graphicx}
% Add your \graphicspath declaration to your local style.
\RequirePackage{eso-pic}
\RequirePackage{ccicons}
\RequirePackage{multicol}
\RequirePackage{ifthen}
\RequirePackage{titletoc}
\RequirePackage{enumitem}
\RequirePackage{tikz}
\usetikzlibrary{positioning}

% === Define colors ===

\definecolor{textbody}{gray}{0.15}
\definecolor{footnoterule}{gray}{0.5}
\definecolor{chapternum}{gray}{0.8}
\definecolor{chaptertitle}{gray}{0.3}
\definecolor{chapterauthor}{gray}{0.3}
\definecolor{chapternote}{gray}{0.3}
\definecolor{section}{gray}{0.3}
\definecolor{tocleftside}{gray}{0.5}
\definecolor{tocleftsidepart}{gray}{0.2}
\definecolor{partname}{gray}{0.5}
\definecolor{parttitle}{gray}{0.5}
\definecolor{linkborder}{rgb}{0.4,0.4,1}% light blue
\definecolor{link}{rgb}{0.2,0.2,1}% not so light blue

% === Load fonts ===

\RequirePackage{fontspec}
\defaultfontfeatures{Ligatures={TeX}}

% Dummy font commands to use system defaults instead of custom fonts

% TODO: comment these out and define them below as \newfontfamily

\newcommand\crimsonRomanFont{}
\newcommand\crimsonRomanFontOldNum{}
\newcommand\gentiumFont{}
\newcommand\headerFont{}
\newcommand\footFont{}
\newcommand\pageNumFont{}
\newcommand\partTitleFont{}
\newcommand\chapterNameFont{}
\newcommand\chapterTitleFont{}
\newcommand\chapterNumberFont{}
\newcommand\chapterAuthorFont{}
\newcommand\chapterNoteFont{}
\newcommand\sectionFont{}
\newcommand\tocFont{}
\newcommand\tocFontOldNum{}

% If -- dashes don't work for your font, try
% Renderer = Basic
% http://tex.stackexchange.com/questions/20580/how-to-enable-ligatures-for-emdash-endash-in-luatex

%% by filename:

%\setmainfont[
%  Path = {./fonts/},
%  SmallCapsFont = Crimson-Roman.otf,
%  SmallCapsFeatures= { Ligatures = TeX, Letters = SmallCaps },
%  ItalicFont = GentiumPlus-I.ttf,
%  BoldFont = GenBkBasB.ttf,
%  BoldItalicFont = GenBkBasBI.ttf,
%]{GentiumPlus-R.ttf}
%
%\newfontfamily\crimsonRomanFont[
%  Path = {./fonts/},
%  ItalicFont = Crimson-Italic.otf,
%  BoldFont = Crimson-Semibold.otf,
%  BoldItalicFont = Crimson-SemiboldItalic.otf,
%]{Crimson-Roman.otf}
%
%\newfontfamily\crimsonRomanFontOldNum[
%  Path = {./fonts/},
%  Numbers = OldStyle,
%]{Crimson-Roman.otf}
%
%\newfontfamily\gentiumFont[
%  Path = {./fonts/},
%]{GentiumPlus-R.ttf}

%% or by name:

%\setmainfont[
%  SmallCapsFont = Crimson Roman,
%  SmallCapsFeatures= { Ligatures = TeX, Letters = SmallCaps },
%  BoldFont = Gentium Book Basic Bold,
%]{Gentium}

%\newfontfamily\crimsonRomanFont[
%  BoldFont = Crimson Semibold,
%  ItalicFont = Crimson Italic,
%]{Crimson Roman}
%\newfontfamily\crimsonRomanFontOldNum[
%  Numbers = OldStyle,
%]{Crimson Roman}
%\newfontfamily\gentiumFont{Gentium}

% header and footer

%% by filename:

%\newfontfamily\footFont[
%  Path = {./fonts/},
%  %Renderer = Basic,
%]{Crimson-Roman.otf}

%% or by name:

%\newfontfamily\footFont[Renderer = Basic]{Shaker Pali}

\newcommand{\footSize}
  {\@setfontsize\footSize{9}{9}}

% chapter

%\newfontfamily\partTitleFont[
%  ItalicFont = Shaker 2 Light Italic,
%  %Renderer = Basic,
%]{Crimson Roman}
%
%\newfontfamily\chapterNameFont{Crimson Roman}
%\newfontfamily\chapterTitleFont{Crimson Roman}
%\newfontfamily\chapterNumberFont{Crimson Roman}
%\newfontfamily\chapterAuthorFont{Crimson Roman}
%\newfontfamily\chapterNoteFont[
%  BoldFont = Crimson Semibold,
%  ItalicFont = Crimson Italic,
%]{Crimson Roman}

% Some default font sizes, use \renewcommand to adjust

\newcommand{\chapterNameSize}
  {\@setfontsize\chapterNameSize{22}{24}}
\newcommand{\chapterNumberSize}
  {\@setfontsize\chapterNumberSize{22}{24}}
\newcommand{\chapterTitleSize}
  {\@setfontsize\chapterTitleSize{13}{16.5}}
\newcommand{\chapterAuthorSize}
  {\@setfontsize\chapterAuthorSize{12}{14}}
\newcommand{\chapterNoteSize}
  {\@setfontsize\chapterNoteSize{10}{13}}
\newcommand{\pageNumSize}
  {\@setfontsize\pageNumSize{10}{12}}

% section

%\newfontfamily\sectionFont[
%  BoldFont = Crimson Semibold,
%  ItalicFont = Crimson Italic,
%]{Crimson Roman}

\newcommand{\sectionSize}
  {\@setfontsize\sectionSize{13}{15}}

% other sizes

\newcommand{\smaller}
  {\@setfontsize\smaller{9}{11}}

\newcommand{\copyrightsize}
  {\@setfontsize\smaller{9}{11}}

% === microtype ===

\RequirePackage[final,babel=true]{microtype}
\SetTracking[spacing={500,100,}]{encoding=*, family=chapterTitleFont}{40}

% === hyperref ===

\RequirePackage{hyperref}

\ifwebversion
% Web version: colored link text
\hypersetup{
  unicode=true,
  colorlinks=true,
  linkcolor=link,
  citecolor=link,
  filecolor=link,
  urlcolor=link
}
\else
% Desktop version: link colors to text color, so that it doesn't
% interfere with printing, but can still test is link targets work.
\hypersetup{
  colorlinks=true,
  unicode=true,
  linkcolor=textbody,
  citecolor=textbody,
  filecolor=textbody,
  urlcolor=textbody
}
\fi

\RequirePackage[
  open,
  openlevel=2
]{bookmark}

% === penalties and hyphenation ===

% memoir's more allowing penalties
\midsloppy

% FIXME: only if babel is english or british
\renewcommand\britishhyphenmins{{3}{3}}

% The lastparline or the parfillskip solution is overkill in many
% places. It is optimal for larger paragraphs, but creates too much
% strech in every other case, particulary not in the main text, such as
% the TOC and so on.
%
% It can be useful with a limited scope, but for general application it
% becomes more of a problem to check where it has gone too far in
% adjusting line breaks.

% lastparline:
%   ``Ensures that the last line of a paragraph is at least as long as the
%   double value of \parindent. When LuaTEX is used, the solution provided
%   by Patrick Gundlach is used. With other rendering engines, it is the
%   native solution provided by Enrico Gregorio that serves as an
%   implementation.''
% http://tex.stackexchange.com/questions/28357/ensure-minimal-length-of-last-line/

% Load with draft option to visualize inserted nobreaks.
% \RequirePackage[lastparline]{impnattypo}

% Alternatively, egreg's native solution:
% http://tex.stackexchange.com/a/28358/831
%\setlength{\parfillskip}{0pt plus\dimexpr\textwidth-2\parindent}

% Last line at least 20% of textwidth
%\parfillskip 0pt plus 0.8\textwidth

\hyphenpenalty=700
\exhyphenpenalty=50
\doublehyphendemerits=900
%\finalhyphendemerits=5000 % default is 5000
\brokenpenalty=990

\RequirePackage[defaultlines=2,all]{nowidow}

% === common hyphenation exceptions and corrections ===

\hyphenation{season wisdom develop-ment respon-sible pheno-mena
philo-sophical munindo amaravati thai-land}

%\hyphenation{accur-ately argu-men-ta-tive attach Ayu-dhaya becomes
%ben-e-fi-cial capa-bil-ity car-ry car-ry-ing cere-monies cere-mony
%ces-sa-tion chal-lenge chal-leng-ing clas-si-fi-ca-tion
%clas-si-fi-ca-tions clas-si-fied com-mu-nity con-di-tion
%con-di-tioned con-struc-tions con-tem-plate con-tem-plat-ing
%con-tem-pla-tion cul-ti-vate cul-ti-vates cul-ti-vat-ing
%cul-ti-vation def-i-ni-tion de-ter-mine de-ter-mined dhamma dhammas
%dis-cern-ment dis-con-tent dis-cur-sive dying em-pha-size
%enlight-ened equa-nim-ity es-pe-cial-ly estab-lish exist-ence
%ex-pe-ri-ence hap-pen-ing having ig-no-rance immedi-ately
%im-per-ma-nent in-nu-mer-a-ble in-se-cu-ri-ty in-spir-ing
%in-struct-ed in-ves-ti-gate in-ves-ti-ga-tion iso-late iso-lat-ed
%Keuan lay-peo-ple ma-te-ri-al mat-u-ra-tion medi-tate medi-ta-tion
%medi-ta-tive mental mon-as-teries mon-as-tery Nana-chat or-dain
%or-dain-ed or-di-na-tion orig-inate oth-er-wise pene-trat-ing
%per-son-al per-son-al-ity phe-nom-e-na phe-nom-e-non po-si-tion
%pow-er pow-ers pre-vi-ous pro-lif-er-ate pro-lif-er-ating
%pro-lif-er-a-tions puthu-jjana quest-ion rec-i-ta-tion
%sat-is-fac-tory sen-sa-tion sen-sa-tions sim-i-lar suf-fer-ing
%sup-po-si-tion syn-on-y-mous tem-per-a-ment tem-per-a-ments tong-rat
%tran-scend tran-scend-ent tran-scends un-con-di-tioned under-stand
%under-stood un-hap-pi-ness un-sat-is-fac-tori-ness un-sat-is-fac-tory
%ven-er-able wea-ri-ness what-ev-er when-ever wher-ever whole-hearted
%whole-heart-edly wrong-do-ing}

% === soul settings ===

\sodef\soTocChapter{}{.1em}{.5em plus.1em}{.1em plus.1em minus.1em}
\sodef\soSection{}{.07em}{.4em plus.1em}{.1em plus.1em minus.1em}
% Using \textls letterspacing with microtype instead, because soul swallows accented characters at the end of words.
%\sodef\soChapter{}{.06em}{.4em plus.1em}{.1em plus.1em minus.1em}

% === Custom commands and environments ===

\newcommand\dividerRule{%
{\centering\bigskip
{\color[gray]{0.6}\rule{0.6\linewidth}{0.2pt}}
\par\bigskip}%
}

\newcommand\emptysheet{%
  \cleardoublepage
  \thispagestyle{empty}\mbox{}\newpage
  \thispagestyle{empty}\mbox{}\newpage
}

\newcommand\emptydoublepage\emptysheet

\newcommand\emptypage{%
  \clearpage
  \thispagestyle{empty}\mbox{}\newpage
}

\newcommand*{\subtitle}[1]{\def\@thesubtitle{#1}}
\newcommand*{\editionInfo}[1]{\def\@theEditionInfo{#1}}
\newcommand*{\printedByInfo}[1]{\def\@thePrintedByInfo{#1}}
\newcommand*{\publisher}[1]{\def\@thePublisher{#1}}
\newcommand*{\ISBN}[1]{\def\@theISBN{#1}}

\newcommand\thesubtitle{\@thesubtitle}
\newcommand\theEditionInfo{\@theEditionInfo}
\newcommand\thePrintedByInfo{\@thePrintedByInfo}
\newcommand\thePublisher{\@thePublisher}
\newcommand\theISBN{\@theISBN}

\newsavebox{\quotepagebox}
\newenvironment{quotepage}[1]
  {\begin{lrbox}{\quotepagebox}\begin{minipage}{#1}
   \setlength{\parskip}{0.6\baselineskip}
   \setlength{\parindent}{0pt}}
  {\end{minipage}\end{lrbox}%
   \begin{tikzpicture}[remember picture,overlay]
   \node at (current page.center) {\usebox{\quotepagebox}};
   \end{tikzpicture}}

\newenvironment{packeditemize}%
{\begin{itemize}[
  itemindent=0pt,
  leftmargin=15pt,
  rightmargin=0pt,
  itemsep=4pt,
  topsep=0pt,
  parsep=0pt,
  partopsep=0pt,
]%
}{\end{itemize}}

\newlength\qw
\setlength\qw{17pt}% same as parindent for smallpage

\newcommand{\question}[1]{%
  \smallskip%
  \par\noindent\hangindent=\qw%
  \ifthenelse{\equal{#1}{}}{\textit{Q:}\space}{\textit{#1:}\space}%
}

\newcommand{\questionBi}[2]{%
  \smallskip%
  \par\noindent\hangindent=\qw%
  \textit{Q: #1}
  \smallskip%
  \par\noindent\hangindent=\qw%
  \textit{Q: #2}
}

\newcommand{\answer}[1]{%
  \smallskip%
  \par\noindent%
  \ifthenelse{\equal{#1}{}}{\textit{A:}\space}{\textit{#1:}\space}%
}

% If class option webVersion is used, show content in a paper sized
% minipage, empty page otherwise.
% Redefine \color{webcoverbg} to change page background color.
\newcommand\webcover[1]{%
\thispagestyle{empty}\mbox{}
\ifwebversion
\AddToShipoutPictureFG*{\put(0,0){%
\begin{minipage}[b][\paperheight][c]{\paperwidth}%
#1
\end{minipage}}}
\fi
\clearpage
}

% === Renewing package macros ===

\addtodef{\mainmatter}{}{%
  \addtocontents{toc}{\addvspace{18pt}}%
  \setcounter{chapter}{0}%
}

\addtodef{\appendix}{}{%
  \addtocontents{toc}{\addvspace{18pt}}%
  \bookmarksetup{startatroot}%
}

\addtodef{\backmatter}{}{%
  \addtocontents{toc}{\addvspace{18pt}}%
  \bookmarksetup{startatroot}%
}

\renewenvironment{quote}%
{\small
\list{}{\rightmargin\leftmargin}%
\item[]}%
{\endlist}

\newcommand\quoteref[1]{%
\par
{\footnotesize #1}
\par
}

\renewcommand\footnoterule{%
  \vspace*{\baselineskip}%
  \kern-3\p@
  {\color{footnoterule}\hrule height 0.25pt width \columnwidth}
  \kern2.6\p@}

\renewcommand*{\notesname}{Notes}
\renewcommand*{\notedivision}{\chapter{\notesname}}
%\renewcommand*{\notedivision}{\section*{\notesname}}
\renewcommand*{\pagenotesubhead}[3]{}
\renewcommand*{\notenumintext}[1]{\textsuperscript{\thinspace [#1]}}
\renewcommand{\prenoteinnotes}{\par\noindent\hangindent=17pt}
\renewcommand{\postnoteinnotes}{\par\vspace*{0.5\baselineskip}}

% === Page styles ===

\nouppercaseheads

% define page styles with names about "what it does"

\newcommand{\sepline}{%
  \hspace{6pt}%
  \raisebox{-0.3\baselineskip}{\rule{0.2pt}{1.2\baselineskip}}%
  \hspace{6pt}%
}
\makepagestyle{topbottomcentered}
\makeevenhead{topbottomcentered}{}{\textit{\rightmark}}{}
\makeevenfoot{topbottomcentered}{}{\thepage}{}
\makeoddhead{topbottomcentered}{}{\textit{\leftmark}}{}
\makeoddfoot{topbottomcentered}{}{\thepage}{}

\makepagestyle{bottomcorner}
\makeevenhead{bottomcorner}{}{}{}
\makeevenfoot{bottomcorner}{%
  \footFont\footSize%
  \thepage \sepline \leftmark%
}{}{}
\makeoddhead{bottomcorner}{}{}{}
\makeoddfoot{bottomcorner}{}{}{%
  \footFont\footSize%
  \rightmark \sepline \thepage%
}

\makepagestyle{bottomcenter}
\makeevenhead{bottomcenter}{}{}{}
\makeevenfoot{bottomcenter}{}{%
  \footFont\footSize%
  \thepage%
}{}
\makeoddhead{bottomcenter}{}{}{}
\makeoddfoot{bottomcenter}{}{%
  \footFont\footSize%
  \thepage%
}{}

% alias the pagestyles into semantic names, "where it is used"

\aliaspagestyle{normalpage}{bottomcorner}
\aliaspagestyle{chapter}{bottomcenter}
\aliaspagestyle{part}{empty}
\aliaspagestyle{afterpart}{empty}

\pagestyle{normalpage}

% === TOC settings ===

\maxtocdepth{section}

% Fixes Undefined control sequence error for \@chapapp@head
\renewcommand\chapternumberline[1]{\numberline{#1}}
\renewcommand\partnumberline[1]{\numberline{#1}}

% Fixes Missing number error when chapter number is not numeric, as in
% Appendix A
\let\ttll@appendix\ttll@chapter

\newcommand*\l@chapternote{\@nodottedtocline{0}{6pc}{1pc}{1pc}}

\def\@nodottedtocline#1#2#3#4#5#6{%
  \ifnum #1>\c@tocdepth \else
    %\vskip \z@ \@plus.2\p@
    \vspace*{-3pt}
    {\footnotesize\itshape\crimsonRomanFont
     \leftskip #2\relax
     \rightskip \@tocrmarg
     \advance\rightskip #3\relax
     \parfillskip -\rightskip
     \parindent #2\relax\@afterindenttrue
     \interlinepenalty\@M
     \leavevmode
     \@tempdima #4\relax
     \advance\leftskip \@tempdima \null\nobreak\hskip -\leftskip
     {#5}\nobreak
     \leaders\hbox{$\m@th
        \mkern \@dotsep mu\hbox{\,}\mkern \@dotsep
        mu$}\hfill
     \nobreak
     \hb@xt@\@pnumwidth{\hfil\normalsize\normalfont}%
     \par}%
  \fi}

\def\tocChapterNote#1{%
    \addcontentsline{toc}{chapternote}{%
    \noexpand\numberline{}#1}%
}

% the right TOC margin
\contentsmargin{0pt}

\newlength\tocLeftWidth
\setlength\tocLeftWidth{6pc}

% FIXME: the first Part heading in the TOC will also add that 20pt
% vspace. How to add it only before a Part that follows a Chapter?

\titlecontents{part}[\tocLeftWidth]
{\addvspace{20pt}%
\normalsize\tocFont}%
{%
  \contentsmargin{0pt}%
  \makebox[0pt][r]{%
  {\color{tocleftsidepart}\partname~\thecontentslabel}%
  \hspace*{0.5em}$\cdot$\hspace*{0.5em}}%
}
{\contentsmargin{0pt}}
{\hfill\normalsize\tocFont\thecontentspage}
[\addvspace{5pt}]

\titlecontents{chapter}[\tocLeftWidth]
{\normalsize\tocFont}%
{%
  \contentsmargin{0pt}%
  \makebox[0pt][r]{%
    {\color{tocleftside}%
    \chaptername~{\tocFontOldNum\thecontentslabel}}%
    \hspace*{0.5em}$\cdot$\hspace*{0.5em}%
  }%
}
{\contentsmargin{0pt}%
\itshape}
{\enspace\hfill\normalsize\tocFont\thecontentspage}
[\addvspace{5pt}]

\titlecontents{appendix}[\tocLeftWidth]
{\normalsize\tocFont}%
{%
  \contentsmargin{0pt}%
  \makebox[0pt][r]{%
    {\color{tocleftside}%
    \appendixname~{\tocFontOldNum\thecontentslabel}}%
    \hspace*{0.5em}$\cdot$\hspace*{0.5em}%
  }%
}
{\contentsmargin{0pt}%
\itshape}
{\hfill\normalsize\tocFont\thecontentspage}

\titlecontents{section}[\tocLeftWidth]
{\addvspace{-2pt}%
\small\tocFont}
{\contentslabel[\thecontentslabel]{\tocLeftWidth}}
{}
{\hfill\normalsize\tocFont\thecontentspage}

\titlecontents*{subsection}[\tocLeftWidth]
{\addvspace{-1pt}%
\small\tocFont}
{}
{}
{\ --- \thecontentspage}
[ \textbullet\ ][]

% === Book styles ===

% === Part styles ===

\newif\ifthisparthastitle
\thisparthastitletrue

\newif\ifthisparthasnote
\thisparthasnotefalse

\newcommand*{\thePartNote}{}
\newcommand*{\partNote}[1]{%
  \thisparthasnotetrue%
  \renewcommand*\thePartNote{#1}%
}

\renewcommand{\partnamefont}{\Huge\partTitleFont\color{partname}}
\renewcommand{\partnumfont}{\Huge\partTitleFont\color{partname}}
\renewcommand{\parttitlefont}{\large\partTitleFont\color{parttitle}\MakeUppercase}
\renewcommand*{\midpartskip}{\par\vskip 10pt}%

% FIXME: Currently, if there isn't a part title, we have to do
% \part{\space} to still create the part line in the TOC and the
% bookmark index.
%
% It would be better if the index had ``Part One'', and the TOC would
% handle it better too.

\long\def\@part[#1]#2{%
  \M@gettitle{#1}%
  \phantomsection
  \ifnum \c@secnumdepth >-2\relax
  \refstepcounter{part}%
  \addcontentsline{toc}{part}%
  {\protect\partnumberline{\thepart}#1}%
  \mempartinfo{\thepart}{#1}{#2}%
  \else
  \addcontentsline{toc}{part}{#1}%
  \mempartinfo{}{#1}{#2}%
  \fi
  \partmark{#1}%
  {%
    \raggedright
    \hspace*{\chapterTitleLeftSkip}%
    \begin{minipage}{\linewidth - \chapterTitleLeftSkip}
      \raggedright
      \interlinepenalty \@M
      \parskip\z@
      \ifthisparthasnote
        \thePartNote
        \par
        \global\thisparthasnotefalse
        \midpartskip
      \fi
      \normalfont
      \ifnum \c@secnumdepth >-2\relax
        \resizebox{2.8cm}{!}{\printpartname \partnamenum \printpartnum}
        \par\vskip 20pt
      \fi
      \ifthisparthastitle
        \printparttitle{#2}
      \else
        \global\thisparthastitletrue
      \fi
      \par%
    \end{minipage}%
    \par%
  }%
\@endpart}

% === Chapter styles ===

\setsecnumdepth{chapter}

% define chapter styles with "fantasy" names

\newif\ifchapterauthor
\chapterauthorfalse

\newcommand*{\theChapterAuthor}{}
\newcommand*{\chapterAuthor}[1]{%
  \chapterauthortrue%
  \renewcommand*{\theChapterAuthor}{#1}%
}

\newcommand\chapterAuthorFmt[1]{%
  \chapterAuthorFont\chapterAuthorSize\color{chapterauthor}%
  #1%
}

\newif\ifchapternote
\chapternotefalse

\newcommand\chapterNoteFmt[1]{%
  \chapterNoteFont\chapterNoteSize\color{chapternote}%
  \itshape #1%
}

\newcommand*{\theChapterNote}{}
\newcommand*{\chapterNote}[1]{%
  \chapternotetrue%
  \renewcommand*\theChapterNote{#1}%
}

\newif\ifchapterfootnote
\chapterfootnotefalse

\newcommand*{\theChapterFootnoteMark}{}
\newcommand*{\theChapterFootnoteText}{}
\newcommand*{\chapterFootnote}[2][\footnotemark]{%
  \chapterfootnotetrue%
  \renewcommand*\theChapterFootnoteMark{#1}%
  \renewcommand*\theChapterFootnoteText{\footnotetext{#2}}%
}

\newlength\chapterTitleLeftSkip
\setlength{\chapterTitleLeftSkip}{17pt}

\makechapterstyle{lowtitle}{
  \chapterstyle{default}
  \setlength{\beforechapskip}{30mm}
  \setlength{\chapterTitleLeftSkip}{17pt}
  \renewcommand\printchaptername{}
  \renewcommand\chapternamenum{}
  \renewcommand\chapnumfont{\chapterNumberFont\chapterNumberSize}
  \renewcommand\printchapternum{%
    \chapnumfont\color{chapternum}%
    \hspace*{\chapterTitleLeftSkip}\thechapter%
  }
  \setlength{\midchapskip}{2\onelineskip}
  \renewcommand\afterchapternum{\par\nobreak\vskip \midchapskip}
  \renewcommand\printchapternonum{}
  \renewcommand\chaptitlefont{\chapterTitleFont\chapterTitleSize}
  \renewcommand*\printchaptertitle[1]{%
    \raggedright\hspace*{\chapterTitleLeftSkip}%
    \parbox{\linewidth - \chapterTitleLeftSkip}{%
      \raggedright\chaptitlefont\color{chaptertitle}%
      \textls*{\MakeUppercase{##1}}%
      \ifchapterfootnote%
        \hspace*{2pt}\theChapterFootnoteMark%
      \fi%
      \ifchapterauthor%
        \vskip 0.5\onelineskip%
        \chapterAuthorFmt{\theChapterAuthor}%
        \global\chapterauthorfalse%
      \fi%
      \ifchapternote%
        \vskip 0.5\onelineskip%
        \chapterNoteFmt{\theChapterNote}%
        \global\chapternotefalse%
      \fi%
    }%
    \ifchapterfootnote%
      \theChapterFootnoteText%
      \global\chapterfootnotefalse%
    \fi%
  }
  \setlength{\afterchapskip}{2.5\onelineskip}
  \renewcommand\afterchaptertitle{\par\nobreak\vskip \afterchapskip}%
}

\makechapterstyle{hightitle}{
  \chapterstyle{lowtitle}
  \setlength{\beforechapskip}{0pt}
  \setlength{\chapterTitleLeftSkip}{6pc}
}

\makechapterstyle{bellatrix}{%
  \chapterstyle{default}
  \setlength{\beforechapskip}{40mm}
  \setlength{\chapindent}{0.5in}
  \setlength{\midchapskip}{-2pt}
  \setlength{\afterchapskip}{32pt}
  \renewcommand\chapnumfont{%
    \chapterNumberFont%
    \chapterNumberSize%
    \color{chapternum}%
    \itshape%
  }
  \renewcommand\chapnamefont{\chapnumfont}
  \renewcommand\chaptitlefont{%
    \chapterTitleFont%
    \chapterTitleSize%
    \color{chaptertitle}%
    \upshape%
  }
  \renewcommand\afterchapternum{\par\nobreak\vspace*{\midchapskip}}
  \renewcommand\printchaptername{\hspace*{\chapindent}\chapnamefont \@chapapp}
  \renewcommand\chapternamenum{\space}
  \renewcommand\printchapternum{\chapnumfont \numtoName{\c@chapter}}
  \renewcommand\printchapternonum{\vspace*{-47pt}}
  \renewcommand*\printchaptertitle[1]{%
    \begin{adjustwidth}{\chapindent}{}
      \raggedright%
      {\chaptitlefont\textls{\MakeUppercase{##1}}}%
      \ifchapterfootnote%
        \hspace*{0.8mm}\theChapterFootnoteMark%
      \fi%
      \ifchapterauthor%
        \vskip 0.5\onelineskip%
        \chapterAuthorFmt{\theChapterAuthor}%
        \global\chapterauthorfalse%
      \fi%
      \ifchapternote%
        \vskip 0.5\onelineskip%
        \chapterNoteFmt{\theChapterNote}%
        \global\chapternotefalse%
      \fi%
    \end{adjustwidth}%
    \ifchapterfootnote%
      \theChapterFootnoteText%
      \global\chapterfootnotefalse%
    \fi%
  }
}

% Commands to assign the chapter styles to book parts. Use \renewcommand
% to adjust.

\newcommand\frontmatterChapterStyle{\chapterstyle{hightitle}}
\newcommand\mainmatterChapterStyle{\chapterstyle{lowtitle}}
\newcommand\appendixChapterStyle{\chapterstyle{hightitle}}
\newcommand\backmatterChapterStyle{\chapterstyle{hightitle}}

% append them to the macros
\addtodef{\frontmatter}{}{\frontmatterChapterStyle}
\addtodef{\mainmatter}{}{\mainmatterChapterStyle}
\addtodef{\appendix}{}{\appendixChapterStyle}
\addtodef{\backmatter}{}{\backmatterChapterStyle}

% === Section styles ===

% TODO: could use \makeheadstyles to keep bundle different chapter and
% section style together. See memoir manual '6.9 Predefined heading
% styles'.

\raggedbottomsection

\setbeforesecskip{-3.5ex \@plus -1ex \@minus -.2ex}
\setaftersecskip{2.3ex \@plus .2ex}

\newcommand\sectionFmt[1]{%
  \sectionFont\sectionSize\color{section}%
  \memRTLraggedright%
  \itshape #1%
}
\setsecheadstyle{\sectionFmt}

\setsubsecheadstyle{%
  \sectionFont\large\itshape\memRTLraggedright%
}
\setsubsubsecheadstyle{%
  \sectionFont\normalsize\itshape\memRTLraggedright%
}


% === Page geometry and layout ===

% Symbols used:
% P = page proportion (h/w)
% T = textblock proportion (d/m)
% w = paper width
% h = paper height
% m = text width
% d = text height

\ifthenelse{\equal{\BOOK@pagePreset}{largepage}}{

  % Large page size
  %
  % 6in x 9in page
  % P = 1.5 (fifth)
  % T = 1.732 (sqrt(3)), Hexagon

  % For 11pt / 16pt font size, Gentium font, 5pt parskip, no parindent.
  % TODO: elaborate on reasonale

  % === normalsize ===

  \def\BOOK@apt{11}
  \def\BOOK@bpt{16}

  \renewcommand{\normalsize}{%
    \@setfontsize\normalsize\BOOK@apt\BOOK@bpt
    \abovedisplayskip 11\p@ \@plus3\p@ \@minus6\p@
    \abovedisplayshortskip \z@ \@plus3\p@
    \belowdisplayshortskip 6.5\p@ \@plus3.5\p@ \@minus3\p@
    \belowdisplayskip \abovedisplayskip
    \color{textbody}
    \let\@listi\@listI}
  \normalsize

  % === indentations ===

  \setlength{\vgap}{1.5em}
  \setlength{\vindent}{\vgap}
  \setlength{\vleftmargin}{2em}

  \setlength{\parskip}{5pt}
  \setlength{\parindent}{0pt}

  % === setup page layout ===

  \setstocksize{9in}{6in}
  \settrimmedsize{\stockheight}{\stockwidth}{*}
  \settrims{0pt}{0pt}
  % It won't be exactly 33 lines because of the parskip,
  % but close enough for our purpose.
  \settypeblocksize{32\baselineskip + \topskip}{*}{0.577}% 1/1.732 (sqrt(3)), Hexagon
  \setlrmargins{*}{*}{1.125}% 1/0.889 major 2nd
  \setulmargins{*}{*}{1.701}% Tall Pentagon, 1.701
  \setlength{\footskip}{3\baselineskip}

% ******************************************************
% Stock height and width: 228.59732mm by 152.39821mm
% Top and edge trims: 0mm and 0mm
% Page height and width: 228.59732mm by 152.39821mm
% Text height and width: 183.81133mm by 105.78816mm
% Spine and edge margins: 21.80508mm and 24.53474mm
% Upper and lower margins: 16.57637mm and 28.20961mm
% Headheight and headsep: 4.77979mm and 6.98476mm
% Footskip: 16.86987mm
% Columnsep and columnseprule: 3.51456mm and 0mm
% Marginparsep and marginparwidth: 2.46019mm and 19.61436mm
% Sidecapsep and sidecapwidth: 2.46019mm and 39.01158mm
% Sidebarhsep and sidebarwidth: 2.46019mm and 39.01158mm
% Sidebarvsep and sidebartopsep: 4.77979mm and 0mm
% Sidebarheight: 189.75801mm
% Sidefoothsep and sidefootwidth: 2.46019mm and 39.01158mm
% Sidefootvsep and sidefootheight: 4.77979mm and 189.75801mm
% ******************************************************
%
% ******************************************************
% Stock height and width: 650.43pt by 433.62pt
% Top and edge trims: 0pt and 0pt
% Page height and width: 650.43pt by 433.62pt
% Text height and width: 523pt by 301pt
% Spine and edge margins: 62.04224pt and 69.80893pt
% Upper and lower margins: 47.16492pt and 80.26508pt
% Headheight and headsep: 13.6pt and 19.8738pt
% Footskip: 48pt
% Columnsep and columnseprule: 10pt and 0pt
% Marginparsep and marginparwidth: 7pt and 55.80893pt
% Sidecapsep and sidecapwidth: 7pt and 111pt
% Sidebarhsep and sidebarwidth: 7pt and 111pt
% Sidebarvsep and sidebartopsep: 13.6pt and 0pt
% Sidebarheight: 539.9202pt
% Sidefoothsep and sidefootwidth: 7pt and 111pt
% Sidefootvsep and sidefootheight: 13.6pt and 539.9202pt
% ******************************************************

}{
\ifthenelse{\equal{\BOOK@pagePreset}{smallpage}}{

  % Small page size
  %
  % 5.25in x 8in page
  % P = 1.523 (~Pentagon (1.539), b/w fifth (1.5) and minor 6th (1.6))
  % T = 1.618 (Golden Section, ~minor 6th (1.6))

  % For 11pt / 16pt font size, 27 lines, Gentium font, no parskip, 17pt parindent.
  % Small book binding swallows more space in the center, hence the 0.889 L-R margin ratio, instead of the 1.125 of the larger page size.

  % === normalsize ===

  \def\BOOK@apt{11}
  \def\BOOK@bpt{16}

  \renewcommand{\normalsize}{%
    \@setfontsize\normalsize\BOOK@apt\BOOK@bpt
    \abovedisplayskip 11\p@ \@plus3\p@ \@minus6\p@
    \abovedisplayshortskip \z@ \@plus3\p@
    \belowdisplayshortskip 6.5\p@ \@plus3.5\p@ \@minus3\p@
    \belowdisplayskip \abovedisplayskip
    \color{textbody}
    \let\@listi\@listI}
  \normalsize

  % === indentations ===

  \setlength{\vgap}{1.5em}
  \setlength{\vindent}{\vgap}
  \setlength{\vleftmargin}{2em}

  % === setup page layout ===

  \setlength{\parskip}{0pt}
  \setlength{\parindent}{17pt}

  \setstocksize{8in}{5.25in}
  \settrimmedsize{\stockheight}{\stockwidth}{*}
  \settrims{0pt}{0pt}
  \settypeblocksize{27\baselineskip + \topskip}{*}{0.618}% 1/1.618 Golden section
  %\setlrmargins{*}{*}{0.889}% major 2nd 15:16, gives: 19.24mm | 17.1mm
  % FIXED: inner margin too close to the spine. Increased it a bit.
  \setlrmargins{*}{*}{0.63}% gives: 22.30mm | 14.04mm
  \setulmargins{*}{*}{1.701}% Tall Pentagon
  \setlength{\footskip}{3\baselineskip}

}{
\ifthenelse{\equal{\BOOK@pagePreset}{opuslargepage}}{

  % Opus Large page size
  %
  % 6in x 9in page
  % P = 1.5 (fifth)
  % T = 1.539 (Pentagon, between fifth and minor 6th)

  % For 10.5pt / 15pt font size, Gentium font, 20pt parindent, no
  % parskip. The textblock is a somber proportion (Pentagon 1:1.539),
  % ~70 characters wide. The slightly open linespacing aviods wall of
  % text effect. The inner margins keep the text out from the spine,
  % so a large book doesn't have to be strained to read the words
  % toward the center. Running header on top with title and chapter
  % marks, centered. Page number centered in footer, about three
  % linespace from text, bottom margin taller than top margin. This
  % gives the textblock a slightly elevated atmosphere, but with a
  % low-resonance proportion (between fifth and minor 6th musical
  % scale) for long prose (Dhamma talks), instead of a high-resonance
  % narrower column that would suit lighter text.

  % === normalsize ===

  \def\BOOK@apt{10.5}
  \def\BOOK@bpt{15}

  \renewcommand{\normalsize}{%
    \@setfontsize\normalsize\BOOK@apt\BOOK@bpt
    \abovedisplayskip 10\p@ \@plus2\p@ \@minus5\p@
    \abovedisplayshortskip \z@ \@plus3\p@
    \belowdisplayshortskip 6\p@ \@plus3\p@ \@minus3\p@
    \belowdisplayskip \abovedisplayskip
    \color{textbody}
    \let\@listi\@listI}
  \normalsize

  % === indentations ===

  \setlength{\vgap}{1.5em}
  \setlength{\vindent}{\vgap}
  \setlength{\vleftmargin}{2em}

  \setlength{\parskip}{5pt}
  \setlength{\parindent}{20pt}

  % === setup page layout ===

  \setstocksize{9in}{6in}
  \settrimmedsize{\stockheight}{\stockwidth}{*}
  \settrims{0pt}{0pt}
  % no parskip, so exactly 33 lines
  %   = 490.5pt
  %   = 172.39mm
  %   = 32\baselineskip + \topskip
  % 1/1.539 = 0.649 (Pentagon) ratio to height, 112mm
  \settypeblocksize{32\baselineskip + \topskip}{*}{0.649}% 1/1.539, Tall Pentagon
  % alt: Short Pentagon, 1.376
  \setlrmargins{*}{*}{1.333}% fourth 3:4, 23.15mm | 17.3mm
  \setulmargins{*}{*}{1.778}% minor 7th 9:16, 20.23mm | 35.97mm
  \setheaderspaces{*}{4mm}{*}% ~ 1/Golden section, closer to text
  \setlength{\footskip}{3\baselineskip}

}{
\ifthenelse{\equal{\BOOK@pagePreset}{opussmallpage}}{

  % Opus Small page size
  %
  % 5.25in x 8in page
  % P = 1.523 (~Pentagon (1.539), b/w fifth (1.5) and minor 6th (1.6))
  % T = 1.618 (Golden Section, ~minor 6th (1.6))

  % For 10.5pt / 15pt font size, 27 lines, Gentium font, no parskip, 17pt parindent.

  % === normalsize ===

  \def\BOOK@apt{10.5}
  \def\BOOK@bpt{15}

  \renewcommand{\normalsize}{%
    \@setfontsize\normalsize\BOOK@apt\BOOK@bpt
    \abovedisplayskip 11\p@ \@plus3\p@ \@minus6\p@
    \abovedisplayshortskip \z@ \@plus3\p@
    \belowdisplayshortskip 6.5\p@ \@plus3.5\p@ \@minus3\p@
    \belowdisplayskip \abovedisplayskip
    \color{textbody}
    \let\@listi\@listI}
  \normalsize

  % === indentations ===

  \setlength{\vgap}{1.5em}
  \setlength{\vindent}{\vgap}
  \setlength{\vleftmargin}{2em}

  % === setup page layout ===

  \setlength{\parskip}{0pt}
  \setlength{\parindent}{17pt}

  \setstocksize{8in}{5.25in}
  \settrimmedsize{\stockheight}{\stockwidth}{*}
  \settrims{0pt}{0pt}
  \settypeblocksize{27\baselineskip + \topskip}{*}{0.618}% 1/1.618 Golden section
  \setlrmargins{*}{*}{0.889}% major 2nd 15:16
  \setulmargins{*}{*}{1.701}% Tall Pentagon
  \setlength{\footskip}{3\baselineskip}

}{
\ifthenelse{\equal{\BOOK@pagePreset}{largevolume}}{

  % Large Volume page size
  %
  % 6in x 9in page
  % P = 1.5 (fifth)
  % T = 1.568181

  % TODO: elaborate on style.

  % === normalsize ===

  \def\BOOK@apt{10.5}
  \def\BOOK@bpt{15}

  \renewcommand{\normalsize}{%
    \@setfontsize\normalsize\BOOK@apt\BOOK@bpt
    \abovedisplayskip 10\p@ \@plus2\p@ \@minus5\p@
    \abovedisplayshortskip \z@ \@plus3\p@
    \belowdisplayshortskip 6\p@ \@plus3\p@ \@minus3\p@
    \belowdisplayskip \abovedisplayskip
    \color{textbody}
    \let\@listi\@listI}
  \normalsize

  % === indentations ===

  \setlength{\vgap}{1.5em}
  \setlength{\vindent}{\vgap}
  \setlength{\vleftmargin}{2em}

  \setlength{\parskip}{0pt}
  \setlength{\parindent}{15pt}

  % === setup page layout ===

  \setstocksize{9in}{6in}
  \settrimmedsize{\stockheight}{\stockwidth}{*}
  \settrims{0pt}{0pt}

  % textheight: 177.8mm (7in) - 15pt (\baselineskip) = 172.5mm
  % or 32.5999 lines
  % textwidth: 110mm
  % 1/1.568181 = 0.63768 ratio

  % TODO: count lines in PDF
  % no parskip, so 32.5 lines
  %   = 487.5pt
  %   = 171.97917mm
  %   = 31.5\baselineskip + \topskip
  \settypeblocksize{32\baselineskip + \topskip}{110mm}{*}
  \setlrmargins{*}{15mm}{*}% 27.4mm | 15mm
  \setulmargins{26mm}{*}{*}
  \setheadfoot{15pt}{39pt}
  \setheaderspaces{*}{13mm}{*}

}{
\ifthenelse{\equal{\BOOK@pagePreset}{tallpage}}{

  % Tall Page page size
  %
  % 5in x 8.25in page
  % P = 1.618 (Golden section)
  % T = 1.568181

  % === normalsize ===

  \def\BOOK@apt{10.5}
  \def\BOOK@bpt{16}

  \renewcommand{\normalsize}{%
    \@setfontsize\normalsize\BOOK@apt\BOOK@bpt
    \abovedisplayskip 10\p@ \@plus2\p@ \@minus5\p@
    \abovedisplayshortskip \z@ \@plus3\p@
    \belowdisplayshortskip 6\p@ \@plus3\p@ \@minus3\p@
    \belowdisplayskip \abovedisplayskip
    \color{textbody}
    \let\@listi\@listI}
  \normalsize

  % === indentations ===

  \setlength{\vgap}{1.5em}
  \setlength{\vindent}{\vgap}
  \setlength{\vleftmargin}{2em}

  \setlength{\parskip}{0pt}
  \setlength{\parindent}{15pt}

  % === setup page layout ===

  \setstocksize{8.25in}{5in}
  \settrimmedsize{\stockheight}{\stockwidth}{*}
  \settrims{0pt}{0pt}

  \settypeblocksize{26.5\baselineskip + \topskip}{90mm}{*}
  \setlrmargins{18mm}{*}{*}
  \setulmargins{27.5mm}{*}{*}% Keeping top same as with 1.618 ratio
  %\setlength{\footskip}{3\baselineskip}

}{

  % other page sizes?

}}}}}}

% This will also typeout values in pt (default)
\checkandfixthelayout
% It is useful to see layout values in mm too.
\settypeoutlayoutunit{mm}
\typeoutlayout

% === Packages to be loaded LAST ===

\RequirePackage[perpage,multiple,stable]{footmisc}

%% =================
%% PDF/X-3:2002 info
%% =================

% \pdfobjcompresslevel=0%
% \pdfminorversion=3%
% \pdfinfo{
%   /Title (\thetitle)
%   /Author (\theauthor)
%   /Subject (buddhism)
%   /Keywords (buddhism)
%   /GTS_PDFXVersion (PDF/X-3:2002)
% }%
% \pdfpageattr{
% /MediaBox [0 0 369.00000 594.00000]
% /BleedBox [0.00000 0.00000 369.00000 594.00000]
% /CropBox [0 0 369.00000 594.00000]
% /TrimBox [0.00000 0.00000 369.00000 594.00000]
% }
% \pdfcatalog{
%   /PageMode /UseNone
%   /OutputIntents [ <<
%     /Info (none)
%     /Type /OutputIntent
%     /S /GTS_PDFX
%     /OutputConditionIdentifier (Blurb.com)
%     /RegistryName (http://www.color.org/)
%   >> ]
% }%

%% ==============

