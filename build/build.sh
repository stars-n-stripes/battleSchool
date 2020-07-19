#!/bin/bash

# Located for now at https://raw.githubusercontent.com/stars-n-stripes/battleSchool/master/build/build.sh

# Set color variables
RED='\033[0;31m'
BLU='\033[0;34m'
WHT='\033[1;37m'
NC='\033[0m' 


# This script should be (initially) run as root, though it will su to dev for Vagrant operations
if [[ "$USER" != "root" ]]
then 
	echo -e "For developer user setup, please run this script as root or with sudo"
	exit
fi

# Input validation
if [[ -z $1 || -z $2 || -z $3 ]]
then 
	echo -e "Usage: [sudo] $0 <dev password> <student password> <challenge>"
	exit
fi

echo -e "===${BLU}Battle School build script for Ubuntu Server 20.04 LTS${NC}==="
echo -e "Author: delogrand/starsnstripes"

# This will help appease apt, and will set an environment variable for the scenario
export DEBIAN_FRONTEND=noninteractive
export SCENARIO_NAME=$3

echo -e "${BLU}[+]${WHT} Installing mkpasswd. . . ${NC}"
apt install -yqq whois

echo -e "${BLU}[+]${WHT} Creating developer user (dev). . . ${NC}"
dev_hash="$(mkpasswd -m sha512crypt $1)" 
useradd dev -p $dev_hash -m -s /bin/bash
usermod -aG sudo dev

apt update -yqq > /dev/null

# Install XFCE 
# gdm3 is installed by default on Ubuntu Server, but XFCE is a lighter alternative
echo -e "${BLU}[+]${WHT} Removing gdm3 and installing lightdm. . . ${NC}"

apt install -yqq lightdm > /dev/null
sed -i 's:/usr/sbin/gdm3:/usr/sbin/lightdm:'

echo -e "${BLU}[+]${WHT} Installing XFCE desktop environment. . . ${NC}"
# This download is over a gig, so it's slightly more verbose
apt install -yq xfce4 xfce4-goodies xorg dbus-x11 x11-xserver-utils rdesktop xfce4-terminal > /dev/null
apt remove -yqq gdm3 --purge
# Might be able to remove gnome-shell from this, I'll have to check sometime
apt remove -yqq --auto-remove ubuntu-gnome-desktop gnome-shell
# Install the RDP server and associate the new xrdp user with the ssl-cert group
# https://askubuntu.com/questions/592537/can-i-access-ubuntu-from-windows-remotely/592544#592544
echo -e "${BLU}[+]${WHT} Installing xrdp and adding xrdp user to ssl-cert group. . . ${NC}"
apt install -yqq xrdp > /dev/null
adduser xrdp ssl-cert  


# Install virtualization software (vbox now, TODO is to move to KVM)
echo -e "${BLU}[+]${WHT} Installing virtualbox. . . ${NC}"
apt install -yqq virtualbox > /dev/null
echo -e "${BLU}[+]${WHT} Disabling DHCP server for vboxnet0. . . ${NC}"
vboxmanage dhcpserver remove --ifname vboxnet0
# apt install -yqq qemu-kvm qemu virt-manager
# Note: for running qemu vms, make sure to add the option "-usbdevice tablet" to ensure accurate mouse mvmnt

echo -e "${BLU}[+]${WHT} Installing docker. . . ${NC}"
curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
sh /tmp/get-docker.sh
usermod -aG docker dev

# Pull a custom xrdp config that kicks the "student" user to the kali VM (once it's up) (Uncomment for manual)
echo -e "${BLU}[+]${WHT} Downloading and applying xrdp settings. . . ${NC}"
wget https://raw.githubusercontent.com/stars-n-stripes/battleSchool/master/build/startwm.sh -O /etc/xrdp/startwm.sh
# TODO: Also pull down xrdp.ini with custom login screen
# In the Vagrant version of this script, this is done in the Vagrantfile

# Ensure the developer profile uses xfce on login:
echo -e "xfce4-session" > /home/dev/.xsession


# The following sed command forces xfce4 to run whenever a user connects 
# sed -i /etc/xrdp/startwm.sh 's/test -x .*//g; s/exec \/bin\/sh \/etc\/X11.*/startxfce4/gm' 
# ^ it's worth noting that sed uses different regex syntax than usual PCRE
# https://www.gnu.org/software/sed/manual/html_node/Regular-Expressions.html


# Vagrant libvirt plugin dependencies <-- using vbox rn, might switch later for performance reasons
# apt install ebtables install libxslt-dev libxml2-dev libvirt-dev zlib1g-dev ruby-dev

# Vagrant libvirt plugin included with apt package for vagrant
# Install vagrant
# TODO: Store the packages online somewhere so this system doesn't fall victim to an update
echo -e "${BLU}[+]${WHT} Installing vagrant. . . ${NC}"
# apt install -yqq vagrant > /dev/null
# The most up-to-date version (hosted on vagrantup.com) avoids a plethora of warnings that come with every execution of the newest apt package
wget https://releases.hashicorp.com/vagrant/2.2.9/vagrant_2.2.9_x86_64.deb -O /tmp/vagrant.deb
apt install -yqq /tmp/vagrant.deb
rm /tmp/vagrant.deb

# get the Vagrant file for this scenario
# Remember to set explicit port forwarding for the kali box ssh so we can know which port to forward via X11
echo -e "${BLU}[+]${WHT} Downloading scenario Vagrantfile. . . ${NC}"
wget "https://raw.githubusercontent.com/stars-n-stripes/battleSchool/master/challenges/$3/Vagrantfile" -O /tmp/Vagrantfile

# Vagrant setup
echo -e "${BLU}[+]${WHT} Creating scenario in the context of the dev user. . . ${NC}"
mkdir /scenario
chown dev:dev /scenario
# Pull the scenario configuration file from GH:
su dev -c 'wget "https://raw.githubusercontent.com/stars-n-stripes/battleSchool/master/challenges/$3/scenario.ini" -O /scenario/scenario.ini'
su dev -c "cd /scenario && vagrant init"
# Vagrant gripes if there's already a Vagrantfile in the current directory so we'll copy it in after
mv /tmp/Vagrantfile /scenario/Vagrantfile
chown dev:dev /scenario/Vagrantfile
# Turns out even a failure within a bash script provider is considered "critical" so we want to ignore them and put every machine up regardless
su dev -c "cd /scenario && vagrant up --no-destroy-on-error"

# alter the kali vm with vboxmanage to force it to be fullscreen all the time
# VBoxManage setextradata "<vm>" "GUI/Fullscreen" true

# It appears that the ssh private key location is in {VAGRANT PROJ DIR}/.vagrant/machines/{NAME}/virtualbox/private_key


# Possibly download the 32-bit kali linux distro
#wget https://cdimage.kali.org/kali-2020.2/kali-linux-2020.2-live-i386.iso

# Establish the users and groups so Student users are compartmentalized to their little corner
# -m ensures the creation of a home directory
# The student password is USAFACyberRange
echo -e "${BLU}[+]${WHT} Adding student user with password $1. . . ${NC}"
password_hash="$(mkpasswd -m sha512crypt $2)" 
useradd student -p $password_hash -m -s /usr/sbin/nologin
# Setting the user's shell to nologin will still allow them to authenticate via RDP and thus participate in the lab
# It'll just (hopefully) give them more of a headache if they somehow find a way to escape the SSH session

# In order for the student to have access to the Kali machine but not to the rest of the environment, we copy the private key and chown it
# We probably want to find a better approach in the future.
# TODO: Do we need to redo this when we revert the student machine?
echo -e "${BLU}[+]${WHT} Adjusting private key ownership for kali linux VM (dev -> student). . . ${NC}"
cp /scenario/.vagrant/machines/kali/virtualbox/private_key /scenario/.vagrant/machines/kali/virtualbox/private_key_student
chown student:student /scenario/.vagrant/machines/kali/virtualbox/private_key_student

# Add the vagrant up command to the User's crontab
# https://askubuntu.com/questions/58575/add-lines-to-cron-from-script
# To prevent confusion between vagrant deploy and running this as dev, run in current user context
echo -e "${BLU}[+]${WHT} Adding \"vagrant up\" command to crontab for dev. . . ${NC}"
su dev -c '(crontab -u $USER -l; echo -e "@reboot cd /scenario && vagrant up" ) | crontab -u $USER -'

# Get rid of the colord error - This needs to be run on the KALI vagrant box
# sed -i /usr/share/polkit-1/actions/org.freedesktop.color.policy -e 's/<allow_inactive>no<\/allow_inactive>/<allow_inactive>yes<\/allow_inactive>/gm'


