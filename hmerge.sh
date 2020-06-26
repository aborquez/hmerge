#!/bin/bash

##############################################################################
# ./hmerge.sh --M <max number of entries in output file> <dir>               #
#                                                                            #
# E.G.: ./hmerge.sh --M 350000 .                                             #
##############################################################################

#####
# Functions
###

function get_num()
{
  sr=$1
  srn=""
  if [[ $sr -lt 10 ]]; then
    srn="0$sr"
  else
    srn="$sr"
  fi
  echo $srn
}

#####
# Input
###

inputArray=("$@")

if [[ "${inputArray[0]}" == "--M" ]]; then
    maxEntries=${inputArray[1]}
else
    printf "\n*** Aborting: Unrecognized argument: ${inputArray[$((ic))]}. Please, check usage box inside code. ***\n\n";
fi

inputDir=${inputArray[2]}
if [[ "${inputDir: -1}" == "/" ]]; then
    inputDir=${inputDir:0:-1}
fi
inputSetOfFiles=$inputDir/*.root

#####
# Main
###

sumEntries=0
filesToMerge=""
ic=0
for inputFile in $inputSetOfFiles; do
    currentEntries=$(root -l -b -q ${inputFile} -e 'CLASEVENT->GetEntries()' | awk 'END{print $NF}')
    ((sumEntries+=currentEntries))
    if [[ $sumEntries -le $maxEntries ]]; then
	filesToMerge+=" $inputFile"
    else
	rn=$(get_num "$ic")
	outFile="$inputDir/merged_${rn}.root"
	echo "hadd $outFile $filesToMerge"
	hadd $outFile $filesToMerge
	# reset values to start from *this* file
	filesToMerge="$inputFile"
	sumEntries=$currentEntries
	# next output file
	((ic+=1))
    fi
done
# after loop: merge remaining files
rn=$(get_num "$ic")
outFile="$inputDir/merged_${rn}.root"
echo "hadd $outFile $filesToMerge"
hadd $outFile $filesToMerge

#####
# Notes
###

# test case: 4 files {01.root, 02.root, 03.root, 04.root}
# the first one has 410 events and the other 3 have 400 events
#
# -> I run ./hmerge --M 800 .
#
# sum=0, filestomerge="", ic=0
# it 1: current=410, sum=410, cond 1 -> filestomerge="01"
# it 2: current=400, sum=810, cond 2 -> hadd merged_00.root 01.root -> filestomerge="02", sum=400, ic=1
# it 3: current=400, sum=800, cond 1 -> filestomerge="02 03"
# it 4: current=400, sum=1200, cond 2 -> hadd merged_01.root 02.root 03.root -> filestomerge="04", sum=400, ic=2 -> loop ends
# after loop: hadd merged_02.root 04.root
