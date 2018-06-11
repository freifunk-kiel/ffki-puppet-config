echo Dieses script nur von hand copy paste ausführen!
exit

sudo su

## Zeitzone anpassen
dpkg-reconfigure tzdata

## CDROM installer aus sources.list entfernen
sed -e '/deb cdrom/ s/^#*/#/' /etc/apt/sources.list

# DNS Problem on OVH:
# echo "217.196.149.233 security.debian.org">>/etc/hosts
# echo "151.101.12.204 security-cdn.debian.org">>/etc/hosts
# echo "192.30.253.113 github.com">>/etc/hosts
# echo "213.32.5.7 debian.mirrors.ovh.net">>/etc/hosts
# echo "52.10.130.237 forgeapi.puppetlabs.com">>/etc/hosts

## Pakete vorinstallieren
apt update && apt -y install apt-transport-https git nload screen tmux etckeeper sshguard tcpdump dnsutils realpath htop tig bash-completion haveged mtr-tiny vim nano unp mlocate cmake build-essential libcap-dev pkg-config libgps-dev python3 ethtool lsb-release zip locales-all ccze ncdu

## Puppet cfg clonen
cd /opt && git clone https://github.com/Tarnatos/ffki-puppet-config

## Pre-puppet anpassen:
### Zeile 11: VPN Nr.
### bei OVH:
##### OVH Block entkommentieren
##### Zeile 101: IPv6 von eth0 
cd /opt/ffki-puppet-config && nano pre-puppet.sh

## In den Screen wechseln
screen

## key hinterlegen
nano /opt/ffki-vpn0-fastd-secret.key


## Pre-puppet ausführen
sh pre-puppet.sh

## adduser puppet ausführen
cd /opt
puppet apply --verbose addusers.pp

## puppet starten
cd /opt/ffki-puppet-config
puppet apply --verbose 0.gw.manifest.pp

## batctl und batman-adv-dkms auf 2013 ändern
### im rm Befehl ggf. Kernel Version ändern 
apt -y remove batctl 
apt -y remove batman-adv-dkms
rm /lib/modules/3.16.0-4-amd64/kernel/net/batman-adv/batman-adv.ko
apt install -y batctl=2013.4.0-1 batman-adv-dkms=2013.4.0-11
dkms uninstall batman-adv/2013.4.0
dkms install batman-adv/2013.4.0
rmmod batman-adv
modprobe batman-adv
batctl -v

### Version anpinnen
cat <<-EOF >> /etc/apt/preferences
	Package: batctl
	Pin: version 2013.4.0-1
	Pin-Priority: 1000

	Package: batman-adv-dkms
	Pin: version 2013.4.0-11
	Pin-Priority: 1000
EOF



## mesh-announce installieren
cd /opt
git clone https://github.com/Tarnatos/kiel-yanic-cfg
cd kiel-yanic-cfg
sh mesh-announce-install.sh

## Install prometheus-node-exporter

## Install nullmailer

## Created blacklist.db file for sshguard

## Adding more stations to ping to in /etc/ffnord




#### optional ######

## OpenVPN deinstallieren
apt remove -y --purge openvpn
rm -Rf /etc/openvpn/

## lokalen Exit aktivieren
cd /opt/ffki-puppet-config
sh localexit.sh

### alle pre-up und down Einträge löschen
nano /etc/network/interfaces.d/ffki-bridge

## Host Datei anpassen:
### manage_etc_hosts: false
nano /etc/cloud/cloud.cfg
nano /etc/hosts
### Zeile 17: 127.0.1.1 vpn5
### vRACK Umleitung ergänzen

#vRACK
192.168.0.12 vpn0.freifunk.in-kiel.de
192.168.0.11 vpn4.freifunk.in-kiel.de
192.168.0.10 vpn5.freifunk.in-kiel.de
192.168.0.13 vpn6.freifunk.in-kiel.de

## resolv.conf rebootfest machen
### prepend domain-name-servers 213.186.33.99; setzen
nano /etc/dhcp/dhclient.conf

## check-services anpassen
### Zeile 77: rpcbind, alfred, openvpn, brid, batadv-vis entfernen respondd ergänzen
nano /usr/local/bin/check-services

## check-gateway anpassen
### tun-anonvon in bat-ffki ändern
nano /usr/local/bin/check-gateway

## fastd cfg anpassen
### peers in peer grp
### null crypto ergänzen
### service alfred start am Ende löschen
nano /etc/fastd/ffki-mvpn/fastd.conf

method "null";

peer group "peers" {
        include peers from "peers";
        peer limit 75;
}

# ICVPN abschalten
systemctl disable tinc
systemctl stop tinc
systemctl daemon-reload

## Server neustarten und online setzen
reboot
online
