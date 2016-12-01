#!/bin/bash
set -x
lower_port=953
upper_port=955
ports="$(netstat -anlp | grep 'LISTEN ')"
    for (( port = lower_port ; port <= upper_port ; port++ )); do
        #nc -l -p "$port" 2>/dev/null && break 2
        echo $ports | grep $port
        if [[ "$?" != 0 ]]; then
            echo $port
 	    break;
        fi
    done