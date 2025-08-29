---
layout: post
title: You received a NetNTLMv1 hash. What next?
date: 2025-08-29 01:00 +0300
category: Pentest
description: Exploring several ways to abuse NetNTLMv1 in corporate networks.
---

Some time ago, during one of my job interviews, I was asked: **“You received a NetNTLMv1 hash. What can you do with it right away?”**

![NetNTLMv1 hash in Responder](/assets/posts/pentest/you-received-a-netntlmv1-hash-what-next/netntlmv1.png)

On a whim, I replied, “Brute force it or send it to crack.sh to search their pre-compiled tables.” To which they replied, “What else?” And I didn't know 😅. Actually, because of this situation, I went to figure out what I can do with NetNTLMv1.

## NetNTLMv1 attacks

### **Well-known challenge**

Challenge is used for authentication via NetNTLM. This is a number that the client must encrypt with its key. In this case, the key is the NTLM hash of the user's password, which passes authentication.

In NetNTLMv1, only the challenge and NTLM hash pair is used to generate the encrypted challenge. This makes it possible to create an attack vector where the same challenge is always used for all clients. Only the second element, the NTLM hash, will differ in all cases. This allows us to prepare a large number of NetNTLM password hashes with a pre-set challenge. The community chose the number **“1122334455667788”**.

How can this be implemented? We set our prepared challenge in the well-known [Responder](https://github.com/lgandx/Responder). The default path to the config in Kali is: `/etc/responder/Responder.conf`.

```
...
HTTPS = On
DNS = On
LDAP = On

; Custom challenge.
; Use "Random" for generating a random challenge for each requests (Default)
Challenge = 1122334455667788

; SQLite Database file
...
```

Next, we launch and specify the `--lm` flag to forcefully lower the victim's authentication mechanism level. If that doesn't work, you can try again with the `--disable-ess` flag.

```bash
sudo responder --lm -I eth0 -A
```

All that remains is to capture the NetNTLMv1 hash of the user's password again. After that, we have two options: either brute force it ourselves or go online for help from the community.

Tools such as [crack.sh](https://crack.sh/get-cracking/) (currently unavailable) and [shuck.sh](https://shuck.sh/get-shucking.php) are available online, which are essentially ready-made infrastructures for cracking such hashes. For example, [crack.sh](https://crack.sh/) uses a system of 48 FPGAs configured to crack such hashes. Such a system provides a speed of 768,000,000,000 keys per second.

BUT. **The use of online services creates leakage risks for both the customer and the contractor**, since we essentially have to send valid credentials from the customer's infrastructure somewhere online. No one knows what happens to them on the other side. Using such services is at your own risk. The best solution would be to have your own infrastructure for such tasks.

As a result, we obtain the NTLM hash of the user's password, which can be used in Pass-The-Hash and Overpass-The-Hash attacks on network services.

### NTLM relay (SMB → LDAP)

As is well known, it is impossible to perform an NTLM relay attack from SMBv2+ to LDAP, since SMBv2 and higher protocols require a signature via a session key. This signature cannot be removed, otherwise a Message Integrity Code (MIC) validation error will occur. Where, how, and to what extent relaying is possible is well described in [an article by hackndo](https://en.hackndo.com/ntlm-relay/).

It turns out that using the NetNTLMv1 protocol is an exception to the request signature rule, as the protocol does not support the MIC calculation mechanism. This allows you to perform an NTLM relay attack from SMB to LDAP, for example, via [ntlmrelayx.py](https://github.com/fortra/impacket/blob/master/examples/ntlmrelayx.py) from the impacket package. It is also implemented as an exploitation of the [CVE-2019-1040 (Drop the MIC)](https://dirkjanm.io/exploiting-CVE-2019-1040-relay-vulnerabilities-for-rce-and-domain-admin/) vulnerability, through the `--remove-mic` option. Example command:

```bash
ntlmrelayx.py -t ldap://<other_dc_IP> -smb2support --no-dump --no-da --no-acl --no-validate-privs --remove-mic --shadow-credentials
```

The possible vectors for developing an attack will depend on whose account we can force to log in to our relay server. The main vectors for attack are:

- Dump domain info (Default);
- Shadow credentials (`--shadow-credentials`);
- Resource-based constrained delegation (`--delegate-access`);
- Escalate privileges of the user (`--escalate-user`);
- LDAP-shell (`--interactive`).

In the case of RBCD, we will overwrite the **msDS-AllowedToActOnBehalfOfOtherIdentity** attribute and be able to obtain a Silver Ticket for the victim's account services using the S4U2Proxy mechanism. 

In the case of Shadow Credentials, we will overwrite the **msDS-KeyCredentialLink** attribute and be able to obtain a certificate for authorization with the victim's account, and then obtain the NTLM hash from this account using the [UnPAC-the-Hash] attack (https://www.thehacker.recipes/ad/movement/kerberos/unpac-the-hash).

So, that's the answer to the question from the beginning of the post. There are a lot of ways to develop the attack, but I tried to cover the main ones here.

## **Protection against NetNTLMv1**

To protect against NetNTLMv1 in the domain infrastructure, you need to roll out a group policy with the following settings: under `Computer Configurations -> Policies -> Windows Settings -> Security Settings -> Local Policies -> Security Options → Network Security: LAN Manager authentication level`. Set the value to Send NTLMv2 response only. Refuse LM & NTLM.

Or, for isolated machines, go to the registry: under `HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Control\\Lsa`, find the `LmCompativilityLevel` key and set the DWORD value to 3 for the client (Send NTLMv2 response only) or 5 for the server (Send NTLMv2 response only. Refuse LM & NTLM).

## Conclusion

Thus, when NetNTLMv1 is used in the infrastructure or we can force the victim to lower the level from NetNTLMv2, we can use this not only to recover the user's original password, but also for NTLM relay attacks.

Thank you for reading, I hope it was useful for you ❤️
