#!/bin/bash
# generate network traffic by using curl(ing) desturl from a range of IP addresses
# v1.1 - added cidr support
SECONDS=0 # dont change - used for figuring script run time

# user configurable vars:
desturl=google.com
network=192.168.20.
cidr=24
firstIP=240
lastIP=250
repeat=20
interface=ens192

# space-separated list of ports
ports=(80)
for itteration in $(seq 1 $repeat); do
	for ip in $(seq $firstIP $lastIP); do
		#echo ===========
		#echo LOOP $itteration
		#echo ===========
		# make sure the alias is not already configured
		sudo ifconfig $interface:$ip down
		
		# create the alias
		sudo ifconfig $interface:$ip $network$ip/$cidr up
		
		# curl to desturl on each port from alias ip 
		for i in ${ports[@]}; do
			echo =========================================================
			echo REPEAT $itteration
			echo SENDING TRAFFIC TO $desturl:$i FROM $network$ip
                	echo =========================================================
			curl --interface $interface:$ip $desturl:$i --insecure
			sleep 1
		done
		
		# tear down the alias
		sudo ifconfig $interface:$ip down

	done
done

duration=$SECONDS
echo -----------------
echo FINISHED in $(($duration / 60))m $(($duration % 60))s
echo -----------------
