---
layout: post
title: NetNTLMv1-хеш. Что дальше?
categories: [Pentest, Research]
description: Несколько способов использовать NetNTLMv1 в корпоративных сетях.
date: 2025-08-29 01:00 +0300
lang: ru
ref: you-received-a-netntlmv1-hash-what-next
---

Некоторое время назад, на одном из собеседований меня спросили: **«Вам прилетел NetNTLMv1-хеш. Что с ним сразу можно сделать?»**

![NetNTLMv1-хеш в Responder](/assets/posts/pentest/you-received-a-netntlmv1-hash-what-next/netntlmv1.png)

По наитию я ответил: «брутануть или отправить в crack.sh для поиска в их заготовленных таблицах». На что мне отвечают, а еще? А я и не знаю 😅. Собственно, из-за этой ситуации я пошел разбираться, что да как с NetNTLMv1.

## **Атаки на NetNTLMv1**

### **Well-known challenge**

Для аутентификации через NetNTLM используется Challenge. Это число, которое клиент должен зашифровать своим ключом. В данном случае ключ — NTLM-хеш пароля пользователя, который проходит аутентификацию.

В NetNTLMv1 для генерации зашифрованного challenge используется только пара challenge и NTLM-хеш. Из-за этого становится возможен вектор атаки, когда **всегда используется одинаковый challenge** для всех клиентов. Различаться во всех случаях будет только второй элемент, NTLM-хеш. Это дает нам возможность подготовить большое количество NetNTLM-хешей паролей с предустановленным challenge. В сообществе выбрали число **«1122334455667788»**.

Как это реализовать? Во всем известном [Responder](https://github.com/lgandx/Responder) ставим наш заготовленный challenge. Дефолтный путь до конфига в Kali: `/etc/responder/Responder.conf`.

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

Далее запускаем и указываем флаг `--lm` для принудительного понижения уровня механизма аутентификации у жертвы. Если не сработает, можно попробовать еще раз с флагом `--disable-ess`.

```bash
sudo responder --lm -I eth0 -A
```

Осталось только снова поймать NetNTLMv1-хеш пароля пользователя. После этого, у нас есть 2 варианта: либо брутим сами, либо идем в онлайн за помощью сообщества.

В онлайне доступны такие инструменты как [crack.sh](https://crack.sh/get-cracking/) (сейчас недоступен) и [shuck.sh](https://shuck.sh/get-shucking.php), по сути это готовая инфраструктура для взлома таких хешей. Например, в crack.sh используется система из 48 FPGA, настроенная на взлом таких хешей. Такая система дает скорость в 768 000 000 000 ключей в секунду.

НО. **Использование онлайн сервисов создает риски утечки как для Заказчика, так и для исполнителя**, так как мы по сути должны отправить куда-то в онлайн валидные учетные данные из инфраструктуры Заказчика. Что с ними делают на той стороне — никто не знает. Использовать такие сервисы можно только на свой страх и риск. Лучшим решением будет наличие своей инфраструктуры для подобных задач.

В результате получаем NTLM-хеш пароля пользователя, который можно использовать в атаках Pass-The-Hash и Overpass-The-Hash к сетевым сервисам.

### **NTLM relay (SMB → LDAP)**

Как известно, нельзя провести атаку NTLM relay из SMBv2+ в LDAP, так как протокол SMBv2 и выше предполагает требование к подписи через session key. А убрать эту подпись нельзя, иначе случится ошибка валидации Message Integrity Code (MIC). Откуда, куда и как можно релеить хорошо описано в [статье от hackndo](https://en.hackndo.com/ntlm-relay/).

Оказалось, что использование протокола NetNTLMv1 является исключением для правила подписи запросов, так как протокол не поддерживает механизм расчета MIC. Это позволяет провести атаку NTLM relay из SMB в LDAP, например через [ntlmrelayx.py](https://github.com/fortra/impacket/blob/master/examples/ntlmrelayx.py) из пакета impacket. Реализуется также, как эксплуатация уязвимости [CVE-2019-1040 (Drop the MIC)](https://dirkjanm.io/exploiting-CVE-2019-1040-relay-vulnerabilities-for-rce-and-domain-admin/), через опцию `--remove-mic`. Пример команды:

```bash
ntlmrelayx.py -t ldap://<other_dc_IP> -smb2support --no-dump --no-da --no-acl --no-validate-privs --remove-mic --shadow-credentials
```

Возможные вектора для развития атаки будут зависеть от того, чью учетную запись мы можем заставить авторизоваться в нашем relay-сервере. Основные вектора для атаки:

- Dump domain info (Default);
- Shadow credentials (`--shadow-credentials`);
- Resource-based constrained delegation (`--delegate-access`);
- Escalate privileges of the user (`--escalate-user`);
- LDAP-shell (`--interactive`).

В случае с RBCD мы перезапишем атрибут **msDS-AllowedToActOnBehalfOfOtherIdentity** и сможем получить Silver Ticket для сервисов учетной записи жертвы с помощью механизма S4U2Proxy.

А в случае с Shadow Credentials мы перезапишем атрибут **msDS-KeyCredentialLink** и сможем получить сертификат для авторизации с учетной записью жертвы, а затем получить NTLM-хеш от этой учетной записи с помощью атаки [UnPAC-the-Hash](https://www.thehacker.recipes/ad/movement/kerberos/unpac-the-hash).

Вот и ответ на вопрос из начала поста. Возможностей для развития атаки очень много, здесь я постарался отразить основные.

## **Защита от NetNTLMv1**

Для защиты от NetNTLMv1 в доменной инфраструктуре нужно раскатить групповую политику со следующей настройкой: по пути `Computer Configurations -> Policies -> Windows Settings -> Security Settings -> Local Policies -> Security Options → Network Security: LAN Manager authentication level` ставим значение Send NTLMv2 response only. Refuse LM & NTLM.

Или через реестр в случае изолированных машин: по пути `HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa` находим ключ `LmCompativilityLevel` и ставим значение DWORD — 3 для клиента (Send NTLMv2 response only) или 5 для сервера (Send NTLMv2 response only. Refuse LM & NTLM).

## **Заключение**

Таким образом, когда в инфраструктуре используется NetNTLMv1 или мы можем заставить жертву понизить уровень с NetNTLMv2, мы можем использовать это не только для восстановления изначального пароля пользователя, но и для атак типа NTLM relay.
