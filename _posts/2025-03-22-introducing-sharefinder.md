---
layout: post
title: Introducing Sharefinder - Network Shares Enumeration Tool
date: 2025-03-22 09:05 +0300
description: Introducing a new tool to find and enumerate SMB shares in networks and Active Directory domains.
categories: [Pentest, Development]
image:
  path: /assets/pentest/introducing-sharefinder/sharefinder_demo.jpg
---

## Introduction

Hi! Today I want to share my new tool - `sharefinder`. It is a tool for finding SMB shares and their privileges in Active Directory networks and domains. In this blog post I will show its functionality, discuss some problems with developing and planned improvements for the tool.

`sharefinder` is already available on my GitHub - [https://github.com/vflame6/sharefinder](https://github.com/vflame6/sharefinder).

> All screenshots in this blog post are made with [Game of Active Directory (GOAD)](https://github.com/Orange-Cyberdefense/GOAD) full lab setup.
> 

### Reason to write a tool

I wanted to make a tool with which I could do SMB shares access scans, and do them well, without a lot of noise with unnecessary information. 

Already available alternative tools (**NetExec**, **PowerHuntShares**, **shareenum**, ...) could, in principle, handle this task, but they either lack options for outputting results or are not designed for network scanning. And PowerHuntShares crashes if you have a different operating system locale than the tool's authors (the bug has been around [since 2022](https://github.com/NetSPI/PowerHuntShares/issues/3)).

The main requirements were the ability to scan networks for SMB shares anonymously, with credentials, and the ability to use an Active Directory and LDAP account to find targets without scanning the network. And also to visualize the results of such scans, for example, in the form of an HTML file with tables. 

### Problems in developing

To check user rights to interact with shares I wanted to try to use **Security Descriptor (SD)** in files, as it is implemented in [shareenum](https://github.com/CroweCybersecurity/shareenum). This implementation has a significant impact for stealth of enumerating shares because nothing needs to be written on disk. Also, this could help identify the exact permissions (local NTFS or share ACLs) used in give or deny the access for the current user, as discussed in the [NetSPI’s PowerHuntShares blog](https://www.netspi.com/blog/technical-blog/network-penetration-testing/network-share-permissions-powerhuntshares/#2).

> In short, from a remote user perspective, network share permissions (remote) are reviewed first, then NTFS permissions (local) are reviewed second, but the most restrictive permission always wins regardless.
> 

![NTFS vs ACL in SMB shares](/assets/pentest/introducing-sharefinder/image.png)

The issue with **NetExec** and **SMBmap’s** implementation (for at least the longest time) was that there was an instance where you would have write permissions, but not delete permissions. So this could lead to times in which randomly named files were written to hundred of shares and couldn’t be deleted… Leaving client networks a mess. And we cannot determine the exact permissions used by our user credentials to access these shares.

But, later when I chose Go as the language for the tool, I found out that existing libraries for interacting with the SMB protocol are very underdeveloped in terms of the ability to interact with SD.  Because of this, I wrote the current implementation using **NetExec** as an example, where reading is checked by the ability to fill the directory of the share, and writing is checked by creating/deleting a file. So, Implementation via SD remains as a big task to solve, as it has to complete the library that is used to interact with SMB.

## Available modules

At the moment of writing, I’ve developed a tool that provides checks for anonymous (`anon`) and authenticated (`auth`) access to shares and their enumeration. Also, there is a `hunt` module to search targets in Active Directory domains. We’ll review them later.

You can see a list of global flags available in the tool on the screenshot below.

![sharefinder help menu](/assets/pentest/introducing-sharefinder/image1.png)

### Anon

`anon` module stands for **Anonymous** check. It tries to get a Guest access by generating a random username and using it to access shares on hosts.

The target is provided as a network range (192.168.0.1-254) or a filename to input targets from file. The `--list` option is used to list shares that were identified as readable, `--exclude` option provides an ability to exclude shares from listing in output.

![sharefinder anonymous module](/assets/pentest/introducing-sharefinder/image2.png)

### Auth

`auth` module stands for **Authenticated** check. It tries to access and enumerate shares by using credentials provided by the user. 

This module requires a user credentials and a target. Target and other flags are processed the same way as in `anon` module. 

![sharefinder authenticated module](/assets/pentest/introducing-sharefinder/image3.png)

### Hunt

`hunt` module stand for **Hunting for targets** check. It automates the process of identifying available targets in Active Directory networks and then scans the targets for available SMB shares. The process is below:

1. Take the user credentials and domain controller IP address
2. Try to get computer objects in Active Directory, extract **dNSHostName** attributes
3. Resolve the hostnames with domain controllers DNS server
4. Scan resolved hosts for opened port 445 (SMB)
5. Enumerate shares with user credentials

Currently this module works only for single domain specified in user credentials, but search forest feature is planned. 

![sharefinder hunting module](/assets/pentest/introducing-sharefinder/image4.png)

## TODO

Some features are developed at the time of writing this post, but there is a lot of things to do to improve the tool. I will provide a list of things I plan to implement.

- HTML output
- Recursive list shares
- File/directory search through shares
- Proxy support
- Support for hashes instead of password
- Kerberos support
- Search forest feature
- Null session checks
- Windows versions check
- Guest/admin checks
- Fix bugs

Also, there is a lot of opportunities to expand the tool’s functionality and unlock its full potential. For example, I think it is possible to include checking for SMB coerce attacks and SMB vulnerabilities as separate module of the tool.

I would be very grateful for new ideas and identified bugs in the tool. You can leave them on the [Issues page on GitHub](https://github.com/vflame6/sharefinder/issues). It would be a great contribution.

## Conclusion

In this post I’ve presented a new tool to enumerate SMB shares, its functionality and plans to improve it. Also, we’ve discussed several problems in developing tools like this and ways to solve this problems.

You can find the tool on my GitHub - [https://github.com/vflame6/sharefinder](https://github.com/vflame6/sharefinder).

Thank you for reading, I hope it was useful for you ❤️

## Resources

- [https://github.com/Pennyw0rth/NetExec/blob/main/nxc/protocols/smb.py](https://github.com/Pennyw0rth/NetExec/blob/main/nxc/protocols/smb.py)
- [https://github.com/CroweCybersecurity/shareenum](https://github.com/CroweCybersecurity/shareenum)
- [https://github.com/NetSPI/PowerHuntShares](https://github.com/NetSPI/PowerHuntShares/blob/main/PowerHuntShares.psm1)
- [https://github.com/jfjallid/go-smb](https://github.com/jfjallid/go-smb)
- [https://github.com/jfjallid/go-shareenum](https://github.com/jfjallid/go-shareenum/blob/main/main.go#L184)
- [https://pkg.go.dev/github.com/go-ldap/ldap/v3](https://pkg.go.dev/github.com/go-ldap/ldap/v3)
