#!/bin/sh
# this file is under the WTFPLv2
# dev. date: 2009/10/17

set -e

pidfile=${XDG_CACHE_HOME:-$HOME/.cache}/lizardclock.pid
themefile=${XDG_CONFIG_HOME:-$HOME/.config}/lizardclock.theme

finish () {
	cleanup
	exit
}

cleanup () {
	rm -f $pidfile
}

reload () {
	read theme < "$themefile" 2>/dev/null || theme=
	reset
}

reset () {
	echo $theme
	# lizardclock-get "$theme"
}

main () {
	if kill -0 `cat "$pidfile"`
	then
		# daemon already running
		exit 10
	fi
	trap finish EXIT
	cleanup
	mkdir -p "`dirname "$pidfile"`"
	sh -c 'echo $PPID' > "$pidfile" # $$ is not the daemon's pid, gotcha
	
	trap reload HUP
	reload
	while true
	do
		sleep 60
		reset
	done
}

( cd /; ( main ) & ) &
