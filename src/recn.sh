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
cd "/media/My Book/CB/"

# Set redirection
exec 1>$CWD/$FILECNT-$MINGRAMS-$MAXGRAMS-`date +'%Y%m%d%H%M%S'`.log 2>&1

# Sort the splitted file
sortFile() {
	rm -f $1.sort
	sort $1 >> $1.sort

	if [ $? -ne 0 ]
	then
		echo "Some error occured during sorting of $1"
		exit 1
	fi
}

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
	cat $1.stat.2 | awk -v var=$N50 'BEGIN{F=0;FL=0} {FL+=$1*$2; if(F==0 && FL>=var) F=$1} END{printf "======================================\nN50 :: %d\n", F}'
	
	echo "No of fragments :: "`wc -l $1`
	echo -e "======================================\n"

	rm -f $1.stat
	rm -f $1.stat.2
}

# 1. Split i/p file so that files for different grams are created starting from 2Grams upto max no of grams i/p by user
# 2. Once split is successful, sort the splitted file
# 3. Once sort is successful, create grams from the sorted file
# 4. Remove intermediate files created for nGrams
# 5. Reconstruct book
# 6. Calculate statistics

minGrams=$MINGRAMS
maxGrams=$MAXGRAMS
curFileCnt=9
for (( i = 0 ; i < FILECNT ; ))
do
	# Split the file
	curFileCnt=`expr $curFileCnt + 1`
	fileToSplit=./PGBooks/$curFileCnt.txt

	if [ -f $fileToSplit ]
	then
		echo "Processing "$fileToSplit" ..."

		# To be on a safer side, take care of "^M" characters
		cat $fileToSplit | tr -d '\15' >> $fileToSplit.2
		rm -f $fileToSplit
		mv $fileToSplit.2 $fileToSplit

		for (( minGrams = MINGRAMS ; minGrams <= maxGrams ; minGrams++ ))
		do
			rm -f ./PGBooks/$FILECNT"Books.txt"$minGrams.sort.gram.recn

			if [ ! -f $fileToSplit$minGrams ]
			then
				$CWD/fileSplitter $fileToSplit $minGrams
				if [ $? -ne 0 ]
				then
					echo "Some error occured during file splitting for $minGrams""grams"
					exit 1
				fi
			fi
		done

		i=`expr $i + 1`
	fi
done

echo ""

minGrams=$MINGRAMS
for (( ; minGrams <= maxGrams ; minGrams++ ))
do
	mrgFile=./PGBooks/$FILECNT"Books".txt$minGrams
	rm -f $mrgFile

	curFileCnt=9
	for (( i = 0 ; i < FILECNT ; ))
	do
		curFileCnt=`expr $curFileCnt + 1`
		curFileToMrg=./PGBooks/$curFileCnt.txt$minGrams

		if [ -f $curFileToMrg ]
		then
			cat $curFileToMrg >> $mrgFile
			echo "" >> $mrgFile
			i=`expr $i + 1`
		fi
	done

	# This check is really important
	err=`cat $mrgFile | awk '{ print NF }' | sort -u | wc -l`
	if [ $err -gt 1 ]
	then
		echo "Number of fields in file $mrgFile are more than $minGrams"
		exit 1
	fi

	# Sort the splitted file
	sortFile $mrgFile

	# Create grams for the sorted file
	uniq -c $mrgFile.sort | awk '{ for( i = 2 ; i <= NF ; i++ ) printf( "%s%s", $i, OFS ); print $1 }' >> $mrgFile.sort.gram
	if [ $? -eq 0 ]
	then
		echo `wc -l $mrgFile | awk '{print $1}'` $minGrams"Grams created successfully from all "$FILECNT" requested books"
	else
		echo "Some error occured while creating $minGrams""Grams"
		exit 1
	fi

	# Reconstruct book
	time $CWD/recnBook $mrgFile.sort.gram $minGrams
	if [ $? -eq 1 ]
	then
		echo "Some error occured while reconstruction for $minGrams""Grams"
		exit 1
	fi

	# Generate statistics and N50
	echo -e "\nGenerating Statistics on number of words in each fragment and the count of such matching fragments ..."
	genStats $mrgFile.sort.gram.recn

	# Remove intermediate files created for nGrams
	rm -f $mrgFile
	rm -f $mrgFile.sort
#	rm -f $mrgFile.sort.gram
done
