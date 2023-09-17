---
layout: post
title: Optimize Hash Cracking
category: Tools
tags: hash brute-force
date: 2023-09-01 09:12 +0300
---

# Introduction

Hi! In this post I want we will explore some ways to optimize hash cracking. We can do it in many ways, for example by optimizing our cracking algorithms or improving hardware part. Our first questions are how many time do we have to crack the hashes and what type the hashes are? Answers for these quiestions help us choose the right technique and hardware sets. Let's explore our possibilities with exaples. 

It is useful in real penetration tests/red teams to try to optimize long processes, like password hashes cracking, because they are very time-consuming. And the time is very important in, for example, 2 week projects, when you don't have enough time or enough CPUs/GPUs to brute-force all possible 8-9-10-characters with special symbols.

# Creating Dictionary Masks

The first way to optimize brute-force attacks is to think about users of the target systems. The target may invole its own password policy with complexity and expiration requirements. And we can use this information to find a way to attack the passwords. Real users are always trying to make complex things simplier, and we can find patterns of matching-criteria passwords in victim's systems. 

Especially this is working when the target has too strong password rotation policy. For example, users must change their password at least one time in 30-60-90 days. The users will just start rotate their favorite 3-4-5 password combinations to make their work comfortable. Nowadays, even [Microsoft recommends](https://learn.microsoft.com/en-us/microsoft-365/admin/misc/password-policy-recommendations?view=o365-worldwide) against password rotation policies.

For example, target's password policy requires at least one uppercase character and 1 digit. It is common to see passwords with first uppercase letter several lowercase letters and digit or digits at the end of string. So, we can optimize our brute-force to set the first letter to uppercase and lowercase/digits at the end of the string. Our theory is to get the passwords like `Orange66` or `Abcdefg0`.

We will use hashcat mask model here. 1 character in the mask sets by using `?num` syntax. The num is set with characters. Time to crack is computed with cracking speed of 100 MHs per second.

| **Characters**                                    | **Length** | **Mask**         | **Possible passwords**                        | **Time to crack** |
|---------------------------------------------------|------------|------------------|-----------------------------------------------|-------------------|
| 1 - Uppercase, lowercase, digits                  | 8          | ?1?1?1?1?1?1?1?1 | 62x62x62x62x62x62x62x62 = 218 340 105 584 896 | **25.3 days**     |
| 1 - uppercase; 2 - lowercase; 3 - lowercase, digits | 8          | ?1?2?2?2?2?2?3?3 | 26x26x26x26x26x26x10x10 = 30 891 577 600      | **5.2 minutes**   |

Sometimes time economy is incredible. This theory could save us a lot of time if it worked. Let's 

**Hashcat**

[Hashcat mask attack documentation](https://hashcat.net/wiki/doku.php?id=mask_attack)

Mask attack with specified combinations:

```bash
hashcat -m 1000 -a 3 -1 ?u -2 ?l -3 ?l?d hashes.ntlm ?1?2?2?2?2?2?3?3
```

You can even create a file with various types of masks and then use the file in Hashcat. You can see an example below.

The general format of 1 single line in the .hcmask file is as follows:

```plaintext
[?1,][?2,][?3,][?4,]mask
```

Example file example.hcmask:

```plaintext
?u,?l,?l?d,?1?2?2?2?3?3
?l,?u,?u?d,?1?2?2?2?3?3?3
?l,?l,?u?d,?1?2?2?2?3?3?3
?d?l,?1?1?1?1?1?1?1?1
```

Mask attack with mask file:

```bash
hashcat -m 1000 -a 3 hashes.ntlm example.hcmask
```

**JohnTheRipper**

[John The Ripper MASK documentation](https://github.com/openwall/john/blob/bleeding-jumbo/doc/MASK)

Mask attack with pre-difened charset `?a` - full 'printable' ASCII.

```bash
john --format=raw-md5 --mask='?a?a?a?a?a?a?a' hash.txt
```

# Using Wordlists

Sometimes we have to do a dictionary-based attack, and the most improtrant thing here is to find, choose or generate the right dictionary. Then, we can improve our wordlists to make them more effective, or make them even bigger by using rules or combining them with masks. 

## Find Wordlists

There are some online resources on the Internet with collections of wordlists, which can be used to hash cracking. One popular website is [WEAKPASS's wordlists](https://weakpass.com/wordlist). It contains an all-in-one wordlist with almost 330 `gigabytes` (!) of data with `28 330 702 856` words. 

![Wordlists on weakpass.com](/assets/tools/optimize-hash-cracking/weakpass_wordlists.png)

## Generate Wordlists

**Generate from masks**

We can use JohnTheRipper with `--stdout` option or [Hashcat's maskprocessor](https://github.com/hashcat/maskprocessor/releases/) to generate a wordlist with specified mask.

```bash
# JohnTheRipper
john --mask='?d?d?d?d' --stdout
john --mask='8905143?d?d?d?d' --stdout > beeline.txt

# maskprocessor
mp64 pass?d
```

![maksprocessor example](/assets/tools/optimize-hash-cracking/maskprocessor.png)

**Parse websites**

It is possible to use any website to generate a wordlists. For example, we can generate a dictionary by using words from target's website.

In this [medium article by @woFF](https://medium.com/@woff/coding-a-custom-wordlist-generator-with-chat-gpt-ca2c60c41a8d) author coded a Python script to get text from URLs with specified search parameters from Google Search API. It makes a search via Google Custom Search JSON API, retrives 100 result's URLs, visits the URLs and extracts the text from them. 

There is an automated tool created by Robin Wood. [CeWL - Custom Word List generator](https://github.com/digininja/CeWL) is a ruby app which spiders a given URL to a specified depth, optionally following external links, and returns a list of words which can then be used for password crackers.

Example usage:

```bash
# -m - min word length (default: 3)
# -d - depth to spider to (default: 2)
# -w - write output to file
cewl -m 6 -d 1 -w https://example.com
```

![cewl example](/assets/tools/optimize-hash-cracking/cewl.png)

**Online generators**

WEAKPASS has its own [online password generator](https://weakpass.com/generate). It can generate a wordlist based on specific input data. For example, by entering an `Acme.corp` you will receive a list of possible passwords like `Acme.corp2018!`, `Acme.corp123`, and so on. All data is processed on the client with JavaScript.

![Generator on weakpass.com](/assets/tools/optimize-hash-cracking/weakpass_generator.png)

**AI based generators**

After the Large Language Models (LLMs) boom in 2022, researchers started explore ways to use LLMs in security practice. In current topic it is possible to use them to generate meaningful custom wordlists using tools like ChatGPT.

There are some tools already built like [meaningful-passwords GitHub repository](https://github.com/leafcloudhq/meaningful-passwords) with [blog post on Leafcloud](https://www.leaf.cloud/blog/how-to-use-a-i-to-generate-meaningful-and-secure-passwords) which generates passwords based on the meanings of a list of words using word vectors.

Also, we can train our own AIs to generate meaningful passwords. There is an [ai-passwords](https://github.com/rarecoil/ai-passwords) GitHub repository by rarecoil, which is a collection of password lists in which he has trained various deep learning algorithms to try to come up with passwords. 

This [blog post on arsTECHNICA](https://arstechnica.com/information-technology/2023/04/the-passgan-ai-password-cracker-what-it-is-and-why-its-mostly-hype/) describes the power of PassGAN tool. PassGAN uses a Generative Adversarial Network (GAN) to autonomously learn the distribution of real passwords from actual password leaks, and to generate high-quality password guesses. The tool was introduced in 2017 and was really hyped by the community. You can find [the research here](https://arxiv.org/abs/1709.00440) and the [tool in GitHub repository](https://github.com/brannondorsey/PassGAN)

## Improve Wordlists

There are ways to improve wordlists, when we have founded or generated a base dictionary for our attack.

The Hashcat's attacks names and examples are used here. Our wordlists can be combined with some type of rules, for example, we can use leetspeak (l33tsp3@k) to make a new type of passwords in our wordlist, this attack is called a `Rule-based` attack. Also, we can combine the initial wordlist with mask described above to generate a new set of variants, this is called a `Hybrid` attack. And we can combine 2 wordlists together, which is called a `Combinator` attack.  

**Combinator attack**

[Hashcat's combinator attack documentation](https://hashcat.net/wiki/doku.php?id=combinator_attack)

In the combinator attack built into hashcat (-a 1), two dictionaries are “combined” - each word of a dictionary is appended to each word in another dictionary.

```bash
./hashcat -m 0 -a 1 hash.txt dict1.txt dict2.txt
```

**Hybrid attack**

[Hashcat's hybrid attack documentation](https://hashcat.net/wiki/doku.php?id=hybrid_attack)

For example if your example.dict contains:

```
password
hello
```

The configuration:

```bash
hashcat -a 6 example.dict ?d?d?d?d
```

Generates the following password candidates:

```
password0000
password0001
password0002
.
.
.
password9999
hello0000
hello0001
hello0002
.
.
.
hello9999
```

It also works on the opposite side! 

```bash
hashcat -a 7 ?d?d?d?d example.dict
```

**Rule-based attack**

[Hashcat's rule-based attack documentation](https://hashcat.net/wiki/doku.php?id=rule_based_attack)

Here we explore some simple rules for examples. You can find a full list of functions in the documentation linked above. It is possible to combine them to make cool combinations.

Contents of 123.rule file: 

```
:
u
r$L$O$L
```

The rules used here are:

- `:` for do nothing (passthrough)
- `u` for uppercase all letters
- `r` for reverse entire word
- `$X` for append character X to end

Let's see what how hashcat processes the rules by using a simple word `password`. We can check it with hashcat's `--stdout` flag.

```bash
hashcat --stdout -r 123.rule one_word.txt
```

![Hashcat rules example](/assets/tools/optimize-hash-cracking/hashcat_rules_example.png)

We can use our rule to crack the hash with command below:

```bash
hashcat -m 0 -a 0 -r 123.rule hash.txt wordlist.txt
```

There are some pre-build hashcat rules coming with hashcat's installation. They contain useful basic mutations for words in dictionary. In Kali you can find them in `/usr/share/hashcat/rules/`. Let's try to use one on one simple word `password`.

![Hashcat built-in rules example](/assets/tools/optimize-hash-cracking/hashcat_rules.png)

# Distributed Cracking

It is possible to parallel our hash cracking tasks to several computers. This way can help us when we have access to several machines. The idea is to create a `client-server` model in hash cracking task. So, we have an administrative center, which computes parts of computed hashes numbers and distributes them, and cracking agents, which receives their parts and computes hashes.

An example of such tool is [Hastopolis server](https://github.com/hashtopolis/server) Hashtopolis is a multi-platform client-server tool for distributing hashcat tasks to multiple computers. The main goals for Hashtopolis's development are portability, robustness, multi-user support, and multiple groups management. In this [Medium blog post](https://tomas-savenas.medium.com/distributing-hashcat-tasks-to-multiple-computers-7bb98d8410bd) by Tomas Savenas you can find an example of it's usage.

The image below shows the example of hashtopolis administrative tasks page. [Image source](https://nikita-guliaev.medium.com/clustering-hashcat-with-hashtopolis-for-distributed-cloud-computing-55f964a56804)

![Hashtopolis tasks](/assets/tools/optimize-hash-cracking/hastopolis_tasks.png)

There are some links to other tools which can be used in distributed cracking below:

- [Fitcrack](https://github.com/nesfit/fitcrack). Fitcrack is a BOINC-based hashcat-powered distributed password cracking system.
- [CrackLord](https://github.com/jmmcatee/cracklord). CrackLord is a system designed to provide a scalable, pluggable, and distributed system for both password cracking as well as any other jobs needing lots of computing resources.
- [Hashview](https://github.com/hashview/hashview). Hashview is a tool for security professionals to help organize and automate the repetitious tasks related to password cracking.


# Cloud Computing

Cloud Computing services are really great in power and availability, but they can be really expensive, especially with hard computing tasks like hash cracking. They are useful, when you don't want to make and maintain your own cracking rig.

Usage of Cloud Computing is always makes you think about your budget and if it is worth it. The clouds are very powerful in computing tasks and can be used in distributed hash cracks. But also clouds can make you "burn your money" for useless computing, so be very careful with them. There are a lot of situations, when operators just have forgot to stop their cloud and then got charged for big amounts of money. 

It is really worth to plan and create a scripting for shutdown. It can be just a Bash script to shutdown your cloud machine for cost improvement.  

**Amazon Web Services**

Amazon Web Services (AWS) with their [GPUs configurations](https://docs.aws.amazon.com/dlami/latest/devguide/gpu.html) can be used in our hash cracking. AWSSEVNX made a [step-by-step video guide](https://www.youtube.com/watch?v=heizjC2cGzU) to setup a powerful hash cracking virtual machine. Amazon EC2 [P3 instances](https://aws.amazon.com/ec2/instance-types/p3/) are used in the video.

There is a [ec2hashcat GitHub repository](https://github.com/wrboyce/ec2hashcat) made to to automate the process of password cracking on the AWS Cloud using GPU Instances. It handles the uploading/downloading of files to/from S3/EC2, starting/stopping of instances and running cudaHashcat. The repository was archieved, but there are some forks for it.

**Google Cloud Platform**

Google Cloud Platform (GCP) has its own [Cloud GPUs](https://cloud.google.com/gpu) service. You can check the pricing at [GCP gpus-pricing page](https://cloud.google.com/compute/gpus-pricing). Kacper Bąk described GCP usage with Hashcat for hash cracking purpose at his [Medium blog post](https://53jk1.medium.com/cracking-passwords-with-hashcat-on-google-cloud-platform-66c875d61dd5). When payment is done, the configured machine can be accessed by SSH, or right in browser with `https://ssh.cloud.google.com/...`. 

The image below is an example machine configuration for hash cracking. [Image source](https://53jk1.medium.com/cracking-passwords-with-hashcat-on-google-cloud-platform-66c875d61dd5).

![GCP's example machine](/assets/tools/optimize-hash-cracking/gcp_example_machine.png)

**vast.ai**

You can rent a server with GPUs on [vast.ai](https://vast.ai/). It is a Global GPU Market with a low-cost cloud GPU rental. We can use it to buy GPU rigs for our hash cracking needs. Price for RTX 4090 is $0.376 per hour. It is not necessary to rent the most expensive/powerful rigs, but it's depends on your tasks. 

![vast.ai RTX 4090 price](/assets/tools/optimize-hash-cracking/vast_io_price.png)

## Combine with Distributed Cracking

The combinations of our computing resources and cloud computing can be used with `Distributed Cracking` . This [Medium blog post](https://nikita-guliaev.medium.com/clustering-hashcat-with-hashtopolis-for-distributed-cloud-computing-55f964a56804) by Nikita Guliaev shows a step-by-step guide to use [vast.ai](https://vast.ai/) with Hashtopolis tool for distributed cloud computing to crack the hashes.

Prerequisites for the attack are:

- vast.ai account with enough money to buy GPUs. They will be used as agents to our Hastopolis server.
- Linux server with Internet access to create Hashtopolis server. 

The author also created [a docker image](https://hub.docker.com/r/nickyf0str/hashtopolis-agent-python) for hashtopolis agents, which can be pulled and used for GPUs agents. This makes the usage of distributed cracking as simple as possible. To connect an agent, the GPU server just have to execute 2 command at startup.

```bash
cd agent-python
python3 hashtopolis.zip --url server_api --voucher voucher_id
```

# Online Crackers and Databases

You can delegate the hash cracking to an outsource by using online resources. There are just free databases like [CrackStaion](https://crackstation.net/), which uses massive pre-computed lookup tables to crack password hashes and paid Cloud Password Recovery Services like [OnlineHashCrack](https://www.onlinehashcrack.com/), which do the cracking in real time for money.

![CrackStaion service](/assets/tools/optimize-hash-cracking/crackstation.png)

# Conclusion

In this post we explored the ways to improve our hash cracking process. As we can see, there are many ways from improving our wordlists to improving our hardware and distribute the tasks. These ways can be combined all together to achieve great success/costs performance.

I would like to refer to a great [Hash Crack - Password Cracking Manual](https://github.com/imrk51/hacking-books/blob/master/Hash%20Crack%20%E2%80%93%20Password%20Cracking%20Manual%20(v2.0).pdf) book. It contains ways to extract hashes form various systems, hash cracking fundamentals and advanced tips to upgrade your hash cracking experience. I strongly recommend read this book.

Thank you for reading, I hope it was useful for you ❤️