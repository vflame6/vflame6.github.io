---
layout: post
title: Scanning Big Networks - Alternative Methods
date: 2025-02-06 12:47 +0300
description: Alternative to scanning methods to achieve network, host and port identification. This post covers Active Directory domains and Kubernetes clusters.
categories: [Pentest, Research]
---

## Introduction

Hi! Today I want to continue sharing my notes on scanning enterprise networks. 

At part 1 we did review the basics for optimizing our scanning techniques to get better results for less time. At part 2 we’ve highlighted defense evasion and automation methods for our scanning. 

At this part of Scanning Big Networks series, we will review some alternatives to identify hosts and services in the network in case of Active Directory domains and Kubernetes clusters. These methods can provide enough information for us to process by leveraging enumeration of specific technologies.

## Active Directory

In case of Active Directory networks, we can leverage queries for registered services, workstations and servers.

### Bruteforce DNS records

The DNS server on Domain Controller can be used to do reverse-ip queries to get the actual domain names. In case of AD networks it can be used to identify available hosts and the actual purpose of these hosts. 

The example here is the same as DNS subdomain bruteforce technique shown in part 1. You only need to specify domain controller address as the resolver.

```bash
echo 10.10.10.10 | aiodnsbrute -r - domain.local
```

The reverse IP-address technique will work here as well.

```bash
cat ips.txt | hakrevdns -r 10.10.10.10
```

### Query AD computers

If we have credentials for Active Directory user account, we can start enumerate the domain. All users in the domain are allowed to access Active Directory LDAP database and get some information about the domain.

The most easy way to identify hosts in the domain is to query domain-joined computer objects via LDAP queries. It is done automatically with tools like https://github.com/SpecterOps/SharpHound and [ldapdomaindump](https://github.com/dirkjanm/ldapdomaindump), check them out on their GitHub repositories.

The cons of this method is a large number of unclassified data, the list of domain computers in our case. If we don’t know a naming convention used by domain administrators, we’ve probably will struggle with scope identification.

