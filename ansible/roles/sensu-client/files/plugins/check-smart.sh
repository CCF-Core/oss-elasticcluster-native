#!/bin/bash

DEVICELIST=""
DEVICEDETAILS=""
DEVICESERIAL=""
DEVICESTATUS=""
FAILURES=0
DEVICES=0

DEVICELIST=$(sudo /opt/MegaRAID/storcli/storcli64 /c0 /eall /sall show | egrep "SAS|SATA" | awk -F ":" '{print $2}' | awk '{print $2}')

for DEVICE in $DEVICELIST; do
    DEVICES=$(($DEVICES + 1))
    DEVICEDETAILS=$(sudo smartctl -H -d megaraid,$DEVICE -a /dev/sda)
    DEVICESERIAL=$(egrep "Serial" <<< "$DEVICEDETAILS")
    DEVICESTATUS=$(egrep "SMART.*ealth" <<< "$DEVICEDETAILS")
    if [[ ! $DEVICESTATUS =~ .*OK ]] && [[ ! $DEVICESTATUS =~ .*PASSED ]]; then
        FAILURES=$(($FAILURES + 1))
        echo "Device ID $DEVICE: $DEVICESERIAL $DEVICESTATUS"
    fi
done

if (( $DEVICES == 0)); then
    echo "No devices found. Please investigate!"
    exit 2
fi

if (( $FAILURES > 0 )); then
    echo "Failure count is: $FAILURES"
    exit 2
else
    echo "SMART Health OK on all $DEVICES drives"
    exit 0
fi

echo "Script failed to run properly. Please investigate!"
exit 2
