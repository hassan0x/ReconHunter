## Nmap

### Nmap default behavior

- Host Discovery
- Port Scanning using SYN scan on top 1000 ports
```
nmap 192.168.1.4
```

### Host Discovery

- ARP protocol if (local network).
- ICMP protocol if (run as root).
- TCP protocol on port 443 through SYN packet.
- TCP protocol on port 80 through ACK packet.
```
nmap -sn 192.168.1.0/24
```

### Port Scanning

- Perform the 3-way handshake (SYN, SYN-ACK, ACK) (Connect scan)
- Perform 2-way handshake (SYN, SYN-ACK) (SYN scan)
- Perform UDP packet scanning (UDP scan)

### Common Scanning Commands
```
nmap -sn 192.168.1.0/24
nmap -sn --traceroute 8.8.8.8 
nmap -sT -p 21,22,23,25,80 --reason -sV 192.168.1.4 -oA result
nmap -sU --top-ports 10 --reason -O --open 192.168.1.4
nmap -Pn -T2 -sS -p- -vv --reason --badsum 192.168.1.4 -oG result.gnmap
nmap -sS -sU -p U:53,111,161,T:21-25,80,445 --reason -sV 192.168.1.4 -oA result
```

### Nmap help
```
nmap --help
man nmap
```

### Scripts Location
```
cd /usr/share/nmap/scripts/
nmap --script-help dns-zone-transfer
head -n 10 script.db
cat script.db | grep 'vuln\|exploit'
```

### Script Engine Commands
```
nmap --script vuln -p80 -vv 192.168.1.4
nmap --script vuln,exploit -vv 192.168.1.4
nmap --script=all -vv 192.168.1.4

nmap -sV -sC 8.8.8.8 // -sC equivalent to --script=default
nmap -p53 -sV --script dns-zone-transfer zonetransfer.me

nmap -p80 -sV --script http-robots.txt 8.8.8.8
nmap -p80 -sV --script http-vuln-* 192.168.1.1

nmap -p21 -sV --script ftp-anon 192.168.1.1
nmap -p21 -sV --script ftp-vsftpd-backdoor 192.168.100.6

nmap -p 139,445 -sV --script smb-os-discovery 192.168.1.1
nmap -p 139,445 -sV --script smb-vuln* 192.168.100.18
nmap -p 139,445 -sV --script smb-check-vulns --script-args=unsafe=1 192.168.1.243

nmap -A 192.168.1.4 // -A equivalent to -sV -sC -O --traceroute
```
