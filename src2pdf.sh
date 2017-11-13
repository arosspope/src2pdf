#!/usr/bin/env bash

read -p "Title (blank to use ${PWD##*/}) : " answer

if [[ $answer == "" ]]; then
    title=${PWD##*/}
else
    title=$answer
fi

read -p "Author (blank for nothing) : " answer

if [[ $answer == "" ]]; then
    author=""
else
    author=$answer
fi

read -p "Subtitle (blank for nothing) : " answer

if [[ $answer == "" ]]; then
    subtitle=""
else
    subtitle=$answer
fi

# see http://en.wikibooks.org/wiki/LaTeX/Source_Code_Listings, part `Supported languages`
read -p "Language of files to parse (blank for 'C++') : " answer

if [[ $answer == "" ]]; then
    lang="C++"
else
    lang=$answer
fi

# if output files already exist, delete them
if [ -f ./tmp.aux ] || [ -f ./tmp.log ] || [ -f ./tmp.out ] || [ -f ./tmp.pdf ] || [ -f ./tmp.toc ] ; then
    echo "  Removing old output files."
    rm ./tmp.*
fi

tex_file=$(mktemp) ## Random temp file name

if [ $? -ne 0 ]; then
    echo "  ERROR: failed to create temporary file."
    exit 1;
fi

## Begin Tex setup
cat << EOF > $tex_file

\documentclass[titlepage]{article}
\usepackage[utf8]{inputenc}

\usepackage{titling}
\newcommand{\subtitle}[1]{%
  \posttitle{%
    \par\end{center}
    \begin{center}\large#1\end{center}
    \vskip0.5em}%
}

\author{$author}
\title{$title}
\subtitle{$subtitle}

\usepackage{listings}
\usepackage[usenames,dvipsnames]{color} %% Allow color names
\lstdefinestyle{customasm}{
  belowcaptionskip=1\baselineskip,
  xleftmargin=\parindent,
  language=$lang,
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
\lhead{$title}
\rhead{$author}
\begin{document}

\maketitle

\pagenumbering{roman}
\tableofcontents

\newpage
\setcounter{page}{1}
\pagenumbering{arabic}

EOF
## End Tex Setup

# ask the user which file extensions to include

read -p "Provide a space separated list of extensions to include (default is 'h cpp') : " answer

if [[ $answer == "" ]]; then
    answer="h cpp"
fi

# replace spaces with double escaped pipe using substring replacement  http://www.tldp.org/LDP/abs/html/parameter-substitution.html

extensions="${answer// /\\|}"

###############

# FINDING FILES TO INCLUDE
# inline comments http://stackoverflow.com/questions/2524367/inline-comments-for-bash#2524617
# not all of the conditions below are necessary now that the regex for c++ files has been added, but they don't harm

filesarray=(
$(
find .                                          `# find files in the current directory` \
        -type f                                 `# must be regular files` \
        -regex ".*\.\($extensions\)"            `# only files with the chosen extensions (.h, .cpp and .qml) by default` \
        ! -regex ".*/\..*"                      `# exclude hidden directories - anything slash dot anything (Emacs regex on whole path https://www.emacswiki.org/emacs/RegularExpression)` \
        ! -name ".*"                            `# not hidden files` \
        ! -name "*~"                            `# don't include backup files` \
        ! -name 'src2pdf'                       `# not this file if it's in the current directory`
))

###############

# sort the array https://stackoverflow.com/questions/7442417/how-to-sort-an-array-in-bash#11789688
# internal field separator $IFS https://bash.cyberciti.biz/guide/$IFS

IFS=$'\n' filesarray=($(sort <<<"${filesarray[*]}"))
unset IFS

###############

## TODO: This doesn't make much sense for other languages
read -p "Re-order files to place header files in front of source files? (Y/n) : " answer

if [[ ! $answer == "n" ]] && [[ ! $answer == "N" ]] ; then
    echo "  Re-ordering files."

    # if this element is a .cpp file, check the next element to see if it is a matching .h file
    # if it is, swap the order of the two elements
    re="^(.*)\.c(pp)?$"

    # this element is ${filesarray[$i]}, next element is ${filesarray[$i+1]}
    for (( i=0; i<=$(( ${#filesarray[@]} -1 )); i++ ))
    do
        # if the element is a .cpp file, check the next element to see if it is a matching .h file
        if [[ ${filesarray[$i]} =~ $re ]]; then
            header=${BASH_REMATCH[1]}
            header+=".h"
            if [[ ${filesarray[$i+1]} == $header ]]; then
                # replace the next element in the array with the current element
                filesarray[$i+1]=${filesarray[$i]}
                # replace the current element in the array with $header
                filesarray[$i]=$header
            fi
        fi
    done
fi

###############

# Change ./foo/bar.src to foo/bar.src
IFS=$'\n' filesarray=($(sed 's/^\..//' <<<"${filesarray[*]}"))
unset IFS

###############

read -p "Review files found? (y/N) : " answer

if [[ $answer == "y" ]] || [[ $answer == "Y" ]] ; then

    echo "  The following files will be included in the document."

    for i in "${filesarray[@]}"
    do
        echo $i
    done

    # allow the user to abort
    read -p "Proceed? (y/n) : " answer
    if [[ $answer == "n" ]] || [[ $answer == "N" ]] ; then
        exit 0
    fi

fi

###############

# create a .tex file with each section on its own page

echo "  Creating tex file."

for i in "${filesarray[@]}"
do
    name=$(echo $i | sed 's/\_/\\_/g') # Escape filename with underscores
    echo "\newpage" >> $tex_file   # start each section on a new page
    echo "\section{$name}" >> $tex_file  # create a section for each source file
    echo "\lstinputlisting[style=customasm]{$i}" >>$tex_file # place the contents of each file in a listing
done

echo "\end{document}" >> $tex_file

###############

# run pdflatex twice to produce TOC
echo "  Creating pdf."
echo

pdflatex $tex_file -output-directory . && pdflatex $tex_file -output-directory .

if [ $? -ne 0 ]; then
    echo "  ERROR: pdflatex command failed, refer to tmp.log for more information."
    exit 1;
fi

###############

echo "  Renaming output files."

mv tmp.pdf "$title.pdf"

echo "  Cleaning up."

rm ./tmp.*

echo "Done, output file is '$title.pdf' in this directory"
