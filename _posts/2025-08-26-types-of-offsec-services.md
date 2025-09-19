---
layout: post
title: Types of Offensive Security Services
categories: [Pentest, Market]
description: My vision on describing and categorizing types of offensive security services with notes of when each category should be used.
date: 2025-09-19 01:00 +0300
---

After the previous post on “AI Red Teaming,” one question remained unanswered: what is the difference, and what should a potential customer of offensive security services choose? It seems that red teaming gives the “coolest” results, so does that mean everything else is unnecessary?

> This is a rather “sensitive” topic, so here's a disclaimer: everything in this post is my personal opinion, and I do not claim to have the absolute truth on this topic. I think that many companies and specialists may have a different understanding of the differences between these services, and that's fine. I am simply expressing my vision, which I believe is effective for solving the tasks of our customers.

To understand this issue, we first need to answer two questions: determine the goals of the customer requesting the service and determine the current level of information security maturity in the company. Let's start with the goals.

## On a hard subject — the goals for Penetration Testing

If the goal is to be cool, like in movies about hackers, then there is no point in the event. In such cases, there is no talk of increasing the level of security of the organization, or things that would be interesting to check, or the effectiveness of the implemented security measures. The same can be said about situations where the goal is to “punish our security guys.”

Usually, problems start to emerge during the negotiation of labor costs and prices. Because at this stage, it becomes clear that the “movie-like” image is actually three months of work for five people at a cost of $100,000. And the customer thought that one specialist would do it in a week for $5,000, maximum.

![I don't know what Red Team is, and at this point I'm too afraid to ask meme](/assets/posts/blog/types-of-offsec-services/1-rtmeme.png)

What can I say, I'm guilty myself — I had experience participating in a “pentest with elements of red teaming” with a deadline of two working weeks. They wanted to break the infrastructure with web applications, do some phishing by also bypassing commercial EDR, and try to get away with it. It's easy to guess what the results of such projects are and how many conflicts arise with the customer's representatives and then with colleagues from the sales department. Unfortunately, such projects reach the contractor in a state of complete disagreement between expectations and reality.

Therefore, it is very important to agree on goals and expectations at the project discussion stage. We talked about how it was done wrong, but what are the right goals? They will be closely related to the current level of information security maturity in the company.

## Levels of information security maturity

Usually, when it comes to the level of information security maturity in a company for the selection of offensive services, three main levels are discussed:

**Stage 1. No information security**

The initial stage, when information security practices, if applied at all, are selective and simply initiated by IT specialists, without a formulated strategy.

In this situation, it is necessary to close obvious attack vectors on the company and determine where to start implementing information security organizationally and technically. Services: security analysis and penetration testing.

**Stage 2. Information security is operating in passive mode**

At this stage, the customer relies on the policies and security measures implemented in accordance with the information security strategy. The information security specialists of such an organization are busy auditing the current state of information security, implementing basic practices, and analyzing incidents.

In this situation, it is necessary to check the effectiveness of the work done by the information security department and to make sure that there are no “simple” vectors of penetration into the organization. Services: penetration testing.

**Stage 3. Information security operates in active mode**

The highest level of expertise. The customer's company has fully developed passive information security and is actively implementing proactive security. Specialists in such an organization are engaged in monitoring information security events on security tools, identifying existing threats to the organization, and responding to them.

In this situation, the goals will be to check the effectiveness of proactive security and evaluate the effectiveness of the set of information security measures. Services: red teaming and purple teaming.

## What does the market offer?

Next, let's look at what can be offered as an offensive security service. The image shows the differences between the main types of services. They differ in the breadth of coverage and depth of expertise. Here, it is easy to see the correlation between the level of information security maturity in the customer's company and the most effective service for their needs.

![Depth of main offensive security services](/assets/posts/blog/types-of-offsec-services/2-rtdepth.png)

So, there are three main types of services and one relatively new one (not shown in the figure):

### Vulnerability assessment (automated testing)

The process is simple: get an access to the target → run the scanner → analyze the report → leave. Performed in a white box format, without protection. Takes 1-2 weeks with a report.

Types:

- Web applications - DAST tools (Acunetix, Burp Scanner);
- Mobile applications - MAST tools (MobSF, AppScreener);
- Infrastructure - vulnerability scanners (Nessus);
- Specific technologies, such as Active Directory - specialized tools, such as PingCastle.

The goal is to identify known vulnerabilities in the infrastructure and applications and prioritize their elimination. This is necessary if the customer has never dealt with offensive security before or does not have vulnerability scanning and management (Vulnerability Management, VM) processes in place.

During the security analysis, commercial vulnerability scanners are used, their output is analyzed, and the results are provided to the customer in a formatted (or we just slap our logo on the report and off we go 😁). There is no manual testing or targeted development for the customer, only automated work is used.

No specific expertise is usually required from the contractor for security analysis. But now everyone likes to require contractors to have OSCP certification, so let's focus on that.

