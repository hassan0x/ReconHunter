# Network

## [1] OSI Model

![](https://raw.githubusercontent.com/hassan0x/RedTeam/main/CheatSheets/Images/Network1.png?raw=true)

## [2] Physical Layer

- Physical layer is how we physically connect devices (Ethernet cables, Wireless).
- Ethernet cards and Wi-Fi and network hubs all operate at the physical layer.
- There are multiple network topologies that we can use to connect devices physically.

### [2.1] Network Topology

- **Star topology (most common):**
  - Each node is connected to central node such as switch.
  - Better performance.
  - Single point of failure.
- **Ring topology:**
  - Each node is connected to two other nodes.
  - Data travels in one direction passing through each node to reach its destination.
  - If one node breaks it can disrupt the entire network.
- **Bus topology:**
  - Each node is connected to a single cable which all nodes share.
  - The signals travels in both directions.
  - Only one node can transmit at one time.
  - More nodes less performance since all nodes share the same cable.
  - If the main cable breaks it can disrupt the entire network.

![](https://raw.githubusercontent.com/hassan0x/RedTeam/main/CheatSheets/Images/Network2.png?raw=true)

## [3] Data Link Layer

- It responsible to make devices communicate with each others through the same network but not outside the network.
- Each device has its own MAC address (00:11:22:33:44:55) and through this MAC the devices can communicate and send messages to each other.
- The first 3 bytes are the manufacturer and the other 3 bytes are the device ID.
- The data in the network layer 2 (Data Link) called Frames.
- Network switches and Access Points operate at layer 2.

### [3.1] Network Switches

![](https://raw.githubusercontent.com/hassan0x/RedTeam/main/CheatSheets/Images/Network3.png?raw=true)

### [3.2] ARP Protocol

- Find MAC address of IP address.
- One system broadcast an ARP request to all the systems in the network asking who has this IP address (192.168.1.1), the system who has this IP respond with its MAC address, then both the systems store each other’s MAC address in their ARP cache so they don’t have to ask again for a while.
- The problem with ARP protocol that it accepts responses without validation.

![](https://raw.githubusercontent.com/hassan0x/RedTeam/main/CheatSheets/Images/Network4.png?raw=true)

## [4] Network Layer

- Connect separate networks together.
- Routers operate at this layer.
- Devices at this layer communicate to each other through the IP addresses.

### [4.1] Routers

![](https://raw.githubusercontent.com/hassan0x/RedTeam/main/CheatSheets/Images/Network5.png?raw=true)

### [4.2] IPv4

```shell
# IPv4 Structure
8bit   .   8bit  .   8bit  .   8bit
0-255  .  0-255  .  0-255  .  0-255
192    .   168   .    1    .    1
```

### [4.3] IP Classes

```shell
# Class A
Range: 0-127
Ex: 0.0.0.0 – 127.0.0.0
First 8bit is the network (N.0.0.0)

# Class B
Range: 128-191
Ex: 128.0.0.0 – 191.255.0.0
First 16bit is the network (N.N.0.0)

# Class C
Range: 192-223
Ex: 192.0.0.0 – 223.255.255.0
First 24bit is the network (N.N.N.0)

# Class D
Range: 224-239
Ex: 224.0.0.0 – 239.255.255.255
Used for multicast.

# Class E
Range: 240-255
Ex: 240.0.0.0 – 255.255.255.255
Reserved for experimental.
```

### [4.4] Reserved IP Addresses

```shell
# Reserved for localhost
127.0.0.0 - 127.255.255.255

# Reserved for local area network (LAN)
10.0.0.0 - 10.255.255.255
172.16.0.0 - 172.31.255.255
192.168.0.0 - 192.168.255.255

# First IP of any network is reserved for the network itself (Network Identifier)
# Last IP of any network is reserved for the broadcast (Broadcast Address)
```

### [4.5] Subnet Mask

It identifies which part of the IP address is the network identifier and which part is the host identifier.

```shell
# Subnet mask
Class A == 255.0.0.0
Class B == 255.255.0.0
Class C == 255.255.255.0
```

### [4.6] CIDR

Classless Inter-Domain Routing (CIDR) is another and simple way to represent the subnet mask.

```shell
# Class A
10.0.0.0/8 
"/8" is the number of bits reserved for the network == 255.0.0.0

# Class B
172.16.0.0/16
"/16" is the number of bits reserved for the network == 255.255.0.0

# Class C
192.168.1.0/24
"/24" is the number of bits reserved for the network == 255.255.255.0
```

### [4.7] Gateway

It’s responsible for routing you from one network to another network and in most cases it will be the first IP in the network.

```shell
Class A: 10.0.0.1
Class B: 172.16.0.1
Class C: 192.168.1.1
```

### [4.8] DHCP

Automatically assign IP addresses for you, Example:

- **IP address**: 192.168.1.10
- **Subnet mask**: 255.255.255.0
- **Default gateway**: 192.168.1.1
- **DNS server**: 8.8.8.8, 8.8.4.4

In your local network the DHCP server will be the router itself, but in other enterprise networks it will be a separate server.

**How DHCP Works:**

- Client send DHCP Discover packet to all the network.
- DHCP Server (Router) replay with DHCP Offer packet (how about 192.168.1.16).
- Client accept the IP and send DHCP Request packet with the IP.
- DHCP replay with DHCP ACK packet.

![](https://raw.githubusercontent.com/hassan0x/RedTeam/main/CheatSheets/Images/Network6.png?raw=true)

### [4.9] Routing

- Routing is the process of moving packets between networks.
- Router is the device that routes the packets between networks.
- Router have multiple interfaces and can connect multiple networks at the same time.

**Routing Table:**

It’s a table in the router device like the CAM table in the switch device, which is responsible for determining the next hop (Router) that it should send the packet to it, to reach the final destination. If no route to the destination network is exist, the router will send the packet to its default gateway.

```shell
# Routing Table Example
192.168.2.0/24     192.168.2.1
192.168.45.0/24    192.168.45.1
172.16.2.0/16      172.16.2.1
default gateway    192.168.1.1
```

**Routing Protocols:**

Routing protocols are responsible for determining next hop, shortest path, network changes and link failures.

- **RIP**: determine the shortest path and broadcast the routing table every 30 seconds.
- **OSPF**: detect changes in the network topology and link failures.
- **BGP**: most widely used protocol, can determine the shortest path and if one route fail, it changes to another route.

![](https://raw.githubusercontent.com/hassan0x/RedTeam/main/CheatSheets/Images/Network7.png?raw=true)

### [4.10] NAT

Network Address Translation (NAT) it’s a technique to translating one IP address to one or more IP addresses. All the home networks (LAN) is using the NAT protocol.

![](https://raw.githubusercontent.com/hassan0x/RedTeam/main/CheatSheets/Images/Network8.png?raw=true)

### [4.11] ICMP Protocol

```shell
# Test connectivity between two hosts. 
Ping google.com

# How it works
1- Client send ICMP Echo Request packet to the destination.
2- Destination send ICMP Echo Reply packet to the client.
```

**TTL (Time to Live):**

- TTL has fixed number almost 64.
- It started at 64 then decrement by 1 at every router (hop or node) until it reachs its destination.
- This number exist to prevent the infinite loops.

### [4.12] Traceroute

![](https://raw.githubusercontent.com/hassan0x/RedTeam/main/CheatSheets/Images/Network9.png?raw=true)

## [5] Real Life Scenario (Lab)

![](https://raw.githubusercontent.com/hassan0x/RedTeam/main/CheatSheets/Images/Network10.png?raw=true)

## [6] Transport Layer

- Ensure reliable data transfer between hosts.
- Determine the success transfers and the failed transfers, retransmit the failed ones and reorder the packets to form the original message.
- It also provide multiple ports on the same IP address, and it consists of mainly two protocols TCP, UDP. 
- Ports are used to identify unique services on the same host.

There are 65,536 ports on the TCP protocol and 65,536 ports on the UDP protocol.

- **Ports(1–1023):** Well known and the most used ports (HTTP, HTTPS, DNS, SMTP, SSH, FTP, TELNET). 
- **Ports(1024–49151):** Available ports that can be used.
- **Ports(49152–65535):** Can’t be used because the operating system use this ports in the outgoing connections.

```shell
# Well Known Ports
21 == FTP
22 == SSH
23 == Telnet
25 == SMTP
53 == DNS
80 == HTTP
110 == POP3
139 == NETBIOS
443 == HTTPS
445 == SMB
3389 == RDP
```

### [6.1] TCP Protocol

TCP is the most used protocol. It performing a lot of functions to ensure the validation of data and a reliable connection.

- Detect lost or failed data and retransmit it.
- Filter if there is duplicate data found.
- Reorder the packets if they unordered.

TCP is design to ensure the accurate delivery not speed.

**TCP Flags:**

It’s a piece of information in the TCP header, added to every packet to help TCP protocol to ensure the accurate delivery \(Syn, Ack, Fin, Push, Reset\).

**TCP 3-Way Handshake:**

```shell
# TCP 3-Way Handshake
1- SYN(seq=100) packet sent.
2- SYN-ACK(seq=200,ack=101) packet received.
3- ACK(seq=101,ack=201) packet sent.
4- Connection established.
```
![](https://raw.githubusercontent.com/hassan0x/RedTeam/main/CheatSheets/Images/Network11.png?raw=true)

### [6.2] UDP Protocol

UDP operate at the same level as TCP, and is connectionless and stateless which means:

- No handshake.
- No failure packet detection.
- No retransmission.

And because of this UDP is faster than TCP, and it used in cases where the accuracy not important like audio/video streaming where one packet lost don’t effect the transmission.

## [7] Session layer

Creates and terminates the unique connections between hosts.

## [8] Presentation layer

It's responsible for encoding and decoding the message and show the message in the right format (Text, Photo, Video).

## [9] Application Layer

Application layer is the end user interface like web browser, mail client and so on. We will talk about two major application protocols like DNS, HTTP.

### [9.1] DNS Protocol

It’s used to convert Hostname to IP address like google.com to 172.217.21.78, it operates at UDP port 53.

```shell
# DNS Structure
Domain: (mail.google.com, login.yahoo.com)
Top level domain: .com, .net, .org, .edu, .gov
Second level domain: google, yahoo, facebook.
Sub-domains: mail, login.

# DNS record types
A:      Show IP address of the domain 192.168.1.145
AAAA:   Show IP address (V6) of the domain fd84:4765:de78:2600::28ff
NS:     Show DNS Servers of the domain ns1.sans.org
MX:     Show Mail Servers of the domain mx1.sans.org
```
![](https://raw.githubusercontent.com/hassan0x/RedTeam/main/CheatSheets/Images/Network12.png?raw=true)

### [9.2] HTTP Protocol

- It’s responsible for transferring the web pages and other files on the World Wide Web Operate on TCP port 80.
- HTTP is stateless so if you visit a login page and insert your username and password and now you have access on your account but you closed the page and revisiting it, then you will required to insert your username and password again, it doesn’t remember you, it's stateless.
- So now websites use cookies, it’s piece of information sent in the HTTP header to make the website remember you and don’t ask your password every time you visit it.

**HTTP methods (GET, POST):**

Both used to retrieve data from website, but GET pass the variables in the URL and POST pass the variables in the HTTP header.

**HTTP status codes:**

- 200: Success
- 300: Redirect
- 400: Not Found

![](https://raw.githubusercontent.com/hassan0x/RedTeam/main/CheatSheets/Images/Network13.png?raw=true)
