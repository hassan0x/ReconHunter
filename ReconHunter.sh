#!/bin/bash

Setup () {

    echo "Setup....."
    date

    # Install required packages
    sudo apt-get install -y curl git subfinder nmap massdns masscan httprobe dirsearch awscli trufflehog golang chromium php python3-pip unzip pipx jq || exit 1

    # Set up pipx environment variables and installing censys and s3scanner
    export PIPX_HOME=/opt/pipx
    export PIPX_BIN_DIR=/usr/local/bin
    sudo pipx install censys
    sudo pipx install s3scanner

    # Create and set up Tools directory
    sudo rm -rf Tools
    mkdir Tools 2>/dev/null
    export GOPATH=$PWD/Tools
    
    # Install Go-based tools
    echo "Installing Go-based tools..."
    go install github.com/Ice3man543/SubOver@latest || exit 1
    go install github.com/tomnomnom/unfurl@latest || exit 1
    go install github.com/tomnomnom/waybackurls@latest || exit 1
    go install github.com/jaeles-project/gospider@latest || exit 1

    cd Tools || exit 1

    # Download and set up Aquatone
    wget -q https://github.com/michenriksen/aquatone/releases/download/v1.7.0/aquatone_linux_amd64_1.7.0.zip
    unzip -q aquatone_linux_amd64_1.7.0.zip -d . && rm aquatone_linux_amd64_1.7.0.zip

    # Download and set up Amass
    wget -q https://github.com/owasp-amass/amass/releases/download/v3.23.3/amass_Linux_amd64.zip
    unzip -q amass_Linux_amd64.zip -d . && cp amass_Linux_amd64/amass . && rm -rf amass_Linux_amd64 amass_Linux_amd64.zip

    cd ..
    date
}


Passive_Scraping () {

echo "##### PASSIVE SCRAPING AND RESOLVING #####"
date

# Check for missing arguments
if [[ -z $2 ]]; then
    echo "Usage: $0 <script_name> <domain>"
    exit 1
fi

Domain=$2
echo "Domain: $Domain"

# Create directory and move into it
mkdir -p "$Domain"
cd "$Domain" || exit

# Run Amass
echo "Running Amass..."
../Tools/amass enum -passive -d "$Domain" 2>/dev/null | sort -u > 1.Amass.txt

# Run SubFinder
echo "Running SubFinder..."
subfinder -silent -all -d "$Domain" | sort -u > 2.SubFinder.txt

# Combine results
echo "Combining Results..."
cat 1.Amass.txt 2.SubFinder.txt | tr 'A-Z' 'a-z' | sort -u > 3.Passive.SubDomains.txt

# Resolve subdomains using massdns
echo "Running Resolving..."
massdns -q -r ../Resources/resolvers.txt 3.Passive.SubDomains.txt | grep -E "IN A [0-9]|CNAME" > 4.massDNS.Resolving.txt

# Extract live subdomains and identify dead ones
grep "$Domain" 4.massDNS.Resolving.txt | cut -d " " -f1 | sed 's/.$//' | sort -u > 5.Live.SubDomains.txt
cat 3.Passive.SubDomains.txt 5.Live.SubDomains.txt | sort | uniq -u > 6.Died.SubDomains.txt

# Extract unique IP addresses
grep "IN A" 4.massDNS.Resolving.txt | grep "$Domain" | cut -d " " -f5 | sort -u > 7.IP.Addresses.txt

# Return to previous directory and display the completion time
cd ..
date
}

