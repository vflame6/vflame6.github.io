---
layout: post
title: My OSCP Journey
category: Blogging
tags: offsec certifications learning
date: 2024-03-03 10:00 +0300
---

![OSCP Certificate](/assets/certifications/OSCP-Certificate.jpg)

Hi! In this post I want to share my OSCP journey with you. I've passed it with my first attempt in July, 2023. Now I study for the OSEP exam and I want to refresh and review some thoughts on OSCP.

# The Course

I've enrolled in an updated version (2023) of the [PEN-200 course](https://www.offsec.com/courses/pen-200/). They removed buffer overflows topics and added some information about Active Directory environment and working with it. I think it is a good change and makes the course and the exam more suitable to modern environmnents and applications.

You can view the full syllabus on the course page. The main topics now are common web application attacks, privilege escalation, pivoting and Active Directory environments. There are course text, videos and exercises to study, and then there are challenge labs to consolidate your knowledge. The challenge labs even provides an **exam examples** challenges.

The course is made by pentesters for pentesters. I mean here that it contains a lot of information, that can be used in real job. And it is written in short-form without useless information just for make the text bigger. Also, text redactors work is very cool. It is really easy to read and understand without translation to my native language.

## Prepare for the Course

The course is really enough to pass the exam in my opinion. But it can be easier for you with some preparation:

