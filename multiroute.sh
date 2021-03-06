#!/bin/bash

ROUTECMD="ip route add default \\
          "

./vpn.sh
./addroute.sh

# disable routing cache
echo -1 > /proc/sys/net/ipv4/rt_cache_rebuild_count

iptables -F

#declare -a IP_PPP

ip rule flush
ip rule del prio 0 from all lookup main &> /dev/null
ip rule del prio 0 from all lookup default &> /dev/null
ip rule add prio 32766 from all lookup main
ip rule add prio 32767 from all lookup default

# connect all xl2p vpn
for i in $(seq 0 7)
do
	echo "c mb${i}" > /var/run/xl2tpd/l2tp-control
	while :
	do
		ip route | grep -q ppp${i}
		if [ $? -eq 0 ]; then
			echo ppp${i} up
			break
		fi
		sleep 1
	done
    echo "ppp$i connected"

    IP_PPP=$(ip route | grep ppp${i} | awk '{print $9}')

    echo -n "modify routing table... "
    ip route flush table P${i}
    ip route add $(ip route show table main | grep "ppp${i}.*src") table P${i}
    ip route add default via ${IP_PPP} table P${i}
    echo "OK"

    echo -n "routing rule ..."
    ip rule add prio 30000 from ${IP_PPP} table P${i}
    echo "OK"

    GATE=$(ip route | grep 'ppp0.*src' | awk '{print $1}')
    ROUTECMD="${ROUTECMD}nexthop via ${GATE} dev ppp${i}  weight 10 \\
              "

    iptables -A INPUT -i ppp${i} -j ACCEPT
done



echo -n "tun0 ... " 
ip route flush table T0
ip route add $(ip route show table main | grep 'tun0.*src') table T0
ip route add default via 10.8.0.33 table T0

ip rule add prio 30000 from 10.8.0.34 table T0
iptables -A INPUT -i tun0 -j ACCEPT
ROUTECMD="${ROUTECMD} nexthop via 10.8.0.33 dev tun0  weight 80 "

echo "OK"

echo -n "eth0 ... " 
ip route flush table E0
ip route add $(ip route show table main | grep 'eth0.*src') table E0
ip route add default via 192.168.1.1 table E0

ip rule add prio 20000 from 192.168.1.2 table E0
iptables -A INPUT -i eth0 -j ACCEPT

echo "OK"

ip route del 222.47.62.142
ip route del 222.47.29.93
ip route add 222.47.62.142 via ${GATE}
ip route add 222.47.29.93 via ${GATE}


ip route del default
eval "${ROUTECMD}"

#ip route add default \
#nexthop via 10.8.0.33 dev tun0  weight 40 \
#nexthop via ${GATE} dev ppp0  weight 25 \
#nexthop via ${GATE} dev ppp1  weight 25 \
#nexthop via ${GATE} dev ppp2  weight 25 \
#nexthop via ${GATE} dev ppp3  weight 25 
#
