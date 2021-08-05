# [1] Technology OSINT

## [1.1] Root-Domains Enumeration

### [1.1.1] Acquisitions
```
# Replace CompanyName instead of google
https://index.co/company/google/acquirees
```

### [1.1.2] Reverse Whois
```
# Find root domains owned by the same org (Reverse Whois)
amass intel -src -whois -d example.com
```

### [1.1.3] ASN (Reverse DNS & Cert Dump)
```
# Find ASN for org
amass intel -org example.com

# Find root domains through Reverse DNS (ASN -> CIDR -> Reverse DNS)
amass intel -ipv4 -src -asn 26808

# Find root domains through Reverse DNS + SSL Cert Dump
amass intel -active -ipv4 -src -asn 26808
```

## [1.2] Sub-Domains Enumeration

### [1.2.1] Public Data Sources
```
# Rapid7 Project Sonar
# https://github.com/Cgboal/SonarSearch
# API -> https://sonar.omnisint.io
/root/go/bin/crobat -s example.com

# Amass
# https://github.com/OWASP/Amass
amass enum -passive -src -d example.com

# SubFinder
# https://github.com/projectdiscovery/subfinder
./subfinder -silent -d example.com
```

### [1.2.2] Brute Force
```
# https://github.com/OJ/gobuster
gobuster dns -d example.com -t 50 -w /usr/share/amass/wordlists/subdomains.lst

# Wordlists
wget https://raw.githubusercontent.com/assetnote/commonspeak2-wordlists/master/subdomains/subdomains.txt
wget https://gist.githubusercontent.com/jhaddix/86a06c5dc309d08580a018c66354a056/raw/96f4e51d96b2203f19f6381c8c545b278eaa0837/all.txt
sort subdomains.txt all.txt | uniq > jhaddix_commonspeak.txt
```

### [1.2.3] Alternations
```
# https://github.com/infosec-au/altdns
./altdns.py -i known-subdomains.txt -o new_subdomains.txt
```

### [1.2.4] Zone Transfer
```
# DIG (Zone Transfer)
dig zonetransfer.me NS
dig @nsztm1.digi.ninja zonetransfer.me AXFR

# HOST (Zone Transfer)
host -t NS zonetransfer.me
host -t AXFR zonetransfer.me nsztm2.digi.ninja

# DNSRecon (Zone Transfer)
dnsrecon -d zonetransfer.me -t axfr
```

### [1.2.5] Reverse DNS & Cert Dump
```
# ASN -> CIDR
nmap --script targets-asn --script-args targets-asn.asn=17012

# CIDR -> IP
nmap -sL -n scope.txt

# Nmap SSL Cert Dump
nmap -p443 --open --script ssl-cert -iL scope.txt | \
grep "Subject Alternative Name\|Nmap scan report" | while read line1;
do read line2; if [[ $line2 == *"example.com"* ]];
then echo $line1 $line2; fi; done

# DNSRecon Reverse DNS
dnsrecon -r 8.8.8.0/24
```

### [1.2.6] Sub-Domains Takeover
```
# Target Specific
go get https://github.com/Ice3man543/SubOver
git clone https://github.com/Ice3man543/SubOver
cd SubOver
go run subover.go -l sub-domains.txt

# HackerOne Programs Subdomains Takeover
wget https://raw.githubusercontent.com/arkadiyt/bounty-targets-data/master/data/domains.txt
mkdir domains-data
for host in $(cat domains.txt);
do amass enum --passive -d $host -o domains-data/$host.txt;
go run subover.go -l domains-data/$host.txt | tee -a subdomains-takeover.txt;
```

### [1.2.7] Live Sub-Domains
```
# HTTProbe
cat subdomains.txt | /root/go/bin/httprobe > live-domains.txt

# Eyewitness
eyewitness -f live-domains.txt --timeout 30 -d result --no-prompt

# Gowitness
for line in $(cat live-domains.txt); do
timeout 30 ./gowitness single $line --timeout 30 --delay 10 &
sleep 2
done
```

## [1.3] IP Addresses

