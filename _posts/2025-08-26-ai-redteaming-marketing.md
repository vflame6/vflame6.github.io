---
layout: post
title: AI Red Teaming or What Marketing has done to Penetration Testing
categories: [Pentest, Market]
description: Several considerations on market shift from classic security research to red teaming everything.
date: 2025-09-12 01:00 +0300
---

In this post, I want to talk about the so-called “AI Red Teaming,” namely a certain trend that is leading the market away from security research/penetration testing and toward red teaming. In the screenshot below, for example, I have included a course from HackThebox with the corresponding name, but in fact, the term is used everywhere.

![HTB AI Red Teamer course](/assets/posts/blog/ai-redteaming-marketing/htb_airedteamer.jpg)

In my opinion, this whole situation with red teaming instead of security research or pentesting is a deeper market problem. It already has negative consequences, including in the CIS region. The reason is simple: it is more difficult for marketers to sell pentesting than red teaming. I want to talk more about this problem.

## **Why AI Red Teaming?**

Let's start with the classic Red Team, a little history:

> The concept of Red Teaming originated during the Cold War, when the “red team” simulated enemy actions and the “blue team” defended itself. Later, this approach moved into the world of IT and cybersecurity.

A full-fledged Red Teaming service has emerged in the cybersecurity market: The contractor must attempt to penetrate the organization's infrastructure and, if agreed in advance, carry out an unacceptable event. All this is done with the protection measures enabled and the customer's cybersecurity department operating as usual. In general, to put it simply, it is a simulation of a real attack on an organization.

Now let's move on to “AI Red Teaming.” We will take the definition from the [OWASP GenAI Red Teaming Guide](https://genai.owasp.org/resource/genai-red-teaming-guide/):

> GenAI Red Teaming provides a structured approach to identify vulnerabilities and mitigate risks across AI systems focusing on safety, security, and trust. This practice combines traditional adversarial testing with AI-specific methodologies, addressing risks like prompt injection, toxic outputs, model extraction, bias, knowledge risks, and hallucinations. GenAI Red Teaming ensures systems will remain secure, ethical, and aligned with organizational goals.
> 

Here we can see the discrepancy between the goals of classic red teaming and AI red teaming. The first is to simulate a real attack on an organization, while the second is to **audit the security of an AI model**.

Next, let's look at the definition of the already familiar [OWASP Web Security Testing Guide](https://owasp.org/www-project-web-security-testing-guide/):

> The WSTG is a comprehensive guide to testing the security of web applications and web services. Created by the collaborative efforts of cybersecurity professionals and dedicated volunteers, the WSTG provides a framework of best practices used by penetration testers and organizations all over the world.

It is easy to see that there is no particular difference here from GenAI Red Teaming. Only security testing has been replaced with adversarial testing. **Why then is one called pentesting and the other red teaming?** I don't have an answer to that...

## **How did AI Red Teaming come about and what does it really mean?**

