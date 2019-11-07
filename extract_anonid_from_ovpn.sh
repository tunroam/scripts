#!/bin/sh

if [ -z "$1" ]; then
  echo USAGE: $0 myvpn.ovpn
  exit 1
fi

if [ "`grep "remote\ " "$1"|cut -f2 -d' '|uniq|wc -l`" != "1" ]; then
  echo "ERROR only one domain/IP possible"
  exit 1
fi

REALM=`grep "remote\ " "$1"|head -1|cut -f2 -d' '`

if echo "$REALM"|grep -q '[a-zA-Z]' && ! echo "$REALM"|grep -q "tunroam\."; then
  echo "WARNING if hostname is used, it must contain 'tunroam.'"
  echo "INFO you could use the IP address instead"
  which host >/dev/null && host -t a "$REALM"
fi

for i in `grep "remote\ " "$1" \
  | awk '{print $4 $3}' \
  | sed 's/tcp/06/g' \
  | sed 's/udp/11/g'`; do
  USERPART=$USERPART'_'$i
done

echo $USERPART"a@$REALM" | sed 's/^_//g'
