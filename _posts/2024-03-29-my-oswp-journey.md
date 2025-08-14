---
layout: post
title: My OSWP Journey
category: Blog
date: 2024-03-29 10:00 +0300
---

![My OSWP Certificate](/assets/certifications/OSWP-Certificate.jpg)

Hi! In this post I want to share my OSWP journey with you. I've passed it with my first attempt in February, 2024. It was a small journey and I want to review it and provide some tips here.

# The Course

Wireless Attacks (PEN-210) introduces learners to the skills needed to audit and secure wireless devices and is a foundational course to gain more skills in network security. Learners will identify vulnerabilities in 802.11 networks and execute organized techniques.

The course covers these topics:

- IEEE 802.11 standard and basics of Wireless Networks
- Foundation of configuring and working with wireless networks in Linux
- Reconnaissance in wireless networks
- Attacks on wireless security solutions
- aircrack-ng suite to perform the attacks
- Frameworks and automatic tools to perform wireless attacks

Refer to the [PEN-210 course page](https://www.offsec.com/courses/pen-210/) for more informaiton.

## Prepare for the Course

The course is well-structured and has a lot of information about Wireless Networks, but you have to learn some basics before you apply for it. I think the course is enough to pass the exam with these preparations:

- **OSI Model** and **TCP/IP Fundamentals**. You have to understand the basics of the networking. Check free HackTheBox Academy's module [Introduction to Networking](https://academy.hackthebox.com/module/details/34)
- **Familiarity with Linux**. It is useful to understand the Linux to set up Wi-Fi attacking environment later. The [Kali Linux Revealed](https://kali.training/) course is a cool preparation here
- **Work with TMUX**. Check [this note](https://gist.github.com/davydany/d33f4b5e19eab6b805b045b91d3cf858) to get a basic understanding of working with TMUX. You can also use [screen](https://gist.github.com/jctosta/af918e1618682638aa82)

During my learning journey, I've faced some troubles to set up my wireless card with a Kali Linux virtual machine in VMWare Workstation. I was unable (or just didn't want) to resolve the issues correctly and quickly, so I decided to do it simple way and rebooted my laptop in **Live USB Kali Linux**.

My recommendation here is to do the same. Use Kali Linux Live USB to avoid any VM-specific problems. Set up a persistence storage in your live USB to store your data and progress. You can learn how to set up live OS with persistence on [Kali Linux documentation](https://www.kali.org/docs/usb/usb-persistence/).

## Setup a Lab Network

The course requires you to set up your own lab environment to do exercises. The requirements are:

1. Wireless card which is injection-capable. OffSec reccomends **Alfa AWUS036NHA**.
2. Wi-Fi Access Point which can be configured to use several security mechanisms (WPA/WPA2, WPA Enterprise). OffSec recommends **NETGEAR AC1000 (R6080)** or **Linksys WiFi 5 Router Dual-Band AC1200 (E5400)**.
3. Victim device to connect with the target access point. It can be your phone or laptop. I recommend use a device like laptop because of capabilities of configuration.

The course exercises will require you to set up the lab network on your own for each section. It is useful to know the basics about how each security mechanism is configured. You can find patterns and the most possible administrator's mistakes by doing that. 

I think it is possible to pass the exam without buying stuff and setting the lab. But the question here is what do you expect from the course? If you just want the certification, go on. But if you want to really learn something practical that you could use in real job, get the stuff and do the exercises. 

# The Exam

The OSWP certification exam simulates a "live wireless network", which some of the scenarios may contain traffic to the Internet and similar AP’s client behavior in a real network.

You have **3 hours and 45 minutes** to complete the exam. After the exam, you have 24 hours to upload your exam report.

There are **three** network scenarios available to attack. Only one scenario can only work at a time. You will only pass the exam if you are able to complete and obtain proof.txt on two network scenarios. One of the scenarios will be **mandatory** to complete.

You will be provided with an SSH/RDP access to Kali Linux machine. The machine has an injection-capable wireless card and is placed near victim access point and its clients.

## Exam Resctrictions

Be aware of the exam restricions:

> The use of automated tools like wifite, wifiphisher and similar are not allowed. In addition, AI chatbots such as ChatGPT, YouChat, and similar are not allowed.

The easier way to understand these restrictions is to only use aircrack-ng suite on the exam. It is enough to do all attack scenarios.

## Prepare for the Exam

The first thing you have to do is to **read carefully** the [OSWP exam guide](https://help.offsec.com/hc/en-us/articles/360046904731-OSWP-Exam-Guide). It will give you an understanding of what to expect from the exam.

The second thing is to **prepare cheatsheets for every attack**. Be aware that you don't have much time, so you have to reproduce them very quickly. Also, OffSec wants you to be able to do all your stuff in terminal, even connecting to the cracked networks. So it is crucial to prepare cheatsheets with commands and configurations to connect to different networks.

## Documentation

While doing the exam, document each step of your attacks with commands in text and screenshots of the results. The mandatory here is to take screenshots of the cracked key and the obtained flag. But I recommend to document every step performed to compromise the network. It is easier to write a report with every step covered without blind zones of your attack, which can nullify your exam points.

It is recommended to use [suggested documentaion templates](https://help.offsec.com/hc/en-us/articles/360046904731-OSWP-Exam-Guide#suggested-documentation-templates) to document your exam. Review them to understand the structure of the report OffSec wants to see.

There is a pattern for each access point:

1. Summary of the attack from reconnaissance to cracking the network key
2. Proof section with cracked network key and contents of proof.txt file
3. Screenshots for cracked network key and curl request for proof.txt file
4. Steps to reproduce the attack

The fourth section is where you have to document your steps from reconnaissance to obtaining the proof.txt file. For each step I've used this structure:

1. Describe what is done in this step
2. Entered commands in text with code formatting
3. Screenshot of step's results if possible/needed

For code formatting I use Microsoft Word's [Easy Code Formatter](https://appsource.microsoft.com/en-us/product/office/wa104382008?tab=overview) extension. It formats the text in different themes and languages syntax.

With these tips I was able to make a reproduceable guide on each scenario.

## My Exam

I've scheduled my exam one week after the course was done. I've taken time to review my notes and prepare cheatsheets for the exam. Also, I've taken 1-day off before the exam to chill and prepare myself to work hard. At the time of the exam, I've connected to the proctor's session 15 minutes before the exam and done preparations. After that, my exam has started.

My plan was to connect to the machine with RDP and then do the job in the terminal, but the RDP-session was working really slow and forced me to use SSH instead. I've used TMUX session to use 2-3 shells at the same time. After the exam I've realized that the SSH connection is more than enough to do the job.

The methodology for each scenario was pretty simple:

1. **Reconnaissance**. Identify network name, it's parameters and security mechanism
2. **Attack**. Just open a prepared cheatsheet with set of commands and execute the attack
3. **Connect**. And again just open a cheatsheet with set of commands and connect to the network
4. **Flag**. Gain proof file from the http://192.168.1.1/proof.txt

I've solved first 2 scenarios in one hour and stucked with the last for 2 hours because of tools were not working properly. But after 3 times of repeating the commands I was able to do the last scenario and sucessfully ended the exam.

# Tips and Tricks

## PEN-210 Discord Channel

OffSec provides a discord channel for every student. Check discord channel for PEN-210 course. Like with OSCP, the discord channel already has answers for all possible questions (without spoilers) for your course and exam journey. I recommend you to read it before the exam to get clear understanding of what to expect on the exam.

## Review Existing Cheatsheets

There are several well-prepaired cheatsheet for OSWP exam and pentesting Wi-Fi networks on the Internet. I've mention here the ones I did use in my journey. Big respect for authors for sharing.

- [Wi-Fi-Pentesting-Cheatsheet](https://github.com/dh0ck/Wi-Fi-Pentesting-Cheatsheet). Obsidian vault with cheatsheets for different scenarios. I think it can be used to pass the exam without any modifications.
- [WiFi Hacking Cheatsheets](https://github.com/koutto/pi-pwnbox-rogueap/wiki). Interesting guide for Wi-Fi pentesting with Wi-Fi theory and example commands. Also, there is a cool mindmap for Wi-Fi pentesting. I think this one can be used in real work.

## Prepare your Cheatsheet

As mentioned before, **prepare cheatsheets for every possible task**, like attacking specific Wireless Security mechanism or connecting to the network from command line.

You will have a lot of information during the course and you don't need to document everything. Just divide the course in topics and make notes about things you want to remember later. I prefer to make it simple and just make a big note for each course topic and then take my notes.

I prepare my own cheatsheets in 2 steps: at first, I do the course and take notes about things that I think will help me understand the topic later and specific code/commands for solving problems. Once the course is done, I review my notes and make several cheatsheets about each topic/problem to solve. The stucture there is like `topic/problem` - `solution` pairs. Then I can just search specific things by headings. 

After the course and exam were done, I reviewed my notes and cheatsheets to update my offensive security wiki to use that information in my future work.

## Other Tips

The basic of all OffSec courses is the Mindset. And tips for these course and exam are the same as for the OSCP. Refer to [My OSCP Journey blog post](https://vflame6.github.io/posts/my-oscp-journey/) here for more tips on OffSec's certifications.

# Conclusion

In this post I've shared with you my journey with the PEN-210 course and the OSWP certification exam. It was a great journey and I'd like to thank the OffSec for their incredible job on making their course. I hope to take new courses/exams as soon as I can to learn new things and take new challenges on labs and the real job. 

Thank you for reading, I hope it was useful for you ❤️
