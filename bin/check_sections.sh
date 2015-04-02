#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset
#set -o verbose



for i in `ls json/section_*.json`; 
do 
CITATIONS=`grep "citations" $i | wc -l`
FAILED=`grep "failed_to_parse" $i | wc -l`
PCT=`perl -e "printf('%d', $FAILED / $CITATIONS * 100)"`

echo "***********************"
wc -l $i
echo "citations: $CITATIONS"
echo "failed to parse: $FAILED ($PCT%)"
echo
done