For example, we can use [PowerView](https://github.com/PowerShellMafia/PowerSploit/blob/master/Recon/PowerView.ps1) to query all domain computers in our domain, it is also crucial to specify the output file, because the list will be large in production networks. This command will return all computers or specific computer objects in AD.

```bash
Get-DomainComputer | Out-File -FilePath computers.txt
```

### Query AD services

The Active Directory domain contains . ServicePrincipalName attribute allows interpret the object as a service and request access for it with Kerberos.

```
setspn -T corp1 -Q MSSQLSvc/*
```

Some of the more interesting services and example [SPNs](https://adsecurity.org/?page_id=183):

- SQL servers, instances, ports, etc.
    - MSSQLSvc/adsmsSQLAP01.adsecurity.org:1433
- Exchange
    - exchangeMDB/adsmsEXCAS01.adsecurity.org
- RDP
    - TERMSERV/adsmsEXCAS01.adsecurity.org
- WSMan / WinRM / PS Remoting
    - WSMAN/adsmsEXCAS01.adsecurity.org
- Hyper-V Host
    - Microsoft Virtual Console Service/adsmsHV01.adsecurity.org
- VMWare VCenter
    - STS/adsmsVC01.adsecurity.org

There is a PowerShell script named `Discover-PSInterestingServices` available on GitHub - https://github.com/PyroTek3/PowerShell-AD-Recon/blob/master/Discover-PSInterestingServices. It is used to discover network servers with interesting services without port scanning. Service discovery in the Active Directory Forest is performed by querying an Active Directory Global Catalog via LDAP.

It queries LDAP server for objects with `SerivcePrincipalName` attribute specified in the current domain or in the whole forest, it supports filtering.

The repository of the tool contains more interesting PowerShell scripts, for example to enumerate available MS Exchange server. You can view the repository on GitHub - https://github.com/PyroTek3/PowerShell-AD-Recon.

While SPN attribute is used for servers and their services, it is possible to specify an SPN to a domain user. If a domain user has an SPN, we can try to attack his password by requesting a TGS. This will allow us to perform a targeted kerberoasting attack. You can read more about it here - https://www.thehacker.recipes/ad/movement/dacl/targeted-kerberoasting.

If the LDAP service is not available for us, we can try to use Active Directory Web Services on port 9389. For example, we can use https://github.com/wh0amitz/SharpADWS tool to enumerate the domain via ADWS:

```bash
SharpADWS.exe Kerberoastable -action list
```

### Get DNS zone through LDAP

To dump DNS zones stored in Active Directory via LDAP, you typically need **read access** to the relevant DNS partitions in Active Directory. By default, **Domain Admins** and **Enterprise Admins** have this access, but regular authenticated users might also have read permissions unless explicitly restricted. We need a read access to DNS application partitions:

- **DomainDNSZones** (DC=DomainDnsZones,DC=example,DC=com)
- **ForestDNSZones** (DC=ForestDnsZones,DC=example,DC=com)

The actual DNS record data is stored in binary format within the `dnsRecord` attributes.

We can use PowerShell to enumerate available DNS zones:

```powershell
# Define the domain
$domain = (Get-ADDomain).DNSRoot

# Connect to DomainDNSZones
$domainDNS = "LDAP://DC=DomainDnsZones,DC=$($domain -replace '\.',',DC=')"
$searcher = New-Object DirectoryServices.DirectorySearcher([ADSI]$domainDNS)
$searcher.Filter = "(objectClass=dnsZone)"
$searcher.PageSize = 1000

# Fetch DNS zones
$results = $searcher.FindAll()

# Display the DNS zones
foreach ($result in $results) {
    $zoneName = $result.Properties["name"]
    Write-Output "DNS Zone: $zoneName"
}
```

To enumerate **all DNS records** within a specific zone:

```powershell
# Replace example.com with the actual zone
$zone = "example.com"
$ldapPath = "LDAP://DC=$($zone -replace '\.',',DC='),CN=MicrosoftDNS,DC=DomainDnsZones,DC=$($domain -replace '\.',',DC=')"
$searcher = New-Object DirectoryServices.DirectorySearcher([ADSI]$ldapPath)
$searcher.Filter = "(objectClass=dnsNode)"
$searcher.PageSize = 1000

# Fetch and display records
$results = $searcher.FindAll()
foreach ($result in $results) {
    $recordName = $result.Properties["name"]
    $recordData = $result.Properties["dnsRecord"]
    Write-Output "Record: $recordName - Data: $recordData"
}
```

Also we can use third-party tools like `ldapsearch` and `PowerView` to get the same results:

```bash
ldapsearch -x -H ldap://<domain_controller> -D "<user>@<domain>" -W \
-b "DC=DomainDnsZones,DC=example,DC=com" "(objectClass=dnsZone)" name
```

```powershell
Import-Module .\PowerView.ps1
Get-DomainDNSZone
```

All Windows DNS servers, whether AD DCs or not, also have their information accessible through RPC (the same that's used by RSAT's "DNS Server" console). You can use `samba-tool dns` to query the servers over RPC.

```bash
samba-tool dns query 10.10.10.10 company.local @ ALL --username 'COMPANY\adminperson' --password 'P4S5w0rd' | grep 'A: ' -B1 | sed 's/ //g;s/(.*)//g;s/,Records.*//g;s/AAAA://g;s/A://g' | awk '/^Name.*/{if(buf){print buf};buf=$1}/^[a-zA-Z0-9]/{buf=buf","$0}END{print buf}' | sed 's/Name=//g' | awk -F',' '{print"\""$2"\"," $3}' | tr '[:upper:]' '[:lower:]' | sed '1 i\\"hostname\",ip_addr' > ad_records.csv
```

## Kubernetes

Kubernetes has a built-in functionality to enumerate clusters and namespaces. It uses well-documented REST API for its clients and DNS server distribute and configure names of resources. We can use them in our work to enumerate the cluster or its resources.

### Query k8s API

The k8s API is used to access cluster resources. We can do everything with the cluster with that API. We will focus on resource enumeration techniques here.

If k8s network policies are not sufficiently configured, we can access the API server from almost everywhere. But we have to get an authorization token for that.

Another possible restriction for us is k8s RBAC. In case of resource enumeration, we need to have `LIST` rights for target objects, like pods, services, deployments, etc… If you also have a `GET` right, you will be able to get details for specific target resources.

We can do GET requests with kubectl command. I’ve specified several commands to list available pods, nodes and services below:

```bash
# List all services in the namespace
kubectl get services
# List all pods in all namespaces
kubectl get pods --all-namespaces
# List all pods in the current namespace, with more details
kubectl get pods -o wide
# List a particular deployment
kubectl get deployment my-dep
# List all pods in the namespace
kubectl get pods
# Get a pod's YAML
kubectl get pod my-pod -o yaml
# Get all worker nodes (use a selector to exclude results that have a label
# named 'node-role.kubernetes.io/control-plane')
kubectl get node --selector='!node-role.kubernetes.io/control-plane'
```

You can check more kubectl command examples in - [oficial Quick Reference guide for kubectl](https://kubernetes.io/docs/reference/kubectl/quick-reference/).

If kubectl is not available in our case, we can use standard `curl` command to get the same results.

```bash
# pre-configure
export APISERVER=${KUBERNETES_SERVICE_HOST}:${KUBERNETES_SERVICE_PORT_HTTPS}
export SERVICEACCOUNT=/var/run/secrets/kubernetes.io/serviceaccount
export NAMESPACE=$(cat ${SERVICEACCOUNT}/namespace)
export TOKEN=$(cat ${SERVICEACCOUNT}/token)

curl -k --header "Authorization: Bearer ${TOKEN}" https://${APISERVER}/api/v1/namespaces/${NAMESPACE}/pods
```

### Bruteforce k8s services

If we don’t have rights to list pods and services via k8s API, we can perform bruteforce enumeration by interacting with k8s DNS service. The https://github.com/Esonhugh/k8spider tool is used to automate the process.

The tool will be useful during the exploration phase inside the Kubernetes infrastructure, after the initial penetration into pods inside the cluster. With its help we can identify other running pods and services in the cluster. Reconnaissance techniques are used using queries to the DNS server of the Kubernetes cluster.

The k8spider uses several techniques to gather information from within:

- **Service ip-port BruteForcing.** Makes SRV queries on domain names to get services;
- **AXFR Domain Transfer Dump.** Makes an AXFR query on a given zone;
- **Coredns WildCard Dump.** Makes a wildcard request for a specified zone (any.any.svc. + zone);
- **Pod Verified IP discovery.** Makes PTR queries on IP addresses to obtain domain names.

With these techniques, the tool gets the IP addresses, domain names, and ports of the services running in the cluster. And we use this information to, for example, connect to a database or other service.

For example, the tool works in all-in-one (`all`) mode. We can also use point techniques (other modes) and customize the search area, for example, set CIDR with the `-c` flag.

```bash
# in kubernetes pods
root@pod:~# echo $KUBERNETES_SERVICE_HOST
# if KUBERNETES_SERVICE_HOST is empty, you can use the following command to set it.
# export KUBERNETES_SERVICE_HOST=x.x.x.x
# or ./k8spider -c x.x.x.x/16 all

root@pod:~# ./k8spider all
INFO[0000] PTRrecord 10.43.43.87 --> kube-state-metrics.lens-metrics.svc.cluster.local. 
INFO[0000] PTRrecord 10.43.43.93 --> metrics-server.kube-system.svc.cluster.local. 
INFO[0000] SRVRecord: kube-state-metrics.lens-metrics.svc.cluster.local. --> kube-state-metrics.lens-metrics.svc.cluster.local.:8080 
INFO[0000] SRVRecord: metrics-server.kube-system.svc.cluster.local. --> metrics-server.kube-system.svc.cluster.local.:443 
INFO[0000] {"Ip":"10.43.43.87","SvcDomain":"kube-state-metrics.lens-metrics.svc.cluster.local.","SrvRecords":[{"Cname":"kube-state-metrics.lens-metrics.svc.cluster.local.","Srv":[{"Target":"kube-state-metrics.lens-metrics.svc.cluster.local.","Port":8080,"Priority":0,"Weight":100}]}]}
```

You can see the examples of k8spider work below:

![k8spider example 1](/assets/pentest/scanning-big-networks-3/k8spider-1.png)

![k8spider example 2](/assets/pentest/scanning-big-networks-3/k8spider-2.png)

## Resources

- [https://t.me/vflame6/60](https://t.me/vflame6/60)
- [https://superuser.com/questions/1752992/can-i-look-up-dns-a-records-through-ldap](https://superuser.com/questions/1752992/can-i-look-up-dns-a-records-through-ldap)
- [https://www.youtube.com/watch?v=W1Tn_-OExIM](https://www.youtube.com/watch?v=W1Tn_-OExIM)
- [https://stackoverflow.com/questions/58159866/get-vs-list-in-kubernetes-rbac](https://stackoverflow.com/questions/58159866/get-vs-list-in-kubernetes-rbac)
- [https://adsecurity.org/?page_id=183](https://adsecurity.org/?page_id=183)

## Conclusion

In this post we’ve reviewed methods of network, host and port identification without actually scanning the network. As we see, we can get some attack surface by just accessing enterprise directory services and management clusters.

Thank you for reading, I hope it was useful for you ❤️
