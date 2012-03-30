#!/bin/bash

if [ $# -ne 1 ]
then
	echo "Invalid number of arguments"
	echo "Usage: $0 <number of books to download>"
	exit 1
fi

BOOKCNT=$1
i=10
dwnldCnt=0

for (( i = 10 ; i < BOOKCNT ; i++ ))
do
	if [ -f $i.txt ]
	then
		dwnldCnt=`expr $dwnldCnt + 1`
	else
		wget http://www.gutenberg.org/files/$i/$i.txt
		if [ $? -eq 0 ]
		then
			dwnldCnt=`expr $dwnldCnt + 1`
		fi
	fi
done

echo $dwnldCnt" books downloaded successfully"
