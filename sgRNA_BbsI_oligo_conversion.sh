#!/bin/bash
# AUTHOR: Kirk Ehmsen
# FILE: sgRNA_BbsI_oligo_conversion.sh
# DATE: 01-25-2017
# DESCRIPTION: This script accepts a text file as a command-line argument, and returns sgRNA sequences
# compatible with BbsI cloning into pX330/335 (AddGene 42230/42335) or related vectors,
# for Cas9 or Cas9-D10A and sgRNA expression following transfection of cultured cells.

# Reference for cloning context: Multiplex Genome Engineering Using CRISPR/Cas Systems.
# Cong L, Ran FA, Cox D, Lin S, Barretto R, Habib N, Hsu PD, Wu X, Jiang W, Marraffini LA, Zhang F.
# Science. 2013 Jan 3. 10.1126/science.1231143 PubMed 23287718

# The sgRNA sequences are returned in a newly created text file, in a comma-delimited format
# compatible with copy-and-paste into the 'bulk upload' feature of the IDT oligo ordering page
# (Integrated DNA Technologies, www.idtdna.com)

# USAGE: ./sgRNA_BbsI_oligo_conversion.sh $1 $2
# $1 and $2 are two arguments required at the command-line script call (see details below)

# REPOSITORY: https://github.com/YamamotoLabUCSF/sgRNA_BbsI_oligo_conversion.sh

#######################################################################
# In brief:

# input data = sgRNA sequence and name, in two columns in text file format (comma-delimited fields).
# input filetype extension can be .csv or .txt
# example content (two distinct guides):

# FKBP5_GOR+86.85kb_Guide#12,CTTCAAAACAAAATTGCTCT
# FKBP5_GOR+86.85kb_Guide#6,CACCCTGTTCTGAATGTGGC

# important: make sure text/csv file content ends in newline character (can test with following code):
# tail -n 1 fileToTest | wc -l
# if result is 1, the file properly ends in newline character; if 0, the file needs a
# newline character to be added to the last line (go to end of last file line and press 'Enter', then resave file)

# output data = sgRNA sequence and name in 'fwd' and 'rev' forms, appropriate for cloning into BbsI sites
# example output for example content above:
 
# FKBP5_GOR+86.85kb_Guide#12_fwd,CACCGCTTCAAAACAAAATTGCTCT
# FKBP5_GOR+86.85kb_Guide#6_fwd,CACCGCACCCTGTTCTGAATGTGGC
# FKBP5_GOR+86.85kb_Guide#12_rev,AAACAGAGCAATTTTGTTTTGAAGC
# FKBP5_GOR+86.85kb_Guide#6_rev,AAACGCCACATTCAGAACAGGGTGC

# make sure the command-line knows where to find this script, and that it has proper permissions 
# (for example (MAC OS), chmod 777 ~/scripts/sgRNA_BbsI_oligo_conversion.sh)

#######################################################################
# Arguments needed at command-line invocation --
# 2 arguments to the script are required at its command-line call:

# $1 = path to text file name.  For example:
# ~/Desktop/FKBP5_guides.txt

# $2 = path to new text file for oligo output (this file does not need to exist before running the script;
# the script will create the file).  For example:
# ~/Desktop/FKBP5_guides_BbsI_oligos.txt

# Usage would resemble:
# ./sgRNA_BbsI_oligo_conversion.sh ~/Desktop/FKBP5_guides.txt ~/Desktop/FKBP5_guides_BbsI_oligos.txt

#######################################################################
# SCRIPT:

# a brief summary of what happens at each stage of the script is commented where appropriate below

bold=$(tput bold)
normal=$(tput sgr0)
export GREP_COLOR='1;32'

echo
echo "* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *"
echo "$(date)"
echo "${bold}These are oligo sequences for sgRNA cloning into BbsI sites of Cas9/Cas9-D10A expression vectors"
echo "Script is: ${normal}$0"
echo "${bold}Path to text file source is: ${normal}$1"
echo "${bold}Path to text file output is: ${normal}$2"
echo "* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *"
echo 

# design 'forward' oligos with overhang compatible with BbsI cloning
while read line
  do
    echo $line | tr ' ' '_' | awk -F "," '{print $1"_fwd" "," "CACCG"$2}'
  done < $1 >> $2

# design 'reverse' oligos (to be annealed to 'forward' oligos) with overhang compatible with BbsI cloning
while read line
  do
    echo $line | tr ' ' '_' | awk -F "," '{print $1"_rev" ","}' ; echo $line | awk -F "," '{print "G"$2 "GTTT"}' | tr 'ATCG' 'TAGC' | rev
  done < $1 | sed '/,/{N;s/\n//;}' >> $2

# summarize total numbers of oligos and target sites represented among the oligo pairs
oligo_count=$(cat $2 | wc -l | tr -d ' ')
oligo_count_uniq=$(cat $2 | sort | uniq | wc -l | tr -d ' ')
sgRNA_count=$(expr $oligo_count / 2)

# report summary and target file where oligo DNA sequences can be found
echo "        You have designed $oligo_count oligos, of which $oligo_count_uniq are unique;"
echo "        When annealed and cloned into Cas9/Cas9-D10A expression vectors, these oligo sets"
echo "        correspond to $sgRNA_count sgRNA(s) and $sgRNA_count target site(s)."

echo
echo "        Oligo design is complete."
echo "        Your output file can be found at: ${bold}$2"
echo
echo "${normal}*end of script*"
echo
