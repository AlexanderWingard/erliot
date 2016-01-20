#!/bin/sh
socat TCP-LISTEN:8888,reuseaddr,fork TCP:127.0.0.1:6571 &
while true
do
	echo "g2gDZAAPZXJsaW90X2Fubm91bmNlZAAKdGNwX3NlcmlhbGIAACK4" | base64 -d | socat - UDP-DATAGRAM:255.255.255.255:6000,broadcast
	sleep 60
done
