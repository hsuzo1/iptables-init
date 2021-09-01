#!/bin/sh

# Empty all rules
sudo iptables -t filter -F
sudo iptables -t filter -X

# Bloc everything by default but OUTPUT
sudo iptables -t filter -P INPUT DROP
sudo iptables -t filter -P FORWARD DROP
sudo iptables -t filter -P OUTPUT ACCEPT

# Authorize already established connexions
sudo iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -t filter -A INPUT -i lo -j ACCEPT
sudo iptables -t filter -A OUTPUT -o lo -j ACCEPT

# ICMP (Ping)
sudo iptables -t filter -A INPUT -p icmp -j ACCEPT

# SSH
sudo iptables -t filter -A INPUT -p tcp --dport 22 -j ACCEPT
sudo iptables -t filter -A INPUT -p tcp --dport 1696 -j ACCEPT

# DNS
sudo iptables -t filter -A INPUT -p tcp --dport 53 -j ACCEPT
sudo iptables -t filter -A INPUT -p udp --dport 53 -j ACCEPT

# HTTP HTTPS
sudo iptables -t filter -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -t filter -A INPUT -p tcp --dport 443 -j ACCEPT

# FTP
#sudo iptables -t filter -A INPUT -p tcp --dport 20:21 -j ACCEPT

# Git
#sudo iptables -t filter -A INPUT -p tcp --dport 9418 -j ACCEPT

# Mail SMTP
#iptables -t filter -A INPUT -p tcp --dport 25 -j ACCEPT

# Mail POP3
#iptables -t filter -A INPUT -p tcp --dport 110 -j ACCEPT

# Mail IMAP
#iptables -t filter -A INPUT -p tcp --dport 143 -j ACCEPT

# NTP (server time)
sudo iptables -t filter -A OUTPUT -p udp --dport 123 -j ACCEPT


# Download IP List
if [ -e ips.txt ]
then
echo "already got ips.txt"
else wget "http://downloads.sourceforge.net/hibernate/hibernate-3.2.5.ga.zip?modtime=1185893922&big_mirror=1"
fi

# Add Trusted IPs
for ip in `cat ips.txt`
do
iptables -I INPUT -s $ip -j ACCEPT
done

