---
layout: post
title: RingZer0 CTF - Xor Me If You Can
category: CTF
tags: ringzer0 coding python
date: 2022-06-30 16:25 +0300
---

![Challenge banner](/assets/ringzer0/coding_challenges/xor_me_if_you_can.png)

## The challenge
In this challenge we have to decrypt message and send answer back within 3 seconds. We need some coding here, so we will use Python3. Let's solve it step-by-step 👨‍💻

## Imports and prepares 
Here we have to open the url, parse it for a xor key string and a crypted message, the message is encoded by base64. For these purposes we have to import base64, requests and BeautifulSoup. Last two are not from the Python standard library, so you have to install them with `pip install requests beautifulsoup4`. Now the code starts:

```python
import base64
import requests
from bs4 import BeautifulSoup

url = 'http://challenges.ringzer0team.com:10016/'
answer_url = 'http://challenges.ringzer0team.com:10016/?r=%s'
```

We use format string `%s` in answer url, later we will format it with the answer.

## Get key and message
After our preparation, we will start the 3s timer by requesting the message. The first step we do is parsing the response for key and message. We also have to convert them in `bytes` type. Then, we decode message with `base64`.

```python
r = requests.get(url)
r = BeautifulSoup(r.text, 'html.parser')
data = r.findAll('div', class_='message')
key_pool, encoded_message = (msg.text.split()[5].encode() for msg in data)
key_length = 10

message = base64.b64decode(encoded_message)
```

Here we use BeautifulSoup `html.parser` and its `findAll` method. We select all blocks with `message` class.

## Decrypt the message and get a flag
The length of the xor key is 10 characters and it's hidden in the key string, we have to brute-force the xor key.  I was stuck here, because I didn't know the answer format, I had to try different answers. We check if the result is legal for us, it means the answer has only letters and digits. If result is legal, we break the loop and send the answer back.

```python
for i in range(len(key_pool) - key_length):
    key = key_pool[i:i+key_length]
    res = list()

    for index, char in enumerate(message):
        res.append(chr(char ^ key[index % key_length]))

    res = ''.join(res)

    if res.isalnum():
        answer = res
        break
    
r = requests.get(answer_url % answer)
r = BeautifulSoup(r.text, 'html.parser')
flag = r.findAll('div', class_='alert alert-info')[0].text
print(f'[*] Flag: {flag}')
```

We use the `^` (XOR) expression here, the message is bigger than the key, so we have to use it several times with `index % key_length` expression. Also, we parsing the response for the flag.

```python
[*] Flag: FLAG-XXXXXXXXXXXXXXXXXXXXXXXXXX # Edited
```

## Conclusion
The challenge was easy, but I was stuck with answer format for a time 😂

You can check the full code [here](https://github.com/vflame6/ringzer0ctf-challenges/blob/main/Coding%20Challenges/xor_me_if_you_can.py)

Thank you for reading, I hope it was useful for you ❤️