Brute_Force () {

echo "##### BRUTE FORCING #####"
date

# Ensure domain argument is provided
if [[ -z $2 ]]; then
    echo "Usage: $0 <script_name> <domain>"
    exit 1
fi

Domain=$2
echo "Domain: $Domain"

# Create directory for the domain and move into it
mkdir -p "$Domain"
cd "$Domain" || exit

# Combine wordlists for brute-forcing
echo "Combining Wordlists..."
cat ../Resources/all.txt ../Resources/commonspeak.txt | tr 'A-Z' 'a-z' | sort -u | sed "s/$/.$Domain/g" > Total.Wordlist.txt

# Run massdns for brute force subdomain discovery
echo "Running BruteForce..."
massdns -q -r ../Resources/resolvers.txt Total.Wordlist.txt | grep -E "IN A [0-9]|CNAME" > 8.massDNS.BruteForce.txt

# Extract live subdomains
grep "$Domain" 8.massDNS.BruteForce.txt | cut -d " " -f1 | sed 's/.$//' | sort -u > 9.Live.SubDomains.txt

# Extract unique IP addresses from resolved "A" records
grep "IN A" 8.massDNS.BruteForce.txt | grep "$Domain" | cut -d " " -f5 | sort -u > 10.IP.Addresses.txt

# Clean up the wordlist file
rm Total.Wordlist.txt

# Return to the previous directory and print the end time
cd ..
date
}

WildCard_Removal () {

echo "##### WILDCARD REMOVAL #####"
date

# Check for the required domain argument
    if [[ -z "$2" ]]; then
        echo "Usage: $0 <script_name> example.com"
        return 1
    fi

Domain=$2
echo "Domain: $Domain"

# Create and change to the domain directory
mkdir -p "$Domain"
cd "$Domain" || exit 1

# Combine subdomain lists, convert to lowercase and remove leading wildcards
echo "Running Wildcard Removal..."
cat 5.Live.SubDomains.txt 9.Live.SubDomains.txt | tr A-Z a-z | sort -u | sed 's/^[*.]*//g' > 11.Total.SubDomains.txt

# Check each subdomain in 11.Total.SubDomains.txt to see if it resolves with a wildcard
> 12.Having.Wildcard.txt
cat 11.Total.SubDomains.txt | while read line; do
host -t A *.$line | cut -d " " -f1 | sed 's/^*.//g' >> 12.Having.Wildcard.txt
done

cat 11.Total.SubDomains.txt 12.Having.Wildcard.txt | sort | uniq -u > 12.1.NotHaving.Wildcard.txt

# Process each subdomain from 12.Having.Wildcard.txt to find and save the root wildcard subdomains to 12.2.Root.Wildcard.txt
> 12.2.Root.Wildcard.txt
cat 12.Having.Wildcard.txt | while read -r line; do
    tmp=""
    while true; do
        if [[ host -t A "*.$line" | grep -q NXDOMAIN ]]; then
            echo "$tmp" >> 12.2.Root.Wildcard.txt
            break
        fi
        tmp="$line"
        line=$(echo "$line" | cut -d "." -f2-)
    done
done

cat 12.2.Root.Wildcard.txt 12.1.NotHaving.Wildcard.txt | sort -u > 13.Clean.SubDomains.txt

cd ..
date
}

