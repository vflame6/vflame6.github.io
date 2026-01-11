---
layout: post
title: Introducing leaker - Passive Leak Enumeration Tool
description: Introducing a new tool to find and enumerate public leaks via passive sources.
categories: [Pentest, Development]
date: 2026-01-11 12:49 +0300
---

## Introduction

Hi! Today I want to share my new tool - `leaker`. It is a leak discovery tool that returns valid credential leaks for emails, using passive online sources. In this blog post I will show its installation, functionality and discuss some ways to improve it in the future.

`leaker` is already available on my GitHub - [https://github.com/vflame6/leaker](https://github.com/vflame6/leaker).

![Introducing leaker](/assets/posts/pentest/introducing-leaker/leaker.png)

### subfinder, but for leaks

A main idea for the tool came from [subfinder](https://github.com/projectdiscovery/subfinder) tool, which is used to enumerate subdomains over passive sources, a.k.a. external attack surface management systems. I use it on a regular basis and it helps automate my work in external network penetration testing projects. 

I wanted to automate another attack vector in such type of projects - publicly available leaks. There a a few projects that provide options to view leaked data based on email or domain, like [ProxyNova](https://www.proxynova.com/tools/comb/). Much less, than for subdomains, but I think they will become more popular and we will have more such sources of information.

Main targets to focus were sources with an ability to disclose the leaked information. There are some sources without an option to view the leaked data, like [Have I Been Pwned](https://haveibeenpwned.com), they were out of scope for the tool. API access was preferred too. So, available sources for the time of writing: `proxynova`, `leakcheck`.

There are not many of them, but they are already yielding results. I tried the tool on few of my emails and got some leaked password for my accounts. So I think the tool is already useful for basic leakage checks on the projects.

## Installation

`leaker` requires **go1.25** to install successfully.

```bash
go install -v github.com/vflame6/leaker@latest
```

Compiled versions are available on [Release Binaries](https://github.com/vflame6/leaker/releases) page.

You can download and build the tool from source code. To Build:

```bash
git clone https://github.com/vflame6/leaker.git
cd leaker
go build -o leaker main.go
./leaker --version
```

### Configure API keys

`leaker` can be used right after the installation, however many sources required API keys to work. View an example configuration file here: [https://github.com/vflame6/leaker/blob/main/static/provider-config.yml](https://github.com/vflame6/leaker/blob/main/static/provider-config.yml).

The tool will generate a provider configuration file on the first launch, so you can also specify API keys there.

The example configuration file for the time of writing this is done like that: 

```yaml
leakcheck:
  - 0123456789abcdef0123456789abcdef01234567
```

After setting up the API keys, the tool will handle them automatically. If the API keys are not specified, leaker will automatically skip sources which require them to work.

## Usage

```bash
leaker -h
```

Here is a help menu for the tool:

```yaml
Usage: leaker [<targets>] [flags]

  leaker is a leak discovery tool that returns valid credential leaks for emails, using passive online sources.

Arguments:
  [<targets>]    Target email or file with emails

Flags:
  -h, --help                                     Show context-sensitive help.
  -s, --sources=all,...                          Specific sources to use for enumeration (default all). Use --list-sources to display all available sources.
  --timeout=10s                              Seconds to wait before timing out (default 10s)
  -N, --no-rate-limit                            Disable rate limiting (DANGER)
  -o, --output=STRING                            File to write output to
  --overwrite                                Force overwrite of existing output file
  -p, --provider-config="provider-config.yml"    Provider config file
  --proxy=STRING                             HTTP proxy to use with leaker
  -A, --user-agent=STRING                        Custom user agent
  --version                                  Print version of leaker
  -q, --quiet                                    Suppress output, print results only
  -v, --verbose                                  Show sources in results output
  -D, --debug                                    Enable debug mode
  --list-sources                             List all available sources
```

It is worth noting that leaker does not filter any of the received result. I mean if the leak contains more data than just username and password, like it is done in `LeakCheck`, leaker will output everything it got from the source. But, the tool will filter unrelevant and inappropriate data, for example results which do not match the entered search query. It is done like that in `ProxyNova` source, because they can give a result based on domain rather than target email. Such behavior is cool, but when you try to enter something like `username@gmail.com`, it can become a real mess.

### Run without pre-configured API keys

`leaker` can be used right after the installation. If the API keys are not specified, the tool will automatically skip sources that requires them and provide available results. 

At the time of the writing the only source without any authenticated access is `ProxyNova`.

```bash
leaker info@example.com -v -D
```

![leakers work without API keys](/assets/posts/pentest/introducing-leaker/leaker-noapi.png)

### Run with pre-configured API keys

If the API keys are specified, the tool will handle configured API keys automatically and execute the enumeration from specified sources.

At the time of the writing the only source with authenticated API access is `LeakCheck`.

> **Note:** LeakCheck disabled searching for emails under `.gov` domains. It will return an error if you try to do that.

```bash
leaker admin@example.com -v -D
```

![leakers work with API keys](/assets/posts/pentest/introducing-leaker/leaker-api.png)

## Further actions and development

There is a lot of opportunities to expand the tool’s functionality and unlock its full potential. The main problem for now is lack of available sources for that task. If you know some sources with public or paid APIs (or parseable frontend 😁), please share it with me - I will add it to the tool.

Also, I think it will force available source maintainers to improve their services. For example, they could add more leaked data into their databases. I think the community is not yet developed for such services.

I would be very grateful for new ideas and identified bugs in the tool. You can leave them on the [Issues page on GitHub](https://github.com/vflame6/leaker/issues). It would be a great contribution.

### How to add a new source in leaker

The code is easy to maintain, thanks to projectdiscovery team and especially [their open-source work on GitHub](https://github.com/projectdiscovery), I took a lot of code examples from their libraries and modified some things to make the code right to me and do its job.

To add a new source to the tool, you need to develop a new struct and implement the `Source` interface. The interface is defined here - [https://github.com/vflame6/leaker/blob/main/runner/sources/types.go](https://github.com/vflame6/leaker/blob/main/runner/sources/types.go).

You can use available sources as an examples for your module:

- `ProxyNova` is an example of free API, which does not require API key to work - [https://github.com/vflame6/leaker/blob/main/runner/sources/proxynova.go](https://github.com/vflame6/leaker/blob/main/runner/sources/proxynova.go)
- `LeakCheck` is an example of paid API, which requires API key to work - [https://github.com/vflame6/leaker/blob/main/runner/sources/leakcheck.go](https://github.com/vflame6/leaker/blob/main/runner/sources/leakcheck.go)

After the module is ready to use, add it to the list of all modules and the tool will handle everything automatically. The `AllSources` variable, which is responsible for that, can be found here - [https://github.com/vflame6/leaker/blob/main/runner/sources.go](https://github.com/vflame6/leaker/blob/main/runner/sources.go).

## Conclusion

In this post I’ve presented a new tool to enumerate leaks, its functionality and plans to improve it. You can find the tool on my GitHub - [https://github.com/vflame6/leaker](https://github.com/vflame6/leaker).

Thank you for reading, I hope it was useful for you ❤️

## Resources

- [https://github.com/projectdiscovery/subfinder](https://github.com/projectdiscovery/subfinder)
- [https://www.proxynova.com/tools/comb/](https://www.proxynova.com/tools/comb/)
- [https://wiki.leakcheck.io/en/api/api-v2-pro](https://wiki.leakcheck.io/en/api/api-v2-pro)
- [https://haveibeenpwned.com/API/v3](https://haveibeenpwned.com/API/v3)
