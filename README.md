# srcpdf
## Introduction
---------------

This script allows a user to print source code files within a folder to a pdf file. After specifying a title, author and coding language the generated pdf contains a coverpage, table of contents and user source files.

I find this script particuarly useful when university assignments require a hardcopy of student code, as it presents your development effort in a neat and ordered format.

## Usage
--------

After installing the required dependencies as specified below, the script should work out-of-the-box. Personally, I like to put the script somewhere where it can be easily found on the PATH (such as /usr/local/bin).

Naviagte to the directory containing all your source files and run the following line (note in the following example, source files are written in c).

  $ Usage: srcpdf [title] [author] [language]
  $ /usr/local/bin/srcpdf.sh "Assignment 1" "A.R.P" "C"
  
This will create a sub-directory called 'srcpdf' which contains the pdf and the tex files used to generate the pdf. Please note that special characters such as (#, %, $, _, ^, &, }, {) must be escaped, or the script will not print correctly.

Currently, the supported languages are 'C', 'C++' and 'Python' - but this can be easily extended upon.


## Dependencies
---------------

+ pdflatex
+ color
+ listings