Spidering () {

echo "##### DOMAINS SPIDERING #####"
date

if [[ $2 == "" ]];then
echo "Usage: $0 $1 example.com"
exit
fi

Domain=$2
echo "Domain:" $Domain
mkdir $Domain 2>/dev/null
cd $Domain

echo "Running HTTProbe..."
cat 13.Clean.SubDomains.txt | httprobe -p https:8443 http:8080,8000 > 14.HTTProbe.txt

echo "Running GoSpider..."
../Tools/bin/gospider -S 14.HTTProbe.txt -o 14.1.Spidering -t 50 -c 10 -d 3 --subs --js --sitemap --robots 1>/dev/null # | grep "\[url\]"

cd 14.1.Spidering
for file in *; do
    if [[ -f $file ]]; then
        mv "$file" "${file}.txt"
    fi
done
cd ..

cat 14.1.Spidering/* | grep -Eo '[a-z0-9_-]*\.[a-z0-9_-]*\.*[a-z0-9_-]*\.*[a-z0-9_-]*\.*[a-z0-9_-]*' | grep $Domain | sort -u > 15.Passive.SubDomains.txt

echo "Running Resolving..."
> 16.massDNS.Resolving.txt
massdns -r ../Resources/resolvers.txt -q 15.Passive.SubDomains.txt | grep -E "IN A [0-9]|CNAME" >> 16.massDNS.Resolving.txt
cat 16.massDNS.Resolving.txt | grep $Domain | cut -d " " -f1 | sort -u | sed 's/.$//' > 17.Live.SubDomains.txt
cat 15.Passive.SubDomains.txt 17.Live.SubDomains.txt | sort | uniq -u > 18.Died.SubDomains.txt
cat 16.massDNS.Resolving.txt | grep "IN A" | grep $Domain | cut -d " " -f5 | sort -u > 19.IP.Addresses.txt

cat 6.Died.SubDomains.txt 18.Died.SubDomains.txt | sort -u > 20.Died.SubDomains.txt
cat 13.Clean.SubDomains.txt 17.Live.SubDomains.txt | sort -u > 21.Final.SubDomains.txt
cat 20.Died.SubDomains.txt 21.Final.SubDomains.txt | sort -u > 22.All.SubDomains.txt

cd ..
date
}

TakeOver () {

echo "##### SUBDOMAINS TAKEOVER #####"
date

if [[ $2 == "" ]];then
echo "Usage: $0 $1 example.com"
exit
fi

Domain=$2
echo "Domain:" $Domain
mkdir $Domain 2>/dev/null
cd $Domain

echo "Running Subdomains Takeover..."

cp ../Resources/providers.json providers.json
../Tools/bin/SubOver -l 22.All.SubDomains.txt -v > 23.Takeover.txt 2>&1
rm providers.json

echo "Running The Second Check..."

cat 22.All.SubDomains.txt | while read sub;do
host $sub | grep alias | cut -d " " -f1,6 > take.tmp
cat take.tmp >> 23.1.Takeover2.txt
cat take.tmp | sed 's/ /\n/' | tail -n +2 | while read line;do
host $line | grep NXDOMAIN;
done
done
rm take.tmp

cd ..
date
}

Censys () {

echo "##### CENSYS SEARCH ENGINE #####"
echo "##### Make sure to put your censys API keys using censys config command #####"
date

#printf "$API_ID\n$API_Secret\n" | censys config > /dev/null 2>&1

if [[ $2 == "" ]];then
echo "Usage: $0 $1 example.com"
exit
fi

Domain=$2
echo "Domain:" $Domain
mkdir $Domain 2>/dev/null
cd $Domain

censys search --pages 1000 "$Domain" > 27.Censys.txt
cat 27.Censys.txt | grep '"ip":' | cut -d '"' -f 4 | sort -n | uniq > 28.IP.Addresses.txt
cat 27.Censys.txt | grep '"port"' | cut -d ":" -f 2 | cut -d "," -f 1 | cut -d " " -f 2 | sort -n | uniq > 28.1.Censys.Ports.txt
cat 27.Censys.txt | jq '.[] | .ip as $ip | .services[] | [$ip, .port, .transport_protocol, .service_name] | join(" ")' | cut -d '"' -f 2 > 28.2.Censys.IP.Ports.txt

cd ..
date
}

Port_Scanning () {

echo "##### IP & PORT SCANNING #####"
date

if [[ $2 == "" ]];then
echo "Usage: $0 $1 example.com"
exit
fi

Domain=$2
echo "Domain:" $Domain
mkdir $Domain 2>/dev/null
cd $Domain

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
date
}

Websites_Screenshots () {

echo "##### DOMAINS SCREENSHOTS #####"
date

if [[ $2 == "" ]];then
echo "Usage: $0 $1 example.com"
exit
fi

Domain=$2
echo "Domain:" $Domain
mkdir $Domain 2>/dev/null
cd $Domain

echo "Running ScreenShots..."
cat 21.Final.SubDomains.txt | ../Tools/aquatone -scan-timeout 2000 -http-timeout 5000 -threads 5 -silent -out 24.Screenshots

cd ..
date
}

Dir_BruteForce () {

echo "##### DIRECTORIES & FILES BRUTE FORCING #####"
date

if [[ $2 == "" ]];then
echo "Usage: $0 $1 example.com"
exit
fi

Domain=$2
echo "Domain:" $Domain
mkdir $Domain 2>/dev/null
cd $Domain

echo "Running DirSearch..."

> 25.DirSearch.txt
cat 24.Screenshots/aquatone_urls.txt | while read line; do
timeout 300 dirsearch -e php,asp,aspx,jsp,html,zip,jar -w $PWD/../Resources/dicc.txt -t 50 -u $line -o $PWD/dir-tmp.txt -q --full-url 1>/dev/null
cat dir-tmp.txt >> 25.DirSearch.txt
done
rm -r dir-tmp.txt reports 2>/dev/null

cd ..
date
}

Internet_Archive () {

echo "##### INTERNET ARCHIVE #####"
date

if [[ $2 == "" ]];then
echo "Usage: $0 $1 example.com"
exit
fi

Domain=$2
echo "Domain:" $Domain
mkdir $Domain 2>/dev/null
cd $Domain

echo "Running WayBackURLs..."

> 26.WayBackURLs.txt
cat 22.All.SubDomains.txt | while read line; do
echo $line | ../Tools/bin/waybackurls >> 26.WayBackURLs.txt
done

# Extract Parameters & Files
cat 26.WayBackURLs.txt | sort -u | ../Tools/bin/unfurl keys | sort -u > 26.1.Parameters.txt
cat 26.WayBackURLs.txt | sort -u | grep -P "\w+\.js(\?|$)" | sort -u > 26.2.JS.Files.txt
cat 26.WayBackURLs.txt | sort -u | grep -P "\w+\.php(\?|$)" | sort -u > 26.3.PHP.Files.txt
cat 26.WayBackURLs.txt | sort -u | grep -P "\w+\.jsp(\?|$)" | sort -u > 26.4.JSP.Files.txt
cat 26.WayBackURLs.txt | sort -u | grep -P "\w+\.aspx(\?|$)" | sort -u > 26.5.ASPX.Files.txt

cd ..
date
}

AWS_S3_Buckets () {

echo "##### AWS S3 BUCKETS #####"
echo "##### Make sure to put your AWS API Keys using aws configure command #####"
date

#AWSAccessKeyId=
#AWSSecretKey=
#printf "$AWSAccessKeyId\n$AWSSecretKey\nus-west-1\njson\n" | aws configure > /dev/null 2>&1

if [[ $2 == "" ]];then
echo "Usage: $0 $1 example.com"
exit
fi

Domain=$2
echo "Domain:" $Domain
mkdir $Domain 2>/dev/null
cd $Domain

# Apply permutations on wordlist
domain=$(echo $Domain | cut -d "." -f1)
> AWS.Wordlist.txt
for i in $(cat ../Resources/common_bucket_prefixes.txt); do
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

rm AWS.Wordlist.txt
cd ..
date
}

Github_Leaked_Secrets () {

echo "##### GITHUB LEAKED SECRETS #####"
date

if [[ $2 == "" ]];then
echo "Usage: $0 $1 github_username"
exit
fi

User=$2
echo "User:" $User
rm -r GitHub_"$User" 2>/dev/null
mkdir GitHub_"$User"; cd GitHub_"$User"
mkdir Repos; cd Repos

# Find the repos owned by the target organization (not forked), then clone these repos locally
curl -s https://api.github.com/users/$User/repos | grep 'full_name\|fork"' \
| cut -d " " -f6 | cut -d "/" -f2 | cut -d '"' -f1 | cut -d "," -f1 | \
while read line1; do read line2; echo $line1 $line2; done | \
grep false | cut -d " " -f1 | while read repo;
do echo "Downloading:" $repo; git clone https://github.com/$User/$repo > /dev/null 2>&1; done

# check if there is no repository to search
if ! [[ $(find . -type d) == "." ]]; then
# Find sensitive data inside repos using git
mkdir ../Native_Result
for i in ./*/; do
cd $i
echo "Native Searching:" $i
git log -p > Commits.txt
j=`echo $i | sed 's/\.\///' | sed 's/\///'`;
cat Commits.txt | grep --color=always -i "api\|key\|user\|uname\|pw\|pass\|mail\|credential\|login\|token\|secret" | aha > ../../Native_Result/"$j"_SECRETS.html
cd ..
done

# Find sensitive data inside repos using trufflehog
for i in ./*/; do
echo "Trufflehog Searching:" $i
trufflehog --entropy=False --regex $i >> ../Trufflehog_Result.txt;
done
cd ..
fi

cd ..
date
}

ALL () {

echo "##### Run All The Commands #####"

if [[ $3 == "" ]];then
echo "Usage: $0 $1 example.com github_username"
exit
fi

Domain=$2
User=$3
echo "Domain:" $Domain "User:" $User

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
    cat << EOF
Usage: $0 <Command_Number> <Domain_Name>

Available Commands:
  0  -> Setup
      - Initializes the environment and installs required tools.
  1  -> Run All
      - Executes all processes sequentially.
  2  -> Passive Scraping
      - Performs passive data collection and enumeration.
  3  -> Brute Force
      - Executes brute force attacks on discovered domains.
  4  -> WildCard Removal
      - Removes wildcard entries from the list of subdomains.
      - Depends on Passive Scraping and Brute Force.
  5  -> Spidering
      - Crawls and collects data from discovered domains.
      - Depends on WildCard Removal.
  6  -> TakeOver
      - Attempts to identify and exploit potential domain takeovers.
      - Depends on Passive Scraping, Brute Force, and Spidering.
  7  -> Censys
      - Queries Censys for additional data on domains.
  8  -> Port Scanning
      - Scans discovered domains for open ports.
      - Depends on Passive Scraping, Brute Force, and Censys.
  9  -> Websites Screenshots
      - Takes screenshots of websites for visual inspection.
      - Depends on Spidering.
  10 -> Dir BruteForce
      - Performs directory brute force attacks on websites.
      - Depends on Websites Screenshots.
  11 -> Internet Archive
      - Retrieves historical data from the Internet Archive.
      - Depends on Spidering.
  12 -> AWS S3 Buckets
      - Enumerates and checks for exposed AWS S3 buckets.
  13 -> Github Leaked Secrets
      - Searches for leaked secrets on GitHub.

Example:
  $0 1 example.com # Executes the 'Run All' command

EOF
}

Main() {

# Main Code
if [ $# -eq 0 ]; then
    Usage
    exit 1
fi

# Check the command number and call the corresponding function
case $1 in
    0)
        Setup
        ;;
    1)
        ALL "$@"
        ;;
    2)
        Passive_Scraping "$@"
        ;;
    3)
        Brute_Force "$@"
        ;;
    4)
        WildCard_Removal "$@"
        ;;
    5)
        Spidering "$@"
        ;;
    6)
        TakeOver "$@"
        ;;
    7)
        Censys "$@"
        ;;
    8)
        Port_Scanning "$@"
        ;;
    9)
        Websites_Screenshots "$@"
        ;;
    10)
        Dir_BruteForce "$@"
        ;;
    11)
        Internet_Archive "$@"
        ;;
    12)
        AWS_S3_Buckets "$@"
        ;;
    13)
        Github_Leaked_Secrets "$@"
        ;;
    *)
        echo "Error: Invalid command number."
        Usage
        exit 1
        ;;
esac
}

Main
