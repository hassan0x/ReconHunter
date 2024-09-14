#!/bin/bash

Setup () {

    echo "Setup....."
    date

    # Install required packages
    sudo apt-get install -y aha curl git subfinder nmap massdns masscan httprobe dirsearch awscli trufflehog golang chromium php python3-pip unzip pipx jq

    # Set up pipx environment variables and installing censys and s3scanner
    export PIPX_HOME=/opt/pipx
    export PIPX_BIN_DIR=/usr/local/bin
    sudo pipx install censys
    sudo pipx install s3scanner
    sudo pip install truffleHog

    # Create and set up Tools directory
    sudo rm -rf Tools
    mkdir Tools && cd Tools
    export GOPATH=$PWD

    # Install Go-based tools
    echo "Installing Go-based tools..."
    go install github.com/Ice3man543/SubOver@latest
    go install github.com/tomnomnom/unfurl@latest
    go install github.com/tomnomnom/waybackurls@latest
    go install github.com/jaeles-project/gospider@latest

    echo "Installing Aquatone & Amass..."
    # Download and set up Aquatone
    wget -q https://github.com/michenriksen/aquatone/releases/download/v1.7.0/aquatone_linux_amd64_1.7.0.zip
    unzip -q aquatone_linux_amd64_1.7.0.zip -d tmp
    cp tmp/aquatone . && rm -rf aquatone_linux_amd64_1.7.0.zip tmp

    # Download and set up Amass
    wget -q https://github.com/owasp-amass/amass/releases/download/v3.23.3/amass_Linux_amd64.zip
    unzip -q amass_Linux_amd64.zip -d tmp
    cp tmp/amass_Linux_amd64/amass . && rm -rf amass_Linux_amd64.zip tmp

    cd ..
    date
}

Passive_Scraping () {
    echo "#################################################"
    echo "#       PASSIVE SCRAPING AND RESOLVING          #"
    echo "#################################################"

    echo "Date and Time: $(date '+%Y-%m-%d %H:%M:%S')"

    echo "#################################################"

    if [[ -z $2 ]]; then echo "Usage: $0 $1 example.com"; exit 1; fi

    Domain=$2 && echo "Domain: $Domain"
    mkdir -p "$Domain" && cd "$Domain"

    echo "Running Amass..."
    ../Tools/amass enum -passive -d "$Domain" 2>/dev/null | sort -u > 1.Amass.txt

    echo "Running SubFinder..."
    subfinder -silent -all -d "$Domain" | sort -u > 2.SubFinder.txt

    echo "Combining Results..."
    cat 1.Amass.txt 2.SubFinder.txt | tr 'A-Z' 'a-z' | sort -u > 3.Passive.SubDomains.txt

    echo "Running Resolving..."
    massdns -q -r ../Resources/resolvers.txt 3.Passive.SubDomains.txt | grep -E "IN A [0-9]|CNAME" > 4.massDNS.Resolving.txt

    grep "$Domain" 4.massDNS.Resolving.txt | cut -d " " -f1 | sed 's/.$//' | sort -u > 5.Live.SubDomains.txt
    cat 3.Passive.SubDomains.txt 5.Live.SubDomains.txt | sort | uniq -u > 6.Died.SubDomains.txt
    
    grep "IN A" 4.massDNS.Resolving.txt | grep "$Domain" | cut -d " " -f5 | sort -u > 7.IP.Addresses.txt

    cd ..
    echo "Date and Time: $(date '+%Y-%m-%d %H:%M:%S')"
}

Brute_Force () {
    echo "#################################################"
    echo "#              BRUTE FORCING                    #"
    echo "#################################################"

    echo "Date and Time: $(date '+%Y-%m-%d %H:%M:%S')"

    echo "#################################################"

    if [[ -z $2 ]]; then echo "Usage: $0 $1 example.com"; exit 1; fi

    Domain=$2 && echo "Domain: $Domain"
    mkdir -p "$Domain" && cd "$Domain"

    echo "Combining Wordlists..."
    cat ../Resources/all.txt ../Resources/commonspeak.txt | tr 'A-Z' 'a-z' | sort -u | sed "s/$/.$Domain/g" > Total.Wordlist.txt

    echo "Running BruteForce..."
    massdns -q -r ../Resources/resolvers.txt Total.Wordlist.txt | grep -E "IN A [0-9]|CNAME" > 8.massDNS.BruteForce.txt

    grep "$Domain" 8.massDNS.BruteForce.txt | cut -d " " -f1 | sed 's/.$//' | sort -u > 9.Live.SubDomains.txt

    grep "IN A" 8.massDNS.BruteForce.txt | grep "$Domain" | cut -d " " -f5 | sort -u > 10.IP.Addresses.txt

    rm Total.Wordlist.txt && cd ..
    echo "Date and Time: $(date '+%Y-%m-%d %H:%M:%S')"
}

