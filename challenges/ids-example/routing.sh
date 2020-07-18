#!/bin/sh

# Reference: https://www.systutorials.com/setting-up-gateway-using-iptables-and-route-on-linux/

# Enable IP forwarding
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf

# The following iptables stuff is not needed for this example; but I'm leaving my code in there for inspiration
# It probably doesn't work, but the reference should help
# Establish forwarding rules via iptables (kali -> victim)
# iptables -t nat -A POSTROUTING ! -d 192.168.31.0/24 -o eth1 -j SNAT --to-source 192.168.31.1

# Establish forwarding rules via iptables (victim -> kali)
# iptables -t nat -A POSTROUTING ! -d 192.168.32.0/24 -o eth2 -j SNAT --to-source 192.168.32.1
# iptables -t nat -A POSTROUTING -i eth1 -s
# Save forwarding rules in case on unexpected reboot
# Can't use this right now as su -c (for sudo redirects) requests password auth
#iptables-save > /etc/iptables.rules

# Add crontab to restore forwarding rules on boot via iptables-restore
#cd /tmp
#crontab -l > rootcron
#echo "@reboot iptables-restore" >> rootcron
#crontab rootcron
#rm rootcron
