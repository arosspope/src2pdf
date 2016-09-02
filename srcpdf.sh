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
  SEARCH_ALL="find . -type f \( -iname '*.c' ! -iname 'main.c' -o -iname '*.h' \)"
  SEARCH_MAIN="find . -type f \( -iname 'main.c' \)"
elif [ "$LANG" == "Python" ]
then  
  SEARCH_ALL="find . -name \*.py"
elif [ "$LANG" == "C++" ]
then
  SEARCH_ALL="find . -type f \( -iname '*.cpp' ! -iname 'main.cpp' -o -iname '*.h' \)"
  SEARCH_MAIN="find . -type f \( -name 'main.cpp' \)"
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
  language=$LANG,                       
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

function printSrcToPdf {
  NAME=$(echo $1 | sed 's/\_/\\_/g')                        # Escape filename with underscores
  echo "\newpage" >> $tex_file                              # Start each section on a new page
  echo "\section{$NAME}" >> $tex_file                       # Create a section for each file                  
  echo "\lstinputlisting[style=customasm]{$1}" >> $tex_file # Print the file to the PDF
}


# If the language is either C or C++, usually these projects contain a 'main' file. It would make
# sense if this file was the first file printed to the pdf.
if [ "$LANG" == "C" ] || [ "$LANG" == "C++" ]
then
  eval $SEARCH_MAIN | sed 's/^\..//' | 
  while read i; do
    printSrcToPdf $i
  done
fi

## Loop through each code file
eval $SEARCH_ALL | sort | sed 's/^\..//' |
while read  i; do
  printSrcToPdf $i
done && 
echo "\end{document}" >> $tex_file &&

## This needs to be run twice for the TOC to be generated
pdflatex -output-directory=$COMPILE_DIR $tex_file && 
pdflatex -output-directory=$COMPILE_DIR $tex_file 

## Rename the file to user specified title
mv "./$COMPILE_DIR/tmp.pdf" "./$COMPILE_DIR/$FILENAME.pdf"
