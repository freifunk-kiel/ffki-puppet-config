per hand
sudo su

## Zeitzone anpassen
dpkg-reconfigure tzdata

## Git und Screen installieren
apt-get update && apt-get -y install git screen

## Puppet cfg clonen
cd /opt && git clone https://github.com/Tarnatos/ffki-puppet-config

## Pre-puppet anpassen:
### Zeile 11: VPN Nr.
### Zeile 101: IPv6 von eth0 
cd /opt/ffki-puppet-config && nano pre-puppet.sh

## In den Screen wechseln
screen

## Pre-puppet ausführen
sh pre-puppet.sh

## adduser puppet ausführen
cd /opt
puppet apply --verbose addusers.pp

## puppet starten
cd /opt/ffki-puppet-config
puppet apply --verbose 5.gw.manifest.pp

## batctl und batman-adv-dkms auf 2013 ändern
### im rm Befehl ggf. Kernel Version ändern 
apt-get -y remove batctl 
apt-get -y remove batman-adv-dkms
rm /lib/modules/3.16.0-4-amd64/kernel/net/batman-adv/batman-adv.ko
apt-get install -y batctl=2013.4.0-1 batman-adv-dkms=2013.4.0-11

### Version anpinnen
cat <<-EOF>> /etc/apt/preferences
Package: batctl
Pin: version 2013.4.0-1
Pin-Priority: 1000

Package: batman-adv-dkms
Pin: version 2013.4.0-11
Pin-Priority: 1000
EOF

## OpenVPN deinstallieren
apt-get remove -y --purge openvpn
rm -Rf /etc/openvpn/

## lokalen Exit aktivieren
cd /opt/ffki-puppet-config
sh localexit.sh

### alle pre-up und down Einträge löschen
nano /etc/network/interfaces.d/ffki-bridge

## Host Datei anpassen:
### manage_etc_hosts: false
nano /etc/cloud/cloud.cfg
### /etc/hosts
### Zeile 17: 127.0.1.1 ffki-5
### vRACK Umleitung ergänzen
nano /etc/cloud/templates/hosts.debian.tmpl

#vRACK
192.168.0.12 vpn0.freifunk.in-kiel.de
192.168.0.11 vpn4.freifunk.in-kiel.de
192.168.0.10 vpn5.freifunk.in-kiel.de
192.168.0.13 vpn6.freifunk.in-kiel.de

## check-services anpassen
### Zeile 77: rpcbind, alfred, openvpn, brid, batadv-vis entfernen respondd ergänzen
nano /usr/local/bin/check-services

## check-gateway anpassen
### tun-anonvon in bat-ffki ändern
nano /usr/local/bin/check-gateway

## fastd cfg anpassen
### peers in peer grp
### null crypto ergänzen
nano /etc/fastd/ffnord-mvpn/fastd.conf

method "null";

peer group "peers" {
        include peers from "peers";
}

## mesh-announce installieren
cd /opt
git clone https://github.com/Tarnatos/kiel-yanic-cfg
cd kiel-yanic-cfg
sh mesh-announce-install.sh

## Server neustarten und online setzen
reboot
online
