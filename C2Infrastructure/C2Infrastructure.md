## C2 Infrastructure

![alt text](https://raw.githubusercontent.com/hassan0x/RedTeam/main/MindMap.png?raw=true)

https://github.com/rsmudge/Malleable-C2-Profiles

# Change default port
sed 's/50050/22666/' teamserver > tmp; mv tmp teamserver

# Generate new self-signed certificate
https-certificate {
        set O  "dmcjna";
        set CN "dmcjna";
        set validity "365";
}

# Test new profile
./c2lint custom.profile

# Run cobalt
./teamserver 8.8.8.8 P@ssw0rd custom.profile &

# Redirector
socat TCP4-LISTEN:80,fork TCP4:192.168.12.100:80

