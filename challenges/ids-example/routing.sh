#!/bin/sh

# Reference: https://www.systutorials.com/setting-up-gateway-using-iptables-and-route-on-linux/

# Enable IP forwarding
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf

# Establish forwarding rules via iptables (kali -> victim)
iptables -t nat -A POSTROUTING ! -d 192.168.31.0/24 -o eth2 -j SNAT --to-source 192.168.32.1

# Establish forwarding rules via iptables (victim -> kali)
iptables -t nat -A POSTROUTING ! -d 192.168.32.0/24 -o eth1 -j SNAT --to-source 192.168.31.1

# Save forwarding rules in case on unexpected reboot
# Can't use this right now as su -c (for sudo redirects) requests password auth
iptables-save > /etc/iptables.rules

# Add crontab to restore forwarding rules on boot via iptables-restore
cd /tmp
crontab -l > rootcron
echo "@reboot iptables-restore" >> rootcron
crontab rootcron
rm rootcron
