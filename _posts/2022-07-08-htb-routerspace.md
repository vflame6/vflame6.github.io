---
layout: post
title: HackTheBox - RouterSpace
categories: [HackTheBox, Easy]
date: 2022-07-08 22:36 +0300
image:
  path: /assets/hackthebox/routerspace/RouterSpace.png
---

## Configuration

If you're using your own machine like me, you have to access HTB network via `OpenVPN`:

```zsh
sudo openvpn lab_access_file.ovpn
```

It is very useful to append `/etc/hosts/` with ip address of the machine. It is useful to get subdomains and to not memorize the address every time.

```zsh
echo '10.10.11.148  routerspace.htb' | sudo tee -a /etc/hosts
```

## Reconnaissance

### nmap scan

```zsh
nmap -p- routerspace.htb
```

```
PORT   STATE SERVICE
22/tcp open  ssh
80/tcp open  http
```

There is a ssh and a web server. Let's dive into web page!

### Web application

![Web page](/assets/hackthebox/routerspace/web_page.png)

At first we check the page, we can see a download button with `Android package` (APK) file. Next we check the source code, there is nothing interesting in it. We download the file. Also, we can check for technologies used in the web application by `whatweb` or `Wappalyzer`.

```zsh
whatweb routerspace.htb
```

```
http://routerspace.htb [200 OK] Bootstrap, Country[RESERVED][ZZ], HTML5, IP[10.10.11.148], JQuery[1.12.4], Modernizr[3.5.0.min], Script, Title[RouterSpace], UncommonHeaders[x-cdn], X-Powered-By[RouterSpace], X-UA-Compatible[ie=edge]
```

There's nothing interesting for us. Let's move on APK file.

### Android package

We need to understand what does this application do. So, at first, we have to emulate this application. We've used an `Anbox` here. Download the latest image available at the [official download page](https://build.anbox.io/android-images/) and use following commands to install it.

```zsh
sudo apt update
sudo apt install anbox
sudo mv ~/Downloads/android*.img /var/lib/anbox/android.img
sudo service anbox-container-manager start
```

Now use launcher to run Anbox app.

![Anbox app](/assets/hackthebox/routerspace/anbox.png)

We have to install RouterSpace.apk into our Anbox. You can do it by following the [documentaion](https://docs.anbox.io/userguide/install_apps.html):

```zsh
sudo apt install android-tools-adb
adb install RouterSpace.apk
```

Then, restart Anbox and the application will appear. Let's open the app and explore it!

![RouterSpace application logo](/assets/hackthebox/routerspace/routerspace_in_anbox.png)


![RouterSpace app](/assets/hackthebox/routerspace/routerspace_app.png)

We can press the `Check Status` button, but it will fail. It tries to connect to a remote server. We have to see the request app performs, we can do it without dissasemble and unsuccessful attempts to find the request (I've tried, don't do that 😂).

## user.txt

### Enumeration

Let's try to intercept this request with `BurpSuite`. To do that we have to configure proxy settings on our Anbox. We have to proxy traffic through BurpSuite.

Check Anbox's IP address:

```zsh
ip addr | grep anbox
```

Set up a new listener in BurpSuite with Anbox's IP address:

![New Burp listener](/assets/hackthebox/routerspace/new_burp_listener.png)

Now set up a global http-proxy for Anbox:

```zsh
adb shell settings put global http_proxy 192.168.250.1:8855
```

Then, return to Anbox and press the button again, you will see the request in Burp.

![App request](/assets/hackthebox/routerspace/app_request.png)

We got it! Send the request to Repeater and let's try to abuse it. We start by including some bash commands with `&&` symbols.

![Request abusing](/assets/hackthebox/routerspace/request_abuse.png)

It works! Now we can perform a lot of things...

### Exploitation

We have `Remote Code Execution`, we got paul user. We noted that `ssh` is enabled on the machine. To establish we have to generate ssh keys and add public key to paul's `authorized_keys`. Don't forget to change authorized_keys permissions to 700.

```zsh
ssh-keygen
```

![Input pub key](/assets/hackthebox/routerspace/input_pub_key.png)

![Key permissions](/assets/hackthebox/routerspace/key_permissions.png)

If everything is good, we will be able to connect via ssh and get our user flag!

```zsh
ssh -i id_rsa paul@routerspace.htb
```

![user.txt](/assets/hackthebox/routerspace/user_txt.png)

## root.txt

### Explore for privilege escalation

I don't like to upload and run `LinPEAS` immediately, because it is noisy and I don't think professionals do really use it. So let's perform a basic enumeration. Check `directories`, `crontab`, `SUID/SGID`... We check for `sudo` version:

```bash
sudo -V
```

```
Sudo version 1.8.31
Sudoers policy plugin version 1.8.31
Sudoers file grammar version 46
Sudoers I/O plugin version 1.8.31
```

We google for vulnerabilities for that version, luckly for us, there is a CVE-2021-3156 with an [exploit](https://github.com/mohinparamasivam/Sudo-1.8.31-Root-Exploit)

### Privilege escalation

We copy files from the repository, then we follow the exploit instructions and get the root:

![Exploit for root](/assets/hackthebox/routerspace/exploit_for_root.png)

## Conclusion

That box was really hard to me, because I didn't had to work with Android packages, so it was something new to me. It was really interesting to learn something new. Privilege escalation was good. I enjoyed the box so much!

Thank you for reading, I hope it was useful for you ❤️