### [1.3.1] Censys
```
# Install the packege
pip install censys-command-line

# API (Search through all the data except hostnames for IPs belong to the target company)
censys --censys_api_id XXXXX --censys_api_secret XXXXX --query_type ipv4 "google" --start_page 1 --max_pages 10 | jq

# API (Get the running services on IP or CIDR)
for host in $(cat scope.txt);do
censys --censys_api_id XXX --censys_api_secret XXX --query_type ipv4 "ip:$host" --fields ip protocols --append false | jq >> censys.txt
done
cat censys.txt | egrep "ip|/" | cut -d '"' -f 2,4 | sed 's/ip"/\n/' > censys_map.txt
```

### [1.3.2] Shodan
```
# Search through the banners only for IPs belong to the target company
"yahoo"

# Search through SSL Certs for IPs belong to the target company
ssl.cert.subject.cn:"yahoo"

# Search through Hostnames (Reverse DNS)
hostname:"yahoo"

# API (Get the running services on IP
for host in $(cat scope.txt);do
nmap -sL -n $host | egrep "Nmap scan report" | cut -d " " -f5 >> hosts_file.txt
done

for host in $(cat hosts_file.txt);do
shodan host $host >> shodan_scope_result.txt
done

cat shodan_scope_result.txt | egrep "/tcp|/udp" | sort -n | uniq > ports.txt
cat shodan_scope_result.txt | egrep -v ":|/" | egrep . > IP.txt
cat shodan_scope_result.txt | egrep "^[0-9]|Hostnames|/tcp|/udp" > shodan_map.txt
```

### [1.3.3] Service Scanning
```
# Nmap scan top 10 ports
nmap -iL IP.txt -oA result --open -p 21,22,23,25,80,110,139,443,445,3306,3389

# Nmap tracking result (1000 common ports)

d=$(date +%Y-%m-%d)
y=$(date -d yesterday +%Y-%m-%d)

nmap -iL IP.txt -oG scan.gnmap > /dev/null
cat scan.gnmap | grep -v "# Nmap" | sort > scan-$d.gnmap
rm -f scan.gnmap diff.txt

if [ -e scan-$y.gnmap ]; then
  comm -3 scan-$y.gnmap scan-$d.gnmap > diff.txt
  if [ ! -s diff.txt ]; then rm -f diff.txt; fi
fi
```

## [1.4] Github Recon
```
# Find the repos owned by the target organization (not forked)
# then clone these repos locally
curl -s https://api.github.com/users/$domain/repos | grep 'full_name\|fork"' \
| cut -d " " -f6 | cut -d "/" -f2 | cut -d '"' -f1 | cut -d "," -f1 | \
while read line1; do read line2; echo $line1 $line2; done | \
grep false | cut -d " " -f1 | while read repo;
do git clone https://github.com/$domain/$repo; done

# Find sensitive data inside repos using git
cd repo-name
git log -p > commits.txt
cat commits.txt | grep "api\|key\|user\|uname\|pw\|pass\|mail\|credential\|login\|token\|secret\|"

# Find sensitive data inside repos using trufflehog
trufflehog --regex --entropy=False repo-name
```

## [1.5] Cloud Recon
```
# Clone the repo
git clone https://github.com/gwen001/s3-buckets-finder
cd s3-buckets-finder

# Download wordlist then apply permutations on it
wget https://raw.githubusercontent.com/nahamsec/lazys3/master/common_bucket_prefixes.txt
domain="example.com"
for i in $(cat common_bucket_prefixes.txt); do
for word in {dev,development,stage,s3,staging,prod,production,test}; do
echo $domain-$i-$word >> res.txt;
echo $domain-$i.$word >> res.txt;
echo $domain-$i$word >> res.txt;
echo $domain.$i$word >> res.txt;
echo $domain.$i-$word >> res.txt;
echo $domain.$i.$word >> res.txt;
done; done

# Start the brute force
php s3-buckets-bruteforcer.php --bucket res.txt
```

# [2] People OSINT

