#!/bin/bash


PUB_IF=$(ip a| grep "BROADCAST" | awk -F ":" 'NR==1{print $2}' | sed "s/ //g")

# Empty all rules
iptables -t filter -F
iptables -t filter -X
iptables -t filter -Z

iptables -t nat -F
iptables -t nat -X
iptables -t nat -Z

# Bloc INPUT
iptables -t filter -P INPUT DROP
iptables -t filter -P FORWARD ACCEPT
iptables -t filter -P OUTPUT ACCEPT

# Authorize already established connexions
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

iptables -t nat -P PREROUTING ACCEPT
iptables -t nat -P POSTROUTING ACCEPT
iptables -t nat -P OUTPUT ACCEPT


# Block sync
# iptables -A INPUT -i ${PUB_IF} -p tcp ! --syn -m state --state NEW -j DROP
 
# Block Fragments
# iptables -A INPUT -i ${PUB_IF} -f -j DROP

# ICMP (Ping)
iptables -t filter -A INPUT -p icmp -j ACCEPT

# SSH
iptables -t filter -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -t filter -A INPUT -p tcp --dport 1696 -j ACCEPT

# DNS
iptables -t filter -A INPUT -p tcp --dport 53 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
iptables -t filter -A INPUT -p udp --dport 53 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT

# HTTP HTTPS
iptables -t filter -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -t filter -A INPUT -p tcp --dport 443 -j ACCEPT

# NTP (server time)
iptables -t filter -A OUTPUT -p udp --dport 123 -j ACCEPT


# Download IP List
if [ -e ips.txt ]
then
echo "already got ips.txt"
else wget "https://raw.githubusercontent.com/hsuzo1/iptables-init/main/ips.txt"
fi

# Add All Trusted IPs to iptables
for ip in `cat ips.txt`
do
iptables -I INPUT -s $ip -j ACCEPT
done


echo "All Done!"
