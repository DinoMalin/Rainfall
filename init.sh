#!/bin/bash

if ! which sshpass 2>&1 >/dev/null; then
	echo "error: sshpass not installed" 1>&2
	exit 1
fi

NAME=Rainfall

MAC=$(VBoxManage showvminfo $NAME \
	| grep "NIC 1" | awk '{print $4}' | sed 's/../&:/g' | sed 's/:,//')
IP=$(arp -a | grep -i $MAC | awk '{print $2}' | sed 's/(\([^)]*\))/\1/')

get_flag() {
	head level$(($1-1))/expl | head -n 1 | awk '{print $2}'
}

get_binary() {
	FLAG=$(get_flag $1)
	if [ -z $FLAG ]; then
		exit 1
	fi

	mkdir -p level$1
	sshpass -p $FLAG scp -P 4242 level$1@$IP:level$1 level$1
}

if [ $1 = "connect" ]; then
	if [ -z $2 ]; then
		echo "usage: $0 connect <level>" 1>&2
		exit 1
	fi

	FLAG=$(get_flag $2)
	if [ -z $FLAG ]; then
		exit 1
	fi

	sshpass -p $FLAG ssh $IP -p 4242 -l level$2
	exit 0
fi

if [ $1 = "copy" ]; then
	if [ -z $2 ]; then
		echo "usage: $0 copy <level>" 1>&2
		exit 1
	fi

	if [ $2 = "all" ]; then
		for i in {0..9}; do
			get_binary $i
		done
		exit 0
	fi

	get_binary $2
	exit 0
fi

