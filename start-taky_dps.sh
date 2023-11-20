#!/bin/bash
# restart if taky not configured yet
if [ ! -f /data/taky/taky.conf ] 
then
    echo "TAKY not configured yet, wait a bit"
    sleep 5
    exit 1
fi
#echo "/data contains:"
#find /data -print
cd /data/taky
echo "data upload path:"
grep upload taky.conf
/usr/local/bin/taky_dps
