#!/bin/bash

# This scripts start OpenVPN server at
# UDP 443 and creates a clientconfig.ovpn file
# the user can import on his device

which docker || apt install -y docker.io

# https://hub.docker.com/r/kylemanna/openvpn

OVPN_DATA="my-ovpn-data-container"
read -p "Enter hostname for VPN server:" VPNHOST

# creating data volume
docker volume create --name $OVPN_DATA

# generating conf
docker run -v $OVPN_DATA:/etc/openvpn \
  --log-driver=none --rm kylemanna/openvpn \
  ovpn_genconfig -u udp://$VPNHOST

# init PKI
docker run -v $OVPN_DATA:/etc/openvpn \
  --log-driver=none --rm -it kylemanna/openvpn ovpn_initpki

# run server daemon
docker run -v $OVPN_DATA:/etc/openvpn -d -p 443:1194/udp \
  --cap-add=NET_ADMIN kylemanna/openvpn

read -p "Enter client name (without spaces):" CLIENTNAME

# client access
docker run -v $OVPN_DATA:/etc/openvpn --log-driver=none \
  --rm -it kylemanna/openvpn easyrsa build-client-full \
  "$CLIENTNAME" nopass

# get conf. file for client
docker run -v $OVPN_DATA:/etc/openvpn --log-driver=none --rm \
  kylemanna/openvpn ovpn_getclient \
  "$CLIENTNAME" | sed 's/1194\ udp/443\ udp/g' > "/tmp/$CLIENTNAME.ovpn"

echo "The configuration can be found at /tmp/$CLIENTNAME.ovpn"
exit 0
