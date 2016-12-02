#!/bin/bash
lower_port=$1
upper_port=$2
ports="$(netstat -anlp | grep 'LISTEN ')"
for (( port = lower_port ; port <= upper_port ; port++ )); do
    echo $ports | grep $port
    if [[ "$?" != 0 ]]; then
        echo $port
	    break;
    fi
done