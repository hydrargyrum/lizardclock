#!/bin/sh
# Dev. date : 2009/10/17
# 2009/11/09 : added support for analog clock hour hands
# 2009/11/10 : added support for moonphase
# current version : 3
# this file is under the "do What The Fuck you want Public License v2"

# requires: convert [from imagemagick], unzip, POSIX grep/date/mktemp
# free of any bashism/gnuism

set -e
[ $# -ne 1 ] && {
	echo "usage: $0 FILE.WCZ"
	exit 1
}

moonphase () {
	# adapted from Vlad Gerasimov's algorithm
	jd=$1
	MOT=2953058
	MOS=486700
	intfactor=100000
	jd=`expr $jd \* $intfactor`
	age=`expr \( $jd + $MOS \) \* $intfactor / $MOT`
	age=`expr 2 \* \( $age - \( \( $age / $intfactor \) \* $intfactor \) \) - $intfactor`
	if [ $age -lt 0 ]
	then
		age=`expr $MOT \* \( $intfactor + $age / 2 \) / $intfactor`
	else
		age=`expr \( $age \* $MOT / 2 \) / $intfactor`
	fi
	if [ $age -ge $MOT ]
	then
		age=0
	fi
	expr $age / $intfactor + 1
}

zipf=$1
shift

output=$PWD/output.png

set -- `LANG=C date +"%m %d %u %P %H %I %M %j"`
month=month${1#0}.png; shift
day=day${1#0}.png; shift
weekday=weekday$1.png; shift
ampm=$1.png; shift
hours24=hour${1#0}.png; shift
hours12=hour${1#0}.png; hourshand=`expr $1 \* 60`; shift
minutes=minute${1#0}.png; hourshand=`expr $1 + $hourshand`; shift
moonphase=moonphase`moonphase $1`.png; shift
hourshand=hour`expr $hourshand / 12`.png

if [ -d "$zipf" ]
then
	dir=$zipf
else
	dir=`mktemp -d "clock.XXXXXX"`
	[ -z "$dir" ] && exit 1

	# exit 11 means some files not in the zipfile
	unzip -qL "$zipf" -d "$dir" $month $day $weekday $ampm $hours24 ${hours12#$hours24} $minutes $hourshand $moonphase clock.ini bg.jpg || [ $? -eq 11 ]
	#tar -x -f"$zipf" -C "$dir" $month $day $weekday $ampm $hours24 ${hours12#$hours24} $minutes clock.ini bg.jpg
fi
cd "$dir"

if grep -q 'ampmenabled[[:space:]]*=[[:space:]]*1' clock.ini
then
	haspm=`date +%p`
	hours=${haspm:+$hours12}
	hours=${hours:-$hours24}
else
	haspm=
	hours=$hours24
fi
if grep -q 'hourimages[[:space:]]*=[[:space:]]*60' clock.ini
then
	hours=$hourshand
fi

convert bg.jpg $moonphase -composite $month -composite $weekday -composite $day -composite $hours  -composite $minutes -composite ${haspm:+$ampm} ${haspm:+-composite} $output

cd -
rm -rf "$dir"
