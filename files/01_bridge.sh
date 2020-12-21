#!/bin/bash
br="br-0"
interface=$1
status=$2
address=$(/usr/bin/ip -4 -br addr show $interface | /usr/bin/grep -Po "\\d+\\.\\d+\\.\\d+\\.\\d+")
mask=$(/usr/bin/ip -4 -br addr show $interface | /usr/bin/grep -Po "\\/\\d+\\d+")
route=$(/usr/bin/ip -4 route  | /usr/bin/grep default | /usr/bin/grep -Po "\\d+\\.\\d+\\.\\d+\\.\\d+")
dhnsmaq_file="/etc/dnsmasq.d/dhcp_server.conf"
if [[ "enp2s0 enp0s20f0u2u4i5 wlp3s0" == *"$interface"* ]]
then
if [ "$status" == "up" ]
then
		/usr/bin/iptables -t nat -A POSTROUTING -o $interface -j MASQUERADE
		/usr/bin/iptables -t nat -A POSTROUTING -o br-0 -j MASQUERADE
		ip link add name $br type bridge
		ip link set $br up
		ip link set $interface up
		/usr/bin/killall parprouted
		/usr/bin/killall dhcp-helper


		if [ "$interface" == "wlp3s0" ]
		then
		/usr/bin/killall parprouted
		/usr/bin/killall dhcp-helper
		/usr/bin/ip addr add $address/32 dev $br
		/usr/bin/parprouted $br $interface
		#/usr/bin/dhcrelay -d -4 -iu $interface -id $br $(/usr/bin/journalctl -b -u systemd-networkd.service | /usr/bin/grep -Po "via\s+\K\\d+\\.\\d+\\.\\d+\\.\\d+")
		#/usr/bin/dhcp-helper -b $interface -i $br
		#echo "dhcp-relay=$address,$route" > /etc/dnsmasq.d/dhcp_server.conf
		#systemctl restart dnsmasq
		else
			/usr/bin/ip addr add $address$mask dev $br
	        	/usr/bin/ip addr del $address$mask dev $interface
		        /usr/bin/ip route add 0.0.0.0/0 via $route
			ip link set $interface master $br
		fi
		exit 0
		#ip netns add ns0
		#ip link add $interface ipvl0 type ipvlan mode l2
		#ip link set dev ipvl0 netns ns0
		#ip netns exec ns0 ip link set dev ipvl0 up
		#ip netns exec ns0 ip link set dev lo up
		#ip netns exec ns0 ip -4 addr add 127.0.0.1 dev lo
		#ip netns exec ns0 ip -4 addr add $IPADDR dev ipvl0
		#ip netns exec ns0 ip -4 route add default via $ROUTER dev ipvl0
fi
if [ "$status" == "down" ]
then
	/usr/bin/iptables -t nat -D POSTROUTING -o $interface -j MASQUERADE
	/usr/bin/iptables -t nat -D POSTROUTING -o br-0 -j MASQUERADE
	ifconfig $br 0.0.0.0
        /usr/bin/killall parprouted
        /usr/bin/killall dhcp-helper
fi
fi
exit 0