WildCard_Removal () {
    echo "#################################################"
    echo "#             WILDCARD REMOVAL                  #"
    echo "#################################################"

    echo "Date and Time: $(date '+%Y-%m-%d %H:%M:%S')"

    echo "#################################################"

    if [[ -z $2 ]]; then echo "Usage: $0 $1 example.com"; exit 1; fi

    Domain=$2 && echo "Domain: $Domain"
    mkdir -p "$Domain" && cd "$Domain"

    echo "Running Wildcard Removal..."
    cat 5.Live.SubDomains.txt 9.Live.SubDomains.txt | tr 'A-Z' 'a-z' | sort -u | sed 's/^[*.]*//g' > 11.Total.SubDomains.txt

    echo "Checking for Wildcards..."
    > 12.Having.Wildcard.txt
    cat 11.Total.SubDomains.txt | while read -r line; do
        host -t A "*.$line" | cut -d " " -f1 | sed 's/^*.//g' >> 12.Having.Wildcard.txt
    done

    cat 11.Total.SubDomains.txt 12.Having.Wildcard.txt | sort | uniq -u > 12.1.NotHaving.Wildcard.txt

    echo "Finding Root Wildcard Subdomains..."
    > 12.2.Root.Wildcard.txt
    cat 12.Having.Wildcard.txt | while read -r line; do
        tmp=""
        while true; do
            if host -t A "*.$line" | grep -q NXDOMAIN; then
                echo "$tmp" >> 12.2.Root.Wildcard.txt
                break
            fi
            tmp="$line"
            line=$(echo "$line" | cut -d "." -f2-)
        done
    done

    cat 12.2.Root.Wildcard.txt 12.1.NotHaving.Wildcard.txt | sort -u > 13.Clean.SubDomains.txt

    cd ..
    echo "Date and Time: $(date '+%Y-%m-%d %H:%M:%S')"
}

