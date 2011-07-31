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
    ip route del ${line} 

    ip route add ${line} \
    nexthop via ${VPNGATE} dev tun0  weight 40 \
    nexthop via ${LOCALGATE} dev eth0  weight 25 

done < routes

ip route add 111.142.0.0/255.255.0.0        via ${LOCALGATE}
ip route add 112.5.66.69 via ${LOCALGATE} 
ip route add 59.77.33.124 via ${LOCALGATE}

