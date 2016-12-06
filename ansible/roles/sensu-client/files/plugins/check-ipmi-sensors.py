#!/usr/bin/python
#
# Author: Chris Chandler (chrchand@cisco.com)
#
# Description: Simple parsing of 'ipmitool sensor list' to look for any non-OK statuses. Returns exit codes per Nagios plugin standard based on sensor status.
#
# UCS IPMI Reference Doc:
# http://www.cisco.com/c/en/us/td/docs/unified_computing/ucs/ts/guide/UCSTroubleshooting/UCSTroubleshooting_chapter_01000.html#reference_DD36791B504E4833A8E14EBC67A7DFD5
#
# ipmitool sensor list column header reference: https://sourceforge.net/p/ipmitool/mailman/message/21976401/
#

import subprocess
import sys

sensor_count = 0
failed_sensors = 0

try:
    ipmi_sensor_data = subprocess.check_output('sudo ipmitool sensor list', shell=True)

except Exception as e:
    print "Unable to run ipmitool. Make sure the ipmitool package is installed."
    sys.exit(2)


# print ipmi_sensor_list

ipmi_sensor_list = ipmi_sensor_data.splitlines()

for sensor_data in ipmi_sensor_list:
    # print sensor_data
    sensor_count += 1
    columns = sensor_data.split('|')
    sensor_name = columns[0]
    sensor_value = columns[1]
    sensor_state = columns[3].lstrip()
    sensor_lower_crit = columns[5]
    sensor_upper_crit = columns[7]
    # print 'Sensor data: ' + sensor_name + ' has state ' + sensor_state
    if (sensor_state.lower().startswith('ok')) or (sensor_state.lower().startswith('na')) or (sensor_state.lower().startswith( '0x')):
        continue
    else:
        failed_sensors += 1
        print 'Sensor ' + sensor_name + ' is reporting unexpected status ' + sensor_state + '. Was expecting "ok" or "na".'

if failed_sensors == 0:
    print "Sensor count: " + str(sensor_count) + ". No failed sensors found."
    sys.exit(0)
else:
    print str(failed_sensors) + " sensors out of " + str(sensor_count) + " sensors reporting issues. See list above for details."
    sys.exit(2)
