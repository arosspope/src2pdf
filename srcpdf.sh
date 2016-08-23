#!/usr/bin/env bash

## Check required arguments are present and not null
if [ -z "$3" ] || [ -z "$2" ] || [ -z "$1" ]
then
  echo "Usage: srcpdf [title] [author] [language]"
  echo "    title    - Title of the created pdf"
  echo "    author   - Author of document"
  echo "    language - Coding Language to parse (C | C++ | Python)"
  echo "Note; special characters (#, %, $, _, ^, &, {}) must be properly escaped"
  exit 1
fi

## Assign title, Author and Language
TITLE=$1
FILENAME=${TITLE//[^[:alnum:]]/} # Strip out special chars
COMPILE_DIR=srcpdf
AUTHOR=$2
LANG=$3

## Perform a language check and initialise the search string
if [ "$LANG" == "C" ]
then
  SEARCH_STRING="find . -name \*.c -o -name \*.h"
elif [ "$LANG" == "Python" ]
then  
  SEARCH_STRING="find . -name \*.py"
elif [ "$LANG" == "C++" ]
then
  SEARCH_STRING="find . -name \*.h -o -name \*.cpp"
else
  echo "Error.. $LANG is an unsupported language"
  exit 1
fi

## Random temp file name and print tex file header
tex_file=$(mktemp)

## Create the srcpdf directory
mkdir $COMPILE_DIR

## Begin Tex setup
cat << EOF > $tex_file

\documentclass[titlepage]{article}
\usepackage[utf8]{inputenc}
\author{$AUTHOR}
\title{$TITLE}
\usepackage{listings}
\usepackage[usenames,dvipsnames]{color} %% Allow color names
\lstdefinestyle{customasm}{
  belowcaptionskip=1\baselineskip,
  xleftmargin=\parindent,
  language=$LANG,                       %% Change this to whatever you write in
  breaklines=true,                      %% Wrap long lines
  basicstyle=\footnotesize\ttfamily,
  commentstyle=\itshape\color{Gray},
  stringstyle=\color{Black},
  keywordstyle=\bfseries\color{OliveGreen},
  identifierstyle=\color{blue},
  xleftmargin=-8em,
}
\usepackage[colorlinks=true,linkcolor=blue]{hyperref}
\usepackage{fancyhdr}
\pagestyle{fancy}
\lhead{$TITLE}
\rhead{$AUTHOR}
\begin{document}
\maketitle
\tableofcontents

EOF
## End Tex Setup

## Loop through each code file
eval $SEARCH_STRING | sort | sed 's/^\..//' |
while read  i; do
  NAME=$(echo $i | sed 's/\_/\\_/g')                        # This properly escapes filenames with underscores
  echo "\newpage" >> $tex_file                              ## Start each section on a new page
  echo "\section{$NAME}" >> $tex_file                       ## Create a section for each file                  
  echo "\lstinputlisting[style=customasm]{$i}" >> $tex_file ## This command will include the file in the PDF
done && 
echo "\end{document}" >> $tex_file &&
## This needs to be run twice for the TOC to be generated
pdflatex -output-directory=$COMPILE_DIR $tex_file && 
pdflatex -output-directory=$COMPILE_DIR $tex_file 

## Rename the file to user specified title
mv "./$COMPILE_DIR/tmp.pdf" "./$COMPILE_DIR/$FILENAME.pdf"
