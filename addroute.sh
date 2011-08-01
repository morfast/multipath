#!/bin/bash

VPNGATE="10.8.0.33"
LOCALGATE="192.168.1.1"

#ip route | grep -q '58.17.0.0'
#if [ $? -eq 0 ]; then
#    echo "routes already added"
#    exit 0
#fi

while read line
do
    ip route del ${line} &> /dev/null

    ip route add ${line} \
    nexthop via ${VPNGATE} dev tun0  weight 40 \
    nexthop via ${LOCALGATE} dev eth0  weight 25 

done < routes

while read line
do
    ip route add ${line} via ${LOCALGATE}
done < directlist

