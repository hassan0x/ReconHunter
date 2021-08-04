# Linux

## [1] Core Commands

```shell
# List files and directories
ls
ls /home
ls –al
ls –al /home/student

# Change current directory
cd /home

# Print current directory
pwd

# Copy files
cp a.txt /home
cp a.txt b.txt

# Move or rename file
mv a.txt /home
mv a.txt b.txt

# Remove empty directory
rmdir test

# Remove file or Non empty directory
rm a.txt
rm –r test

# Create directory
mkdir test

# Print file content
cat a.txt

# Search for text in file
grep "word" a.txt

# Display the first 10 lines of a file
head a.txt
head –n 5 a.txt

# Display the last 10 lines of a file
tail a.txt
tail –n 5 a.txt
tail –f a.txt

# Display text from file in one screen
less a.txt

# Display list of running processes
ps aux

# Display list of open files
lsof –i

# Display network connections
netstat –antp

# Display network information
ifconfig

# Sort content of a file
sort a.txt

# Remove duplicate lines (sort first)
uniq a.txt

# Display information about a file
stat a.txt

# Test network connectivity
ping google.com

# Display current user
whoami

# Change user passwd
passwd student

# Terminate process
kill 1845

# Search on files
find / -name a.txt
find / -name "*.txt"

# Text editor (Save: Ctrl+X)
nano filename

# Create link file
# Soft link
ln –s file soft-link

# Hard link
ln file hard-link
```
![](https://raw.githubusercontent.com/hassan0x/RedTeam/main/CheatSheets/Images/Linux1.png?raw=true)

## [2] Special Characters

```shell
# Directory separator ( / )
cd /home/student

# Escape character ( \ )
mkdir test\ dir

# Current directory ( . )
ls .
cat ./a.txt

# Parent directory ( .. )
ls ..
cat ../a.txt

# User home directory ( ~ )
cd ~

# Run in background ( & )
gedit &

# Represent one or more characters ( * )
ls *.txt

# Represent single character ( ? )
ls a?.txt

# Represent range of values ( [ ] )
ls a[0-9].txt

# Command separator run both commands anyway ( ; )
pwd ; whoami
ay7aga ; whoami

# Command separator run second command if the first succeed ( && )
pwd && whoami
ay7aga && whoami

# Command separator run second command if the first failed ( || )
pwd || whoami
ay7aga || whoami
```

## [3] Redirection

```shell
# stdout (1)
whoami > a.txt
whoami 1> a.txt

# stderr (2)
ay7aga 2> err.txt

# stdin (0)
wc < a.txt
wc 0< a.txt

# append value to the end of file
pwd >> a.txt

# print the output to out.txt, and print the error to err.txt 
ls > out.txt 2> err.txt

# print the output and error to all.txt
ls > all.txt 2>&1
```
![](https://raw.githubusercontent.com/hassan0x/RedTeam/main/CheatSheets/Images/Linux2.png?raw=true)

## [4] Piping

```shell
# Pass the output of the first command to the input of the second command.
ls –l | grep "Desktop"
cat /etc/passwd | grep ":0:"
ping google.com | grep "64 bytes"
cat a.txt | sort | uniq
```

## [5] Environment Variables

```shell
# Run "env" command
HOSTNAME=Debian
USER=student
PWD=/home/student
PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games
SHELL=/bin/bash

# Print environment variables
echo $HOSTNAME
echo $PATH
echo $SHELL

# Set variables
PATH=$PATH:/home/user
SHELL=/bin/sh
```

## [6] User Management

```shell
# Create user
useradd testuser

# Set or change user password
passwd testuser

# Create  group
groupadd testgroup

# Add user to group
gpasswd –a testuser testgroup

# Delete user
userdel testuser

# Delete group
groupdel testgroup
```

## [7] Important Files

**[7.1] /etc/passwd**

```shell
# Example
# root:x:0:0:root:/root:/bin/bash

1- Username
2- Encrypted password
3- User ID
4- Group ID
5- Comment (Full username)
6- Home directory
7- Shell type
```

**[7.2] /etc/shadow**

```shell
# Example
# root:$6$KILMHVxNbzVXTmbwlh6GiH6k3u4zrMsvlmTgWRF9m7SW:18184:0:99999:7:::

1- Username
2- Encrypted password (Look at the first 3 characters)
   $1$ = MD5 encryption
   $5$ = SHA-256 encryption
   $6$ = SHA-512 encryption
3- Last password change date
4- Minimum date
5- Maximum date
6- Warn date
7- Inactive date
8- Expire date
```

**[7.3] /etc/group**

```shell
# Example
# root:x:0:hassan,ahmed

1- Group name
2- Group password if exist
3- Group ID
4- Members of this group
```

## [8] SU

```shell
# SU switch to another user
su
su testuser

# SU also can switch to another user with similar environment as the user loggedin
su -
su - testuser

# SU can also run command directly without full shell
su username -c command
```

## [9] Sudo

```shell
# Sudo can run single command as root
sudo cat /etc/shadow

# And you can also have full root shell
sudo -i
```

## [10] Linux Boot Process

- **BIOS**: Performs some system integrity checks then executes MBR.
- **MBR**: It contains information about boot loader then loads and executes the boot loader \(GRUB\).
- **GRUB**: displays a splash screen then executes kernel.
- **Kernel**: mount partitions then executes init script.
- **Init**: determine the Linux run level then executes runlevel programs.
- **Runlevel**: responsible for which services started at which runlevel.

![](https://raw.githubusercontent.com/hassan0x/RedTeam/main/CheatSheets/Images/Linux3.png?raw=true)

## [11] Linux Run Levels

```shell
# Get current runlevel
runlevel

# Get default runlevel
systemctl get-default

# Set default runlevel
systemctl set-default runlevelX.target

# List services at specific runlevel (S means start, K means kill/stop)
ls /etc/rcX.d
```
![](https://raw.githubusercontent.com/hassan0x/RedTeam/main/CheatSheets/Images/Linux4.png?raw=true)

## [12] Services

```shell
# Start service
systemctl start apache2

# Stop service
systemctl stop apache2

# Restart service
systemctl restart apache2

# Print status of service
systemctl status apache2

# Enable or disable service at boot time
systemctl enable/disable apache2
```

## [13] File System

- **/**: Root directory, every thing starts from there.
- **/root**: Root home directory, contains Desktop, Downloads, Documents and so on.
- **/bin**: Contains users binaries (ls, cp, cat).
- **/sbin**: Contains system binaries (reboot, ifconfig, fdisk).
- **/etc**: Contains system configuration files.
- **/home**: Home directory for all users (/home/student, /home/testuser).
- **/boot**: Contains boot load files and kernel files.
- **/lib**: Contains system libraries.
- **/var**: Contains variable data which is continuously change in size (/var/log).
- **/usr**: Contains user programs and it contains another bin (/usr/bin) & sbin (/usr/sbin) which contains second level user and system binaries.
- **/mnt**: Mount directory where system admin can mount any partitions here.
- **/tmp**: Temporary files (delete at reboot).

![](https://raw.githubusercontent.com/hassan0x/RedTeam/main/CheatSheets/Images/Linux5.png?raw=true)

## [14] File Permissions

```shell
# Permission groups
1- owner (u)
2- group (g)
3- others (o)

# Permission types
1- read (r=4)
2- write (w=2)
3- execute (x=1)

# Example 1 
chmod u+rwx filename 
chmod g+rw filename 
chmod o+r filename 
chmod go+rw filename
chmod a-x filename

# Example 2
chmod 777 filename 
chmod 700 filename 
chmod 764 filename 
chmod 755 filename 
chmod 644 filename
```
![](https://raw.githubusercontent.com/hassan0x/RedTeam/main/CheatSheets/Images/Linux6.png?raw=true)

## [15] Installing Software

```shell
# Update repository (always must run first)
apt-get update

# Upgrade all softwares
apt-get upgrade

# Upgrade all the system include kernel
apt-get dist-upgrade

# In most cases you will need to run this
apt-get update && apt-get dist-upgrade

# Install software
apt-get install software-name

# Remove software
apt-get remove software-name

# Remove software with its configuration files
apt-get purge software-name

# Search on software
apt-cache search software-name
```

**If the software don’t exist in the repository then you can go to the main website of the software and download the deb package.**
```shell
# Install .deb package
dpkg –i nmap.deb

# List all packages
dpkg –l
dpkg –l | grep nmap

# Remove package
dpkg –r nmap
```
