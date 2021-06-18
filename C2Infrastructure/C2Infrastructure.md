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

1- Generate new self-signed certificate
```
https-certificate {
        set O  "dmcjna";
        set CN "dmcjna";
        set validity "365";
}
```

### Test New Profile
```
./c2lint custom.profile
```

### Run Cobalt
```
./teamserver 8.8.8.8 P@ssw0rd custom.profile &
```