### Penetration testing (manual testing)

Classic penetration testing. Performed in a gray/black box format. Security measures are usually disabled, but if they are enabled, they are not quarantined so as not to block further work. Duration: 2-4 weeks with a report.

Types:

- External infrastructure;
- Internal infrastructure;
- Web application;
- Mobile application;
- Social engineering;
- Wireless Wi-Fi networks;
- Physical intrusion.

The goal is to find attack vectors on company resources that remain after some work has been done on information security. It allows you to see unclosed holes, leaks, configuration errors, and unknown vulnerabilities. It is necessary after the implementation of an information security strategy to assess its effectiveness and when launching new applications.

![If having a coffee in the morning doesn't wake you up, try taking down a production server during a penetration test.](/assets/posts/blog/types-of-offsec-services/3-pentestmeme.png)

During pentesting, well-known techniques and tools are used, as well as the contractor's existing expertise. The key difference with vulnerability assessment - manual testing. But there are still no custom developing: tools for targeted attacks and bypassing security measures are not developed due to lack of time.

Although some vendors offer to include bypassing security measures in the scope of work, this significantly increases the project's duration and price, and usually does not bring any benefit, as there is no understanding of why this should be included in the scope. The same situation applies to the attacking infrastructure; for example, the same static IP address is used, so quarantine on the information security system is removed using whitelists.

In terms of the contractor's qualifications for performing pentesting, OSCP certification is usually required as a baseline, as well as certification in the domain areas of the object of study, such as OSWE for web applications or eMAPT for mobile applications.

### Red Teaming (adversarial simulation)

Simulation of a real attack on a company. Performed in a black box format, with security measures enabled, including active monitoring and blocking. Duration: 3 months with a report.

Conducted without communication. There is no or minimal interaction with the information security team. The occurrence of an unacceptable event is assessed by the end of the project.

The goal is to simulate events that are unacceptable for the company in conditions that are as close to reality as possible. This allows you to see the ability of the information security department to detect and counter attacks within the framework of proactive protection, as well as the effectiveness of the implemented set of information security processes and security measures.

During the red teaming process, custom tools and TTPs are developed and used, including the development of a targeted attack on a specific customer. Development usually takes up the first month and a half of work on the project. At this point, the “attacker's activity” on the customer's infrastructure is greatly reduced.

![Everyone is an atheist until they're waiting for a reverse shell to connect back - Sun Tzu](/assets/posts/blog/types-of-offsec-services/4-rtmeme2.png)

Here, bypassing the customer's security measures becomes a mandatory requirement for project implementation, and the necessary resources are allocated. The same situation applies to the attacking infrastructure: IP addresses are rotated, noisy actions are not used unnecessarily, there is a backup infrastructure and useful payloads for cases of complete blocking of attackers (IP, domains, hash sums, protocols, tools, etc.).

To confirm the contractor's qualifications, for the most part, they use their existing, public experience in successfully implementing red team projects. If they look at certifications, they look at the number of certifications specifically related to malware development and targeted attacks, such as OSEP, CRTO/CRTE, MalDev academy.

### Purple Teaming (cyber training)

A relatively new service for the CIS market. Simulation of various attack scenarios on a company. Performed in a black box format, with protection measures enabled, including active alerting and blocking. The timing and report are determined by the coverage and format of interaction, usually from 1 month.

Purple teaming projects are carried out with communication. There is coordination and interaction with the customer's IT security department. Metrics for coverage of known TTPs, detection time, and response time in various attack scenarios are evaluated.

![Red Team plus Blue Team equals Purple Team](/assets/posts/blog/types-of-offsec-services/5-purpleteam.png)

The goal is to quantitatively and qualitatively determine the effectiveness of proactive information security in the company. It allows you to formulate performance metrics, identify gaps in information security responsibilities, and fine-tune security measures to ensure full coverage of known TTPs.

During cyber exercises, the contractor typically uses existing developments for implementing relevant tactics, techniques, and procedures. By agreement, these are implemented on the customer's infrastructure to determine the ability of the information security department to detect and counter specific techniques. Developments can be carried out to implement specific scenarios and specific TTPs.

For more information about Purple Teaming, see [Purple Team Exercise Framework on GitHub](https://github.com/scythe-io/purple-team-exercise-framework).

## **Conclusion**

With each level, the amount of labor and expertise required from the contractor increases exponentially, and so does the price of the project. Thus, we have different services for specific situations at the customer's site.

Unfortunately, reality shows that many people do not understand the differences and the necessity of a particular measure for their task within the budget. And the sales strategies of some companies only exacerbate the gap between expectations and reality. This affects the quality of services provided and the potential for long-term cooperation between the customer and the contractor.

I hope this post will help readers better understand the types of offensive security services available and, if necessary, make the right choice. Also, note that **AI Red Teaming == AI Security Research 😁**.