Spidering () {
    echo "#################################################"
    echo "#             DOMAINS SPIDERING                 #"
    echo "#################################################"

    echo "Date and Time: $(date '+%Y-%m-%d %H:%M:%S')"

    echo "#################################################"

    if [[ -z $2 ]]; then echo "Usage: $0 $1 example.com"; exit 1; fi

    Domain=$2 && echo "Domain: $Domain"
    mkdir -p "$Domain" && cd "$Domain"

    echo "Running HTTProbe..."
    cat 13.Clean.SubDomains.txt | httprobe -p https:8443 http:8080,8000 > 14.HTTProbe.txt

    echo "Running GoSpider..."
    ../Tools/bin/gospider -S 14.HTTProbe.txt -o 14.1.Spidering -t 50 -c 10 -d 3 --subs --js --sitemap --robots 1>/dev/null

    cd 14.1.Spidering
    for file in *; do
        if [[ -f $file ]]; then mv "$file" "${file}.txt"; fi
    done
    cd ..

    cat 14.1.Spidering/* | grep -Eo '[a-z0-9_-]*\.[a-z0-9_-]*\.*[a-z0-9_-]*\.*[a-z0-9_-]*\.*[a-z0-9_-]*' | grep "$Domain" | sort -u > 15.Passive.SubDomains.txt

    echo "Running Resolving..."
    massdns -q -r ../Resources/resolvers.txt 15.Passive.SubDomains.txt | grep -E "IN A [0-9]|CNAME" > 16.massDNS.Resolving.txt
    
    cat 16.massDNS.Resolving.txt | grep "$Domain" | cut -d " " -f1 | sort -u | sed 's/.$//' > 17.Live.SubDomains.txt
    cat 15.Passive.SubDomains.txt 17.Live.SubDomains.txt | sort | uniq -u > 18.Died.SubDomains.txt
    
    cat 16.massDNS.Resolving.txt | grep "IN A" | grep "$Domain" | cut -d " " -f5 | sort -u > 19.IP.Addresses.txt

    echo "Combining Final SubDomains..."
    cat 6.Died.SubDomains.txt 18.Died.SubDomains.txt | sort -u > 20.Died.SubDomains.txt
    cat 13.Clean.SubDomains.txt 17.Live.SubDomains.txt | sort -u > 21.Final.SubDomains.txt
    cat 20.Died.SubDomains.txt 21.Final.SubDomains.txt | sort -u > 22.All.SubDomains.txt

    cd ..
    echo "Date and Time: $(date '+%Y-%m-%d %H:%M:%S')"
}

TakeOver () {
    echo "#################################################"
    echo "#             SUBDOMAINS TAKEOVER               #"
    echo "#################################################"

    echo "Date and Time: $(date '+%Y-%m-%d %H:%M:%S')"

    echo "#################################################"

    if [[ -z $2 ]]; then echo "Usage: $0 $1 example.com"; exit 1; fi

    Domain=$2 && echo "Domain: $Domain"
    mkdir -p "$Domain" && cd "$Domain"

    echo "Running Subdomains Takeover..."
    cp ../Resources/providers.json providers.json
    ../Tools/bin/SubOver -l 22.All.SubDomains.txt -v > 23.Takeover.txt

    echo "Running The Second Check..."
    cat 22.All.SubDomains.txt | while read sub; do
        host "$sub" | grep alias | cut -d " " -f1,6 | tee -a 23.1.Takeover2.txt > tmp
        cat tmp | sed 's/ /\n/' | tail -n +2 | while read line; do
            host "$line" | grep NXDOMAIN 
        done
    done
    
    rm providers.json tmp && cd ..
    echo "Date and Time: $(date '+%Y-%m-%d %H:%M:%S')"
}


Censys () {
    echo "#################################################"
    echo "#          CENSYS SEARCH ENGINE                 #"
    echo "#################################################"

    echo "Date and Time: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "Insert your Censys API keys using 'censys config'"
    echo "#################################################"

    if [[ -z $2 ]]; then echo "Usage: $0 $1 example.com"; exit 1; fi

    Domain=$2 && echo "Domain: $Domain"
    mkdir -p "$Domain" && cd "$Domain"

    echo "Running Censys Search..."
    censys search --pages 1000 "$Domain" > 27.Censys.txt

    cat 27.Censys.txt | grep '"ip":' | cut -d'"' -f4 | sort -n | uniq > 28.IP.Addresses.txt
    cat 27.Censys.txt | grep '"port"' | cut -d":" -f2 | cut -d"," -f1 | cut -d" " -f2 | sort -n | uniq > 28.1.Censys.Ports.txt
    cat 27.Censys.txt | jq '.[] | .ip as $ip | .services[] | [$ip, .port, .transport_protocol, .service_name] | join(" ")' | cut -d'"' -f2 > 28.2.Censys.IP.Ports.txt
    
    cd ..
    echo "Date and Time: $(date '+%Y-%m-%d %H:%M:%S')"
}

Port_Scanning () {

    echo "#################################################"
    echo "#                IP & PORT SCANNING             #"
    echo "#################################################"
    
    echo "Date and Time: $(date '+%Y-%m-%d %H:%M:%S')"
    
    echo "#################################################"
    
    if [[ -z $2 ]]; then echo "Usage: $0 $1 example.com"; exit 1; fi

    Domain=$2 && echo "Domain: $Domain"
    mkdir -p "$Domain" && cd "$Domain"

    cat 7.IP.Addresses.txt 10.IP.Addresses.txt 19.IP.Addresses.txt 28.IP.Addresses.txt | sort -n | uniq > 29.Final.IPs.txt

    echo "Running Masscan..."
    sudo masscan -iL 29.Final.IPs.txt --max-rate 10000 --wait 5 -oL 30.masscan.Scanning.txt -p 1,3-4,6-7,9,13,17,19-26,30,32-33,37,42-43,49,53,70,79-85,88-90,99-100,106,109-111,113,119,125,135,139,143-144,146,161,163,179,199,211-212,222,254-256,259,264,280,301,306,311,340,366,389,406-407,416-417,425,427,443-445,458,464-465,481,497,500,512-515,524,541,543-545,548,554-555,563,587,593,616-617,625,631,636,646,648,666-668,683,687,691,700,705,711,714,720,722,726,749,765,777,783,787,800-801,808,843,873,880,888,898,900-903,911-912,981,987,990,992-993,995,999-1002,1007,1009-1011,1021-1100,1102,1104-1108,1110-1114,1117,1119,1121-1124,1126,1130-1132,1137-1138,1141,1145,1147-1149,1151-1152,1154,1163-1166,1169,1174-1175,1183,1185-1187,1192,1198-1199,1201,1213,1216-1218,1233-1234,1236,1244,1247-1248,1259,1271-1272,1277,1287,1296,1300-1301,1309-1311,1322,1328,1334,1352,1417,1433-1434,1443,1455,1461,1494,1500-1501,1503,1521,1524,1533,1556,1580,1583,1594,1600,1641,1658,1666,1687-1688,1700,1717-1721,1723,1755,1761,1782-1783,1801,1805,1812,1839-1840,1862-1864,1875,1900,1914,1935,1947,1971-1972,1974,1984,1998-2010,2013,2020-2022,2030,2033-2035,2038,2040-2043,2045-2049,2065,2068,2099-2100,2103,2105-2107,2111,2119,2121,2126,2135,2144,2160-2161,2170,2179,2190-2191,2196,2200,2222,2251,2260,2288,2301,2323,2366,2381-2383,2393-2394,2399,2401,2492,2500,2522,2525,2557,2601-2602,2604-2605,2607-2608,2638,2701-2702,2710,2717-2718,2725,2800,2809,2811,2869,2875,2909-2910,2920,2967-2968,2998,3000-3001,3003,3005-3007,3011,3013,3017,3030-3031,3052,3071,3077,3128,3168,3211,3221,3260-3261,3268-3269,3283,3300-3301,3306,3322-3325,3333,3351,3367,3369-3372,3389-3390,3404,3476,3493,3517,3527,3546,3551,3580,3659,3689-3690,3703,3737,3766,3784,3800-3801,3809,3814,3826-3828,3851,3869,3871,3878,3880,3889,3905,3914,3918,3920,3945,3971,3986,3995,3998,4000-4006,4045,4111,4125-4126,4129,4224,4242,4279,4321,4343,4443-4446,4449,4550,4567,4662,4848,4899-4900,4998,5000-5004,5009,5030,5033,5050-5051,5054,5060-5061,5080,5087,5100-5102,5120,5190,5200,5214,5221-5222,5225-5226,5269,5280,5298,5357,5405,5414,5431-5432,5440,5500,5510,5544,5550,5555,5560,5566,5631,5633,5666,5678-5679,5718,5730,5800-5802,5810-5811,5815,5822,5825,5850,5859,5862,5877,5900-5904,5906-5907,5910-5911,5915,5922,5925,5950,5952,5959-5963,5987-5989,5998-6007,6009,6025,6059,6100-6101,6106,6112,6123,6129,6156,6346,6389,6502,6510,6543,6547,6565-6567,6580,6646,6666-6669,6689,6692,6699,6779,6788-6789,6792,6839,6881,6901,6969,7000-7002,7004,7007,7019,7025,7070,7100,7103,7106,7200-7201,7402,7435,7443,7496,7512,7625,7627,7676,7741,7777-7778,7800,7911,7920-7921,7937-7938,7999-8002,8007-8011,8021-8022,8031,8042,8045,8080-8090,8093,8099-8100,8180-8181,8192-8194,8200,8222,8254,8290-8292,8300,8333,8383,8400,8402,8443,8500,8600,8649,8651-8652,8654,8701,8800,8873,8888,8899,8994,9000-9003,9009-9011,9040,9050,9071,9080-9081,9090-9091,9099-9103,9110-9111,9200,9207,9220,9290,9415,9418,9485,9500,9502-9503,9535,9575,9593-9595,9618,9666,9876-9878,9898,9900,9917,9929,9943-9944,9968,9998-10004,10009-10010,10012,10024-10025,10082,10180,10215,10243,10566,10616-10617,10621,10626,10628-10629,10778,11110-11111,11967,12000,12174,12265,12345,13456,13722,13782-13783,14000,14238,14441-14442,15000,15002-15004,15660,15742,16000-16001,16012,16016,16018,16080,16113,16992-16993,17877,17988,18040,18101,18988,19101,19283,19315,19350,19780,19801,19842,20000,20005,20031,20221-20222,20828,21571,22939,23502,24444,24800,25734-25735,26214,27000,27352-27353,27355-27356,27715,28201,30000,30718,30951,31038,31337,32768-32785,33354,33899,34571-34573,35500,38292,40193,40911,41511,42510,44176,44442-44443,44501,45100,48080,49152-49161,49163,49165,49167,49175-49176,49400,49999-50003,50006,50300,50389,50500,50636,50800,51103,51493,52673,52822,52848,52869,54045,54328,55055-55056,55555,55600,56737-56738,57294,57797,58080,60020,60443,61532,61900,62078,63331,64623,64680,65000,65129,65389
    cat 30.masscan.Scanning.txt | grep tcp | cut -d " " -f 3 | sort -n | uniq > 30.1.masscan.Ports.txt

    cat 28.1.Censys.Ports.txt 30.1.masscan.Ports.txt | sort -n | uniq > 30.2.Total.Ports.txt

    echo "Running Nmap TCP..."
    > 30.3.Nmap.TCP.txt
    cat 30.2.Total.Ports.txt | while read line; do
        sudo nmap -sV -sC -Pn --open -iL 29.Final.IPs.txt -p $line >> 30.3.Nmap.TCP.txt
    done

    echo "Running Nmap UDP..."
    sudo nmap -iL 29.Final.IPs.txt -sU -nn -Pn --top-ports=10 > 30.4.Nmap.UDP.txt

    cd ..
    echo "Date and Time: $(date '+%Y-%m-%d %H:%M:%S')"
}

Websites_Screenshots () {

    echo "#################################################"
    echo "#              Websites Screenshots             #"
    echo "#################################################"
    
    echo "Date and Time: $(date '+%Y-%m-%d %H:%M:%S')"
    
    echo "#################################################"
    
    if [[ -z $2 ]]; then echo "Usage: $0 $1 example.com"; exit 1; fi

    Domain=$2 && echo "Domain: $Domain"
    mkdir -p "$Domain" && cd "$Domain"

    echo "Running ScreenShots..."
    cat 21.Final.SubDomains.txt | ../Tools/aquatone -scan-timeout 2000 -http-timeout 5000 -threads 5 -silent -out 24.Screenshots

    cd ..
    echo "Date and Time: $(date '+%Y-%m-%d %H:%M:%S')"
}

Dir_BruteForce () {

    echo "#################################################"
    echo "#       Directories & Files Brute Forcing       #"
    echo "#################################################"
    
    echo "Date and Time: $(date '+%Y-%m-%d %H:%M:%S')"
    
    echo "#################################################"
    
    if [[ -z $2 ]]; then echo "Usage: $0 $1 example.com"; exit 1; fi

    Domain=$2 && echo "Domain: $Domain"
    mkdir -p "$Domain" && cd "$Domain"

    echo "Running DirSearch..."
    
    > 25.DirSearch.txt
    cat 24.Screenshots/aquatone_urls.txt | while read line; do
        timeout 300 dirsearch -e php,asp,aspx,jsp,html,zip,jar -w $PWD/../Resources/dicc.txt -t 50 -u $line -o $PWD/dir-tmp.txt -q --full-url 1>/dev/null
        cat dir-tmp.txt >> 25.DirSearch.txt
    done

    rm -rf dir-tmp.txt reports && cd ..
    echo "Date and Time: $(date '+%Y-%m-%d %H:%M:%S')"
}

Internet_Archive () {

    echo "#################################################"
    echo "#                Internet Archive               #"
    echo "#################################################"
    
    echo "Date and Time: $(date '+%Y-%m-%d %H:%M:%S')"
    
    echo "#################################################"
    
    if [[ -z $2 ]]; then echo "Usage: $0 $1 example.com"; exit 1; fi

    Domain=$2 && echo "Domain: $Domain"
    mkdir -p "$Domain" && cd "$Domain"

    echo "Running WayBackURLs..."
    
    > 26.WayBackURLs.txt
    cat 22.All.SubDomains.txt | while read line; do
        echo $line | ../Tools/bin/waybackurls >> 26.WayBackURLs.txt
    done

    echo "Extract Parameters & Files..."
    cat 26.WayBackURLs.txt | sort -u | ../Tools/bin/unfurl keys | sort -u > 26.1.Parameters.txt
    cat 26.WayBackURLs.txt | sort -u | grep -P "\w+\.js(\?|$)" | sort -u > 26.2.JS.Files.txt
    cat 26.WayBackURLs.txt | sort -u | grep -P "\w+\.php(\?|$)" | sort -u > 26.3.PHP.Files.txt
    cat 26.WayBackURLs.txt | sort -u | grep -P "\w+\.jsp(\?|$)" | sort -u > 26.4.JSP.Files.txt
    cat 26.WayBackURLs.txt | sort -u | grep -P "\w+\.aspx(\?|$)" | sort -u > 26.5.ASPX.Files.txt

    cd ..
    echo "Date and Time: $(date '+%Y-%m-%d %H:%M:%S')"
}

AWS_S3_Buckets () {

    echo "#################################################"
    echo "#                  AWS S3 Buckets               #"
    echo "#################################################"
    
    echo "Date and Time: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "Insert your AWS API Keys using 'aws configure'"
    echo "#################################################"
    
    if [[ -z $2 ]]; then echo "Usage: $0 $1 example.com"; exit 1; fi

    Domain=$2 && echo "Domain: $Domain"
    mkdir -p "$Domain" && cd "$Domain"

    echo "Applying permutations on wordlist..."
    domain=`echo $Domain | cut -d "." -f1`
    > AWS.Wordlist.txt
    for i in `cat ../Resources/common_bucket_prefixes.txt`; do
        for word in {dev,development,stage,s3,staging,prod,production,test}; do
            echo $domain-$i-$word >> AWS.Wordlist.txt
            echo $domain-$i.$word >> AWS.Wordlist.txt
            echo $domain-$i$word >> AWS.Wordlist.txt
            echo $domain.$i$word >> AWS.Wordlist.txt
            echo $domain.$i-$word >> AWS.Wordlist.txt
            echo $domain.$i.$word >> AWS.Wordlist.txt
        done
    done

    echo "Running S3Scanner..."
    s3scanner --threads 10 scan --buckets-file AWS.Wordlist.txt | grep "bucket_exists" > 31.AWS.Result.txt

    rm AWS.Wordlist.txt && cd ..
    echo "Date and Time: $(date '+%Y-%m-%d %H:%M:%S')"
}

Github_Leaked_Secrets () {

    echo "#################################################"
    echo "#             Github Leaked Secrets             #"
    echo "#################################################"
    
    echo "Date and Time: $(date '+%Y-%m-%d %H:%M:%S')"
    
    echo "#################################################"
    
    if [[ -z $2 ]]; then echo "Usage: $0 $1 github_username"; exit 1; fi

    User=$2 && echo "User: $User"
    #rm -rf "GitHub_$User"
    mkdir -p "GitHub_$User" && cd "GitHub_$User"
    mkdir -p Repos Native_Result && cd Repos

    # Fetch repositories that are not forks and clone them
    curl -s https://api.github.com/users/$User/repos | jq -r '.[] | select(.fork == false) | .name' | \
    while read repo; do
        echo "Downloading: $repo"
        git clone https://github.com/$User/$repo >/dev/null 2>&1
    done

    # Check if there are repositories to search
    if [[ $(find . -type d) ]]; then
    
        # Find sensitive data inside repos using git
        for dir in ./*/; do
            echo "Native Searching: $dir"
            cd "$dir"
            git log -p | grep -iE "api|key|user|uname|pw|pass|mail|credential|login|token|secret" > Commits.txt
            repo_name=$(basename "$dir")
            cat Commits.txt | aha > "../../Native_Result/${repo_name}_SECRETS.html"
            cd ..
        done

        # Find sensitive data inside repos using trufflehog
        > ../Trufflehog_Result.txt
        for dir in ./*/; do
            echo "Trufflehog Searching: $dir"
            trufflehog --entropy=False --regex "$dir" >> ../Trufflehog_Result.txt
        done
    fi

    cd ..
    echo "Date and Time: $(date '+%Y-%m-%d %H:%M:%S')"

}

ALL () {

    echo "#################################################"
    echo "#                Run All Commands               #"
    echo "#################################################"
    
    echo "Date and Time: $(date '+%Y-%m-%d %H:%M:%S')"
    
    echo "#################################################"
    
    if [[ -z $3 ]]; then echo "Usage: $0 $1 example.com github_username"; exit 1; fi

    Domain=$2 && echo "Domain: $Domain"
    User=$3 && echo "User: $User"

    Passive_Scraping 2 $Domain
    Brute_Force 3 $Domain
    WildCard_Removal 4 $Domain
    Spidering 5 $Domain
    TakeOver 6 $Domain
    Censys 7 $Domain
    Port_Scanning 8 $Domain
    Websites_Screenshots 9 $Domain
    Dir_BruteForce 10 $Domain
    Internet_Archive 11 $Domain
    AWS_S3_Buckets 12 $Domain
    Github_Leaked_Secrets 13 $User

}

Usage() {

    echo "Usage: $0 <Command Number>"

    echo "+----+-------------------------+------------------------------------------------------+"
    echo "| No | Command                 | Description                                          |"
    echo "+----+-------------------------+------------------------------------------------------+"
    echo "| 0  | Setup                   | Initializes the environment and installs tools.      |"
    echo "|----|-------------------------|------------------------------------------------------|"
    echo "| 1  | Run All                 | Executes all processes sequentially.                 |"
    echo "|----|-------------------------|------------------------------------------------------|"
    echo "| 2  | Passive Scraping        | Performs passive data collection and enumeration.    |"
    echo "|----|-------------------------|------------------------------------------------------|"
    echo "| 3  | Brute Force             | Executes brute force attacks on discovered domains.  |"
    echo "|----|-------------------------|------------------------------------------------------|"
    echo "| 4  | WildCard Removal        | Removes wildcard entries.                            |"
    echo "|    |                         | Depends on Passive Scraping & Brute Force.           |"
    echo "|----|-------------------------|------------------------------------------------------|"
    echo "| 5  | Spidering               | Crawls and collects data from domains.               |"
    echo "|    |                         | Depends on WildCard Removal.                         |"
    echo "|----|-------------------------|------------------------------------------------------|"
    echo "| 6  | TakeOver                | Identifies and exploits domain takeovers.            |"
    echo "|    |                         | Depends on Passive Scraping, Brute Force & Spidering.|"
    echo "|----|-------------------------|------------------------------------------------------|"
    echo "| 7  | Censys                  | Queries Censys for domain data.                      |"
    echo "|----|-------------------------|------------------------------------------------------|"
    echo "| 8  | Port Scanning           | Scans domains for open ports.                        |"
    echo "|    |                         | Depends on Passive Scraping, Brute Force & Censys.   |"
    echo "|----|-------------------------|------------------------------------------------------|"
    echo "| 9  | Websites Screenshots    | Takes screenshots of websites.                       |"
    echo "|    |                         | Depends on Spidering.                                |"
    echo "|----|-------------------------|------------------------------------------------------|"
    echo "| 10 | Dir BruteForce          | Performs directory brute force on websites.          |"
    echo "|    |                         | Depends on Websites Screenshots.                     |"
    echo "|----|-------------------------|------------------------------------------------------|"
    echo "| 11 | Internet Archive        | Retrieves historical data.                           |"
    echo "|    |                         | Depends on Spidering.                                |"
    echo "|----|-------------------------|------------------------------------------------------|"
    echo "| 12 | AWS S3 Buckets          | Checks for exposed AWS S3 buckets.                   |"
    echo "|----|-------------------------|------------------------------------------------------|"
    echo "| 13 | Github Leaked Secrets   | Searches for leaked secrets on GitHub.               |"
    echo "+----+-------------------------+------------------------------------------------------+"

}

if [ $# -eq 0 ]; then
    Usage
    exit 1
fi

case "$1" in
    0)  Setup ;;
    1)  ALL "$@" ;;
    2)  Passive_Scraping "$@" ;;
    3)  Brute_Force "$@" ;;
    4)  WildCard_Removal "$@" ;;
    5)  Spidering "$@" ;;
    6)  TakeOver "$@" ;;
    7)  Censys "$@" ;;
    8)  Port_Scanning "$@" ;;
    9)  Websites_Screenshots "$@" ;;
    10) Dir_BruteForce "$@" ;;
    11) Internet_Archive "$@" ;;
    12) AWS_S3_Buckets "$@" ;;
    13) Github_Leaked_Secrets "$@" ;;
    *)  echo "Error: Invalid command number." ;;
esac
