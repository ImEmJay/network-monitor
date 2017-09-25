#!/bin/bash

#
# Based on a script by Sam Hobbs
# https://samhobbs.co.uk/2013/11/fix-for-ethernet-connection-drop-on-raspberry-pi
#

INTERFACES=${NETWORK_MONITOR_INTERFACES:-"eth0"}
STATUS_QUERY='inet\s*\K.*(?=\s+netmask)'

log() {
	local message="$(date "+%m %d %Y %T") : $1"
	echo $NETWORK_MONITOR_LOGFILE
	if test $NETWORK_MONITOR_LOGFILE
	  then
			echo $message >> $NETWORK_MONITOR_LOGFILE
	else
	  echo $message
	fi  
}

for i in $INTERFACES; do
	if ifconfig $i | grep -qoP $STATUS_QUERY;
		then
      log "$i OK"
	else
		log "$i connection down! Attempting reconnect."
    ifup --force $i
    OUT=$? #save exit status of last command to decide what to do next
    if [ $OUT -eq 0 ] ; then
      STATE=ifconfig $i | grep -qoP $STATUS_QUERY
      log "$i connection reset. Current state is $STATE"
    else
      log "Failed to reconnect $i"
    fi
  fi
done