Further in this post, I will focus on terms and definitions from Google, as they started the topic of AI Red Teaming [back in 2018](https://blog.google/technology/safety-security/googles-ai-red-team-the-ethical-hackers-making-ai-safer/).

Google began creating internal teams that tested large language models for resilience to malicious influence, misinformation, and confidential data leaks. **These teams were called AI Red Teamers**.

The term spread beyond the company: DEF CON held AI Red Teaming competitions, where participants tried to get LLM to give malicious responses or reveal its instructions.

Thanks to the work of the AI Red Teamers, the main vulnerabilities for LLM have now been identified. So, to quote Google, **Common types of red team attacks on AI systems**:

- Prompt attacks;
- Training data extraction;
- Backdooring the model;
- Adversarial examples;
- Data poisoning;
- Exfiltration.

It looks like a list of AI model vulnerability classes, and it seems that there are no “red team attacks” here. If we compare it to web applications, it is exactly the same as the OWASP TOP 10 with a list of application weaknesses, only the “application” itself is different. There are no tactics, techniques, or procedures (TTPs) that need to be covered by monitoring and response from defenders.

So, AI Red Teaming is not quite Red Teaming?

## **Why is AI Red Teaming bad for the market?**

In recent years, there has been a growing trend toward red teaming in the world of offensive information security, as large customers are increasingly moving toward proactive security and need to test this approach for performance and effectiveness.

Over time, the term has become more popular, and hype has set in—now small and medium-sized businesses, often without functioning information security, need red teaming, just like large organizations do. Because salespeople say that it will really break things and be cool.

To some, red teaming sounds more impressive than security analysis or penetration testing. It creates the illusion of depth and scale of services. For example, it is understandable why many contractors prefer to use this term when pre-selling to clients. You explain how your specialist will start red teaming, how they will get into the infrastructure, how they will physically get into critical office premises, and that's it — the customer is ready to buy everything from you. **It really works.**

This is where the problem begins—customers with a “below average” level of information security maturity, who simply need a perimeter scan for vulnerabilities, spend time, effort, and huge amounts of money on high-level services.

As a result, they receive a report in which they were broken into, the penetration goal was achieved using one attack vector on the external network and one attack vector on the internal network, and the number of steps from penetration to domain administrator was 2-3. Next, the customer closes these gaps, orders the same service for a lot of money, and again gets the same result. How is this possible?

And I'm not even talking about the fact that most contractors simply don't have the necessary competencies to conduct a full-fledged Red Team. But they continue to sell it knowingly, hoping that due to the customer's weak level of information security, they will draw up a cool report with a “real attack,” and the customer simply won't comply.

### **Let's get back to AI Red Teaming. What are the consequences?**

The emergence of AI Red Teaming is the first precedent leading to errors in expectations and reality in terms of offensive information security services. My opinion: very soon it will be usual to start ordering red teaming for web applications, red teaming for mobile applications, and so on.

This “simplification” will lead to the price for a service with the same name varying greatly from case to case. The customer will no longer understand **what they need and how much it will cost**. And the contractor will not understand **what they need to do and how much to charge for it**.

I expect that offensive security for the next big technology will also be called **[TECHNOLOGY_NAME] Red Teaming**. Because now security research is not cool.

And everything that was before will remain with the established terms: AD security research, web security research, ... Although, most likely, they will soon be swept away by the wave of red teaming.

Modern shift-left security practices, such as DevSecOps in the case of application development and MLSecOps in the case of AI application development, may also begin to be underestimated or even eliminated. Because if red teaming didn't break it, then everything is fine. Right?

As a result, things like pipeline security analysis, infrastructure, physical security, access control, protection against internal attackers, SOC, and adequate pentesting can become unnoticed. This opens up a large number of risks and creates obscurity about the real level of information security maturity in the organization.

As a result, customers with a low level of information security maturity do not want to use offensive security services that correspond to their level of maturity. Because of this, that very level of maturity **may never grow**.

### **Candidates who are AI Red Teamers**

In terms of work for a pentester, the situation is getting worse. Job candidates are increasingly encountering positions such as “Red Teamer,” “AI Red Teamer,” “Cloud Red Teamer,” and other similar titles.

When you start digging deeper and read about their most recent jobs and job responsibilities, you find that they ran Nessus, Burp Scanner, and even used Metasploit.

Here we come back to the original problem: it will be harder for a skilled security researcher to find a job than for an AI Red Teamer with zero years of experience. Because the latter sells better to HR and business in general.

Of course, I'm exaggerating in some places here, but that's the logic of the whole situation.

## **Conclusion**

The term **AI Red Teaming**, popularized by Google and other organizations, causes real confusion — it sounds impressive, but often hides simple model tests rather than full penetration into the customer's system and infrastructure, as understood in the usual definition.

Clients and customers who request red teaming may expect scenarios that the contractor cannot offer, since their “Red Teaming” consists of poking the model with various prompts.

It is important to distinguish between AI Red Teaming (testing the model for specific attacks) and classic Red Teaming (simulating an attack on the entire organization). The best term is **AI security research**, without any pretensions.

It is important to speak clearly, use precise definitions, and protect the interests of clients by offering not a marketing slogan, but real work with specific expectations and benefits. This will be the subject of the next post.

Thank you for reading, I hope it was useful for you ❤️
