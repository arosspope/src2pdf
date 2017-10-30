# src2pdf :page_with_curl:

Yet another source code to pdf script using LaTeX.

## Introduction
### Rationale

Ever needed to hand in a hardcopy of the code you produced in a university assignment? Have you almost destroyed your keyboard trying to format a word document (or similar) containing this same source code?

Well look no further, `src2pdf` is here to put your troubled mind at ease! Using LaTeX and Bash, present your development efforts in a neat and ordered format using one command!

### Example

![1](https://i.imgur.com/T4QiEX5m.png) ![2](https://i.imgur.com/YDpsWm9m.png)
> _Show how fancy you are with a title page, table of contents, and syntax highlighting based on source language_

### How is this script different?

Honestly, this script is not that different to the others out there. However, this implementation does allow you to customise a **title**, **subtitle**, **author**, and source **language**. If this script gains popularity, I might put in _extra features_ such as _fancier_ title pages.

## Installation
### Required packages

As this script extensively uses LaTeX, you will need to ensure that it is installed on your system. As an example for Ubuntu, you might install the packages...
```bash
$ apt-get install texlive-latex-base texlive-latex-extra
```
More generally, this script will require the following packages to be installed: [pdflatex](http://linux.die.net/man/1/pdflatex),  [color](http://www.ctan.org/tex-archive/macros/latex/contrib/xcolor/), [listings](https://en.wikibooks.org/wiki/LaTeX/Source_Code_Listings).

### Finding the script

After installing the required packages, the script should work out-of-the-box after making it executable. Personally, I like to put the script somewhere where it can be easily found on `$PATH` (such as `/usr/local/bin`).

```bash
$ chmod +x /usr/local/bin/src2pdf.sh
```

## Operation

Navigate to your project directory and run the following (assuming the script is on the `$PATH`):
```
arosspope@(project) $ src2pdf
```
You will then be prompted with a series of questions to generate and customise the pdf. Here is an example of the script running:


```
$ Title (blank to use prm_sim) : PRM Simulator
$ Author (blank for nothing) : arosspope
$ Subtitle (blank for nothing) : A Probabilistic RoadMap (PRM) simulator in ROS
$ Language of files to parse (blank for 'C++') :
$ Provide a space separated list of extensions to include (default is 'h cpp') :
$ Re-order files to place header files in front of source files? (y/n) : y
  Re-ordering files.
$ Review files found? (y/n) : n
  Creating tex file.
  Creating pdf.
...
  Renaming output files.
  Cleaning up.
Done, output file is 'PRM Simulator.pdf' in this directory
```
Please note that _special characters_ `#%$_^&}{)(` within the title, subtitle and/or author positions **must be escaped**, or the script will fail to run.

Currently, the supported languages are specified by the LaTeX [source code listings](http://en.wikibooks.org/wiki/LaTeX/Source_Code_Listings) page.

## Acknowledgements

The bones of this script comes from the [tutorial](https://samhobbs.co.uk/2017/01/bash-script-generate-pdf-source-code-syntax-highlighting-using-latex) _'BASH Script to generate PDF of Source Code with Syntax Highlighting using LaTeX'_ by Sam Hobbs, 2017.
