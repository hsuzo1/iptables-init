#!/bin/bash


PUB_IF=$(ip a| grep "BROADCAST" | awk -F ":" 'NR==1{print $2}' | sed "s/ //g")

# Empty all rules
sudo iptables -t filter -F
sudo iptables -t filter -X
sudo iptables -t filter -Z

sudo iptables -t nat -F
sudo iptables -t nat -X
sudo iptables -t nat -Z

# Bloc INPUT
sudo iptables -t filter -P INPUT DROP
sudo iptables -t filter -P FORWARD ACCEPT
sudo iptables -t filter -P OUTPUT ACCEPT

# Authorize already established connexions
sudo iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A OUTPUT -o lo -j ACCEPT

sudo iptables -t nat -P PREROUTING ACCEPT
sudo iptables -t nat -P POSTROUTING ACCEPT
sudo iptables -t nat -P OUTPUT ACCEPT


# Block sync
# sudo iptables -A INPUT -i ${PUB_IF} -p tcp ! --syn -m state --state NEW -j DROP
 
# Block Fragments
# sudo iptables -A INPUT -i ${PUB_IF} -f -j DROP

# ICMP (Ping)
sudo iptables -t filter -A INPUT -p icmp -j ACCEPT

# SSH
sudo iptables -t filter -A INPUT -p tcp --dport 22 -j ACCEPT
sudo iptables -t filter -A INPUT -p tcp --dport 1696 -j ACCEPT

# DNS
sudo iptables -t filter -A INPUT -p tcp --dport 53 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
sudo iptables -t filter -A INPUT -p udp --dport 53 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT

# HTTP HTTPS
sudo iptables -t filter -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -t filter -A INPUT -p tcp --dport 443 -j ACCEPT

# NTP (server time)
sudo iptables -t filter -A OUTPUT -p udp --dport 123 -j ACCEPT


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