## [2.1] Hunter.IO
```
# Website Search
https://hunter.io/search/google.com

# API count emails
https://api.hunter.io/v2/email-count?domain=google.com

# API get emails
https://api.hunter.io/v2/domain-search?domain=google.com&api_key=XXXXX

# API get emails using Curl
curl -s "https://api.hunter.io/v2/domain-search?domain=google.com&api_key=XXXXX" | grep "@google.com" | cut -d '"' -f4 | sort -n | uniq
```

## [2.2] Google Dorks

Save the following code as file.sh and run it with bash file.sh, it will collect all the target company emails from google search engine.
```
Query="uber.com"
UserAgent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.146 Safari/537.36"

rm tmp.txt emails.txt 2>/dev/null

Start=0
while(true);do
  echo "Request Data..."
  echo "https://www.google.com/search?q=intext:${Query}&hl=en&filter=0&enum=100&start=${Start}"
  curl -s -A $UserAgent "https://www.google.com/search?q=intext:"${Query}"&hl=en&filter=0&num=100&start="${Start} > tmp.txt

  if grep -q "did not match any documents" tmp.txt
  then
    echo "End of Data."
    rm tmp.txt emails.txt 2>/dev/null
    break
  fi

  if grep -q "document has moved" tmp.txt
  then
    echo "Blocked, try after while."
    rm tmp.txt emails.txt 2>/dev/null
    break
  fi

  clear
  cat tmp.txt | grep -Eio '[[:alnum:]_.-]+(@|@<em>)'${Query} | tr A-Z a-z | sed 's/<em>//g' | sort -n | uniq >> emails.txt
  echo "Emails Count:" $(cat emails.txt | sort -n | uniq | wc -l)
  cat emails.txt | sort -n | uniq
  Start=$((Start+100))
done
```

## [2.3] LinkedIn
```
function sleep(ms) {
	  return new Promise(resolve => setTimeout(resolve, ms)) }

flag = 0
data = []
domain = "uber.com"

async function connections() {
while(1){

		for (i=1;i<20;i=i+5){
			  window.scrollTo(0,document.body.scrollHeight/i)
			  await sleep(1000)
		}
		
		users = document.getElementsByClassName('entity-result__title-text  t-16')
		if (users.length < 10){ flag = 1 }
		
		for (i=0;i<10;i++){
			  name = users[i].firstElementChild.firstElementChild.firstElementChild.innerText
			  first = name.split(" ")[0].replace(/[^a-z]+/gi, '')
			  second = name.split(" ")[1].replace(/[^a-z]+/gi, '')
			  if(first.length > 2 && second.length > 2){
				    name = first + "." + second + "@" + domain
				    data.push(name)
			  }
		}
		data = data.sort()
		
		result = ""
		for (i=0;i<data.length;i++){
		    result = result + '\n' + data[i]
		}
		console.log(result)
		console.log('Data Count: ', data.length)
		
		if (flag == 1){ break }
		
		await sleep(1000)
		document.getElementsByClassName('artdeco-pagination__button artdeco-pagination__button--next artdeco-button artdeco-button--muted artdeco-button--icon-right artdeco-button--1 artdeco-button--tertiary ember-view')[0].click()
		await sleep(4000)
		}
}

connections()
```

## [2.4] Leaked Databases
```
# HaveIBeenPwned
# Website Search
https://haveibeenpwned.com/unifiedsearch/hassansaad0x@gmail.com

# Code to Automate
Header1="User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:78.0) Gecko/20100101 Firefox/78.0"
Header2="Accept-Language: en-US"
Header3="Accept: application/json"

for line in $(cat emails.txt);do
data=`curl -s -H "$Header1" -H "$Header2" -H "$Header3" "https://haveibeenpwned.com/unifiedsearch/"$line | jq | grep '"Name":'`
if [ ! -z "$data" ]; then
echo $line $data
fi
done

# Pastebin
site:pastebin.com "kevin mitnick" "password"
site:pastebin.com "leaked" "download"
```

Kindly refer to this repo: https://github.com/hassan0x/ReconHunter
