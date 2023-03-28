---
layout: post
title: How to install Microsoft Store applications without Microsoft Store
category: Tools
tags: windows applications automation
date: 2023-03-28 10:53 +0300
---

I had to install a Windows 10 VM to do some researches. But I’ve got a problem after the installation. There was not a Microsoft Store and of course I had to install some MS Store specific applications. 

In this article I will show you how to install MS Store specific applications without MS Store. You can even install the MS Store itself by doing this.

# Table of contents

- [Install App Installer](#install-app-installer)
  * [Turn on "Developer Mode"](#turn-on--developer-mode-)
  * [Install App Installer](#install-app-installer-1)
- [Example with WhatsApp Desktop](#example-with-whatsapp-desktop)
- [Conclusion](#conclusion)

# Install App Installer

## Turn on "Developer Mode"

Firstly, we have to turn on “Developer Mode”. Press Ctrl + I → Click “Privacy and Security” → Click “For developers” → Turn on “Developer Mode” → Click “Yes”.

{% 
    include image.html
    url="/assets/tools/windows-how-to-install-applications-without-ms-store/developer_mode.png"
    description="Turning on the Developer Mode in Windows"
%}

## Install App Installer

1. Find the application on MS Store web and copy link to that web page.

{% 
    include image.html
    url="/assets/tools/windows-how-to-install-applications-without-ms-store/app_installer_in_ms_store.png"
    description="Locating the link to App Installer application in MS Store"
%}

2. Go to this [site](https://store.rg-adguard.net/), put the link in an entry and click the button. The site will process the link and output all links to direct files needed to install the application. You can find all libraries required by the application in this list.

{% 
    include image.html
    url="/assets/tools/windows-how-to-install-applications-without-ms-store/link_generator.png"
    description="Using the Link Generator"
%}

{% 
    include image.html
    url="/assets/tools/windows-how-to-install-applications-without-ms-store/app_installer_links_list.png"
    description="The list of links to different versions of application and required packages"
%}

3. Download required packages. Applications can be in different formats (appx, appxbundle, msix, msixbundle). You can find more about how to install them manually [here](https://www.makeuseof.com/download-install-msixbundle-appx-appxbundle-microsoft-store/).  I recommend to install `.appx` or  `.appxbundle` package, because you can install them just with PowerShell commands. In my situation, I had to install the “VCLibs” library. It was also listed in packages list on the site.

4. Install required packages with PowerShell

```powershell
Add-AppxPackage -Path .\Downloads\Microsoft.VCLibs.140.00_14.0.30704.0_x64__8wekyb3d8bbwe.Appx
Add-AppxPackage -Path .\Downloads\Microsoft.DesktopAppInstaller_2019.1019.1.0_neutral___8wekyb3d8bbwe.AppxBundle
```

5. Check everything is OK. After installation, you could open .msix, .msixbundle and other installation files with App Installer application.

{% 
    include image.html
    url="/assets/tools/windows-how-to-install-applications-without-ms-store/app_installer.png"
    description="Trying to open an installer application with App Installer"
%}

# Example with WhatsApp Desktop

Suppose you want to install WhatsApp Desktop on your Windows computer. How can you do it without interacting with MS Store? The example of the process is below.

1. Find the app on MS Store web and copy link to the app page.

{% 
    include image.html
    url="/assets/tools/windows-how-to-install-applications-without-ms-store/whatsapp_in_ms_store.png"
    description="Locating the link to WhatsApp application in MS Store"
%}

2. Go to this [site](https://store.rg-adguard.net/), put the link in an entry and click the button.

{% 
    include image.html
    url="/assets/tools/windows-how-to-install-applications-without-ms-store/whatsapp_links_list.png"
    description="The list of links to different versions of application and required packages"
%}

3. Download the application package (here it is the second item with `.msixbundle` extension).

4. If you did install the App Installer app before, you can install applications in these formats easily by just double-clicking on them.

{% 
    include image.html
    url="/assets/tools/windows-how-to-install-applications-without-ms-store/installing_whatsapp.png"
    description="Using App installer to install the application with .msixbundle extension"
%}

5. Click the “Install” button and there you are.

{% 
    include image.html
    url="/assets/tools/windows-how-to-install-applications-without-ms-store/install_success.png"
    description="WhatsApp is installed successfully"
%}

# Conclusion

Today we learned how to install Microsoft Store applications without the MS store itself. You can also install applications and packages which are not distributed from the MS Store with App Installer.

Thank you for reading, I hope it was useful for you ❤️
