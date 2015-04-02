#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset
set -o verbose

# ./get /Vol07_Ch0346-0398/HRS0383/HRS_0383-0069.htm

mkdir hrs_output
cd hrs_output

for i in `seq 2000 2013`; 
do
echo $i
URL="http://www.capitol.hawaii.gov/hrs$i/$1"
curl $URL > hrs$i.html
html2text hrs$i.html > hrs$i.txt
md5sum hrs$i.txt >> hrs.txt
done

URL="http://www.capitol.hawaii.gov/hrscurrent/$1"
curl $URL > hrscurrent.html
html2text hrscurrent.html > hrscurrent.txt
md5sum hrscurrent.txt >> hrs.txt