1. **Get familiar with Linux and terminal**. [OverTherWire's Bandit](https://overthewire.org/wargames/bandit/) CTF game is a cool starting point for that.
2. **Get familiar with Kali Linux**. There is an interesting [Kali Linux Revealed](https://kali.training/) course by OffSec.
3. **Get familiar with Python Scripting**. There's a lot of materials for Python language on the Internet.

After that, try to do all available easy and medium machines on [HackTheBox](https://www.hackthebox.com/) platform. I know it is a difficult task to do "from scratch", but it is important to master the googling skills to solve your tasks. You will learn by doing the basics and will get familiar with tools.

## Notes

The most important part of the course is your notes. The OSCP is not about learning the theory. It is about practice and doing the job. And for that reason you don't have to remember all the stuff and be able to reproduce it letter-by-letter. You have to reproduce a set of processes you've learned on the course. That's why you have to take notes about these processes: commands, what do they do, important flags.

The most ideal situation for you is to create a list of **easy-to-search** notes describing each process that you learn. For example, you want to port forward your local port to remote host's port with SSH. You just search for the note with that specific command and do the copy-paste. Create several cheat sheets for each topic and make them useful and understandable for you. 

The thing here is to just type a shortcut to search for specific note or headings in the note. The [Obsidian](https://obsidian.md/) and [Notion](https://www.notion.so/) support that feature. I prefer Notion for its cloud synchronizing functions, but it's formatting features are less comfortable than pure Markdown in Obsidian.

## Take Your Time

I've purchased a single Course & Cert Exam Bundle with 90 days of lab access and 1 exam attempt. And this was enough for me to take the whole course and to complete all challenge labs in 2.5 months. BUT I've really spent a lot of time at every week to do my best at this course. I would think of it like 20 hours per every week. Most of the time on weekends. 

My learning sessions were about 2-4 hours per each one. This course is not about "learn small things" with 30 minutes every day. Each learning session has a big topic to learn and you have to setup your VM, VPN, handlers, etc... every time. I've decided to arrange a time for these sessions and that's worked for me. 

## Mindset

The first thing that OffSec teaches you is the mindset. They want you to try your best in solving your problems. You have to think that every task is not impossible to do. You just need to think, look or enumerate more and more and more. They wrote a cool [blog post about Trying Harder](https://www.offsec.com/offsec/what-it-means-to-try-harder/) and I recommend you to read it.

In my opinion, you have to build a mindset on consistency and creativity. Try to answer these questions:

1. What do you have now? What you want to do?
2. How can you do the thing with stuff you have now?
3. Maybe you need something more? What else you can look for?

This often called **Thinking Outside the Box**. For me it is an iterative process about consistently enumerating what you have now and what else can be done. It is an ideas generating process. I've noticed that it's easier to do with some experience and fundamental knowledge about how do things work.  

## Community

There were a lot of struggles during the course and especially with the labs. And while the rules are blocking the people to share the solutions, it is not forbidden to **navigate** students to the right direction with their problems.

OffSec has their own Discord channel and you can connect to it from your learning portal. They're building a powerful community of students, providing the chats for every single course and even non-technical things like games. And students there can ask questions about their problems with the course exercises or challenge labs. 

The requirement here is to provide enough information about **what you did before** you asking the question. The students can answer to you and give you more directions to look at your situations. But it is important to do it without spoilers.

Also, I've noticed that a lot of my questions (or all of them) were asked before me right in the discord. So, right after I've decided that I need help with what to do next I just hopped in Discord's messages search. I think OffSec's Discord **community is a legal cheat code** for the course.  

# The Exam

The OSCP certification exam simulates a live network in a private VPN, which contains a small number of vulnerable machines. **You have 23 hours and 45 minutes to complete the exam**. Once the exam is finished, you will have another 24 hours to upload your documentation.

You are NOT allowed to use automatic exploitation tools like Metasploit. You can use Metasploit once on one exam machine, but I think it's more useful to just forget about it and to the exam on your own. I think it is easy to forget some specific restriction and just fail the exam because of inaccuracy.

The exam contains 3 independent targets and an Active Directory set with 2 clients and 1 domain controller. Each independent target gives you 10 points for low-privilege access and 10-points for privilege escalation. The AD set gives you 40 points but only if you compromise and entire domain. You must achieve a minimum score of 70 points to pass the exam. It is possible to achieve a maximum of 100 points on the exam.

## Documentation 

You have to write a **professional penetration testing report** after the exam. The report has a requirement to be **reproducible** by technical staff without specific knowledge. And that's why it is really important to document every single step while taking the exam. Also, it is important to document every exploit code you use, or just provide the links if you don't modify it. The methodology here is:

1. Scanned the host
2. Found that and that
3. Searched for exploit for that
4. Modified the exploit code and used it
5. local.txt
6. Enumerated the host for privesc
7. Found the vector
8. Exploited the vector
9. proof.txt 

OffSec provides you suggested documentation templates for the report:

- [Microsoft Word](https://www.offsec.com/pwk-online/OSCP-Exam-Report.docx)
- [OpenOffice/LibreOffice](https://www.offsec.com/pwk-online/OSCP-Exam-Report.odt)

You can use any template for your documentation, but ensure that it looks clear and at least has all the sections provided in suggested templates. The most popular documentation template for OffSec exams is [Offensive Security Exam Report Template in Markdown](https://noraj.github.io/OSCP-Exam-Report-Template-Markdown/), which allows you to write your report in markdown and then generate a formatted PDF documentation report. It's a good idea to use it and don't lose your time on MS Word's formatting, whitespaces and linefeeds. 

## Schedule

The schedule time for the OSCP exam can be really flexible. The important here is to schedule your exam for the **right time** specificly for you. For example: I prefer to start work at 8-9 AM, so I did schedule the exam on 9 AM.

Also, ensure that you have **at least one day off** before the exam. It is important to take just one day to relax and prepare your brain and body for really hard day. Just don't try to "make big things" right before the exam, or your energy will be low on the exam, and the success rate will be decreased. I did take a day off at my job to take the day off on Saturday and do the exam on Sunday to Monday.

## Read the FAQ

In my opinion, the OSCP is the first certificate you get with OffSec learning. That's why it has the biggest [Exam Guide](https://help.offsec.com/hc/en-us/articles/360040165632-OSCP-Exam-Guide) in their help section. 

I really recommend you to read EVERY page of it, just like you do with the course and labs. You can find an exam's stucture, requirements, bonus points and additional required information here. That's why it's so important. I've noticed that with OffSec it's really helpful to process all information they provide to you. They did a great job to ensure that you're **ready** for the exam.

## Get Bonus Points

It is possible to get 10 bonus points on the exam while taking the course. The requirements are:

- **80%** of the correct solutions for **every** module's lab in the course
- Submit 30 correct **proof.txt** hashes for the 30 challenge labs

These requirements are really easy to fit when you do the whole course. I think this is an another point by OffSec to do everything. You can use these bonus points and be able to skip an AD set or 2 independent targets on the exam. But I recommend to try to do all targets without exceptions, even with bonus points.

## My Exam

I did schedule the exam 1 week after the whole course and labs were completed. I've connected to the proctoring software right before the exam, checked everything with proctor and started the exam.

My plan was to do the Active Directory set first, and then try to do single machines. The important here was to take as much notes as I can to provide full step-by-step report after. I did the AD set, rooted 2 single machines and got a local.txt on the last single machine. It took 15 hours for me to complete the exam. 

After the exam, I've started a 24-hour timer for my documentaion and just slept. On the next day, I did my report just by copying and pasting my exam notes. I think that big notes increased my flexibility with the report, so I was able to provide step-by-step documentation in my report.

# Tips and Tricks

## Make the Wiki

OSCP is a good start to make your own pentest wiki, if you didn't before. As I mentioned in **Notes** section, you will learn the processes, you take notes for them and then you can create a big self-wiki. As your skill set grows, your wiki will grow with them and you will able to store and quickly reproduce a lot of things. You wouldn't have to re-learn the things, just look at your wiki to remember if needed. 

I use Notion's [Wiki Template](https://www.notion.so/templates/team-wiki) for that. But you can create your own from scratch or find something that fits your needs. Look at [HackTricks](https://book.hacktricks.xyz/welcome/readme) for some inspiration about how it should look.

## Pay Attention

After OSCP I've started worrying about attention. While doing the exam I’ve noticed that I was not touching my phone or accessed social media for 1+ day. The focus was incredible and there was no world around me. Just me and the job. Great feeling. I think it is a big problem in today’s world to make yourself clear all useless things from your attention and just focus on the work. 

I think the attention problem with today's social medias is really noticeable. After the exam I’ve really started thinking about clearing the desktop, drop all social medias and just turn off my phone for a while or set a “Do not disturb” mode.

## Health

It is important to prepare your mental and physical health to work constantly, solve the problems and learn new things. It is a hard process and you have to make your body work with yourself together. Somebody calls it a **productivity** and it's important to make yourself increase it within reasonable limits. 

**Remember that its just a game**. Don't overthink the tasks and don't make them "impossible" to solve. Don't make yourself feel bad about the difficulty and just **try harder** :).

**Sleep well**. You don't have to use energy drinks and affect your health to do the job. Just sleep. 6-8 hours per day, find your own schedule. You'll never get your brain work without sleeping.

**Take breaks**. Especially if you're stuck with a problem for 2+ hours without any idea what to do. Go relax, eat or walk for 30-60 minutes. Your brain will continue work in the "background mode". Then, you will return with a fresh view and energy to solve the problems.

**Don't forget to eat**. Your brain do burn your energy just like you do when you do physical exercises, and you have to fulfill your body with it by eating. It's a good idea to make an eating schedule and your body will just remember when do you eat and control your hunger.

# How does OSCP affect the Job?

In 2023-2024 the OSCP is really hyped and it is included in many non-intern job requirements (probably in interns too). So I think it is important to discuss how it affects the day-to-day pentest job. 

## Job Seeking after OSCP

My experience is based on russian job market, so the situation can be really different from that with worldwide companies.

So, after obtaining the OSCP I've updated my resume and LinkedIn profile. There was an experience from my job and I've added the new certification. And that was enough to increase the number of HRs contacting me to offer an interview for junior-middle pentest positions.

I think the OSCP has really high impact on the job seeking process, because of HRs screening the candidates. The certification makes you look special on the first step of the candidates selection. OffSec's certificates are known all around the world and they're a great way to improve your resume.

## Real World Pentests

**The OSCP teaches you the basics**. It makes you familiar with tools, vulnerabilities, software and operating systems. But there is nothing special, which will make you "hack the world".

In real projects with corporate networks there are a lot of implemented defense mechanism, like antiviruses, Intrusion Detection/Prevention Systems, Endpoint Detenction & Response (EDR) and so on. These mechanisms will block your interaction with the systems and make even vulnerable systems unexploitable. 

That's why I encourage you to continue your learning after the OSCP. I think to do the real job now its really important to learn about using C2 servers (at least get familiar with post-exploitaion with Metasploit), in-memory payload execution and bypassing techniques. And it is important to notice a big switch to use web applications everywhere, so it is really important to dive deeper in web vulnerabilities. 

# Conclusion

In this post I've shared with you my journey with the PEN-200 course and the OSCP certification exam. It was a great journey and I'd like to thank the OffSec for their incredible job on making their course. I hope to take new courses/exams as soon as I can to learn new things and take new challenges on labs and the real job. 

Thank you for reading, I hope it was useful for you ❤️
