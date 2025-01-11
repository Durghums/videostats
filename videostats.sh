#!/bin/bash

MOVIE=`ls -1S | head -n 1`
MOVIESIZE=`du -m "$MOVIE" | sed 's/\(^.*\)\t.*$/\1/'`

echo -e "\nFile name:\t$MOVIE"
echo -e "File size:\t$MOVIESIZE MB"

ffprobe -hide_banner "$MOVIE" 2>report.log

grep -e Duration <report.log | sed -e 's/^  \(Duration:\) 0\(.:.*\), .*, .*$/\1\t\2/'
grep -e Duration <report.log | sed -e 's/^.*\(itrate:\) \(.*$\)/B\1\t\2/'

echo

while IFS= read -r line
do
	ISSTREAM=`echo "$line" | grep -e Stream`
	if [ -n "$ISSTREAM" ]
	then
		STREAMID=`echo $line | awk '{print $2}'`
		STREAMTYPE=`echo $line | awk '{print $3}'`
		CODEC=`echo $line | awk '{print $4}' | sed 's/,//' `
		DISPSIZE=`echo $line | grep -e Video | sed 's/^.* \([0-9]*x[0-9]*\).*$/\1/'`
		BITRATE=`echo $line | grep -e kb/s | sed -e 's/^.* \([0-9]* kb\/s\).*$/\1/'`
		FRAMERATE=`echo $line | grep -e Video | sed -e 's/^.*, \(.* fps\),.*$/\1/'`
		ISDEFAULT=`echo $line | grep -e default`
		
		echo -n Stream "$STREAMID"
		echo -n " $STREAMTYPE"
		echo -n " $CODEC"
		
		if [ -n "$DISPSIZE" ]
		then
			echo -n ", $DISPSIZE"
		fi
		
		if [ -n "$BITRATE" ]
		then
			echo -n ", $BITRATE"
		fi
		
		if [ -n "$FRAMERATE" ]
		then
			echo -n ", $FRAMERATE"
		fi
		
		if [ -n "$ISDEFAULT" ]
		then
			echo -n ", (default)"
		fi
		
		echo
	fi
	
done <report.log

rm report.log
