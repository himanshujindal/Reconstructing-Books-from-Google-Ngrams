#!/bin/bash

# Check validity of the arguments
if [ $# -lt 3 ]
then
	echo "Invalid no of arguments"
	echo "Usage: $0 <Number of files> <min no of grams> <max no of grams>"
	exit 1
fi

# Initialize arguments
FILECNT=$1
MINGRAMS=$2
MAXGRAMS=$3

CWD=$PWD
cd "/media/My Book/CB/PGBooks/"

# Set redirection
exec 1>$CWD/$FILECNT-$MINGRAMS-$MAXGRAMS-`date +'%Y%m%d%H%M%S'`.log 2>&1

# Generate statistics
genStats() {
	rm -f $1.stat*

	awk '{ print NF }' $1 >> $1.stat

	sort -g $1.stat >> $1.stat.2
	rm -f $1.stat
	mv $1.stat.2 $1.stat 

	uniq -c $1.stat | awk '{ for( i = 2 ; i <= NF ; i++ ) printf( "%s%s", $i, OFS ); print $1 }' >> $1.stat.2
	cat $1.stat.2

	N50=`cat $1.stat.2 | awk 'BEGIN{N50=0} {N50+=$1*$2} END{print N50/2}'`
	cat $1.stat.2 | awk -v var=$N50 'BEGIN{F=0;FL=0} {FL+=$1*$2; if(F==0 && FL>=var) F=$1} END{printf "======================================\nN50::%d\n", F}'
	
	echo "NoOfFragments::"`wc -l $1`
	echo -e "======================================\n"

	rm -f $1.stat
	rm -f $1.stat.2
}

minGrams=$MINGRAMS
maxGrams=$MAXGRAMS
for (( ; minGrams <= maxGrams ; minGrams++ ))
do
	gramFile=$FILECNT"Books.txt"$minGrams".sort.gram"

	# Delete rare fragments
	gramNo=`expr $minGrams + 1`
	rm -f $gramFile.del
	awk '{if (($NF != 1)&&($NF != 2)&&($NF != 3)) printf "%s\n", $0}' $gramFile >> $gramFile.del

	#gramToDel=`awk '{print $gramNo}' $gramFile | sort -h | uniq -c | awk '{if ($1 < 40 ) print $2}'`

	#for curGram in $gramToDel
	#do
	#	awk '{if ($gramNo != $curGram) for(int i=1 ; i<=NF ; i++) print $i, }' $gramFile >> $gramFile.del
	#done

	# Reconstruct book
	time $CWD/recnBook $gramFile.del $minGrams
	if [ $? -eq 1 ]
	then
		echo "Some error occured while reconstruction for $minGrams""Grams"
		exit 1
	fi

	# Generate statistics and N50
	echo -e "\nGenerating Statistics on number of words in each fragment and the count of such matching fragments ..."
	genStats $gramFile.del.recn
done
