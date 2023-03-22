---
layout: post
title: RingZer0 CTF - I Hate Mathematics
category: CTF
tags: ringzer0 coding js
date: 2022-08-21 20:34 +0300
---

Hi, I keep doing challenges on [RingZer0](https://ringzer0ctf.com/) and today I'm going to show the solution to "I hate mathematics" challenge. Here I'll use `JavaScript` and [Tampermonkey](https://addons.mozilla.org/en-US/firefox/addon/tampermonkey/) tool to solve the task.

# Table of contents

- [The challenge](#the-challenge)
- [Configuration](#configuration)
  * [Install Tampermonkey](#install-tampermonkey)
- [Solve](#solve)
  * [Get the message](#get-the-message)
  * [Take the flag](#take-the-flag)
- [Conclusion](#conclusion)

# The challenge

![Challenge banner](/assets/ringzer0/coding_challenges/i-hate-mathematics/i-hate-mathematics.png)

Today's challenge is very simple. We just have to solve a math expression in 2 seconds and send the answer back. I think it will be boring to do in Python, so I've decided to solve it by using JavaScript and a userscript manager tool Tampermonkey. You can find the tool in a link below, it is available for Chrome, Firefox, etc...

# Configuration

## Install Tampermonkey

To solve this we have add Tampermonkey to our browser extensions and create a new script. It will open a new window with our new empty script.

![Tampermonkey new script](/assets/ringzer0/coding_challenges/i-hate-mathematics/tm_new_script.png)

To see how it works let's add a `onload` function, which executes when the page is loaded.

```javascript
window.onload =(function () {
    let solveTask = () => {
        alert("It works!");
    };

    setTimeout(solveTask, 100);
})();
```

Here `setTimeout` function will wait 100 miliseconds to execute a `solveTask` function. Save the script and reload a task page, you will see an alert executed.

![Tampermonkey works](/assets/ringzer0/coding_challenges/i-hate-mathematics/tm_works.png)

# Solve

## Get the message

I am putting a code provided here in solveTask function, so when I reload the page it executes.

All coding challenges on RingZer0CTF with messages have a class name `message`, we can use it to get the full string. The message is in `innerText` attribute. Then, we can use `Regular Expressions` to get our math expression. We have to use string's `match` method with regex. This method returns an array, so we extract the first string.

```javascript
message = document.getElementsByClassName("message")[0];
message = message.innerText;
const re = /^\d+.*/gm;
message = message.match(re)[0];
```

## Take the flag

We've got an expression string. Now we have to get our values and convert them into decimal form. Javascript's string has a `split` method, which works just like in Python, so I used it here to get an array and extract the values. Also, we have to convert strings into integers, JS provides a `parseInt` function, which can be used to convert decimal, binary and hexadecimal numbers.

```javascript
values = message.split(" ");
x1 = parseInt(values[0]);
x2 = parseInt(values[2], 16);
x3 = parseInt(values[4], 2);
```

After some page reloads, I've noticed that the operations in math expression are always the same. So we don't have to parse the operations or just eval them.

Our final step is just to solve the expression and redirect it to URL. I've found that JS has template literals to perform text formatting and used it here.

```javascript
answer = x1 + x2 - x3;
const url = "http://challenges.ringzer0team.com:10032/?r=";
window.location.href = `${url}${answer}`
```

Finally, we have our script to solve the task. Reload the page and get the flag!

![Flag](/assets/ringzer0/coding_challenges/i-hate-mathematics/solved.png)

# Conclusion

I think the post might be boring, but I wanted to show a Tampermonkey tool, which allows us to do much more things than I've showed here. In-browser automation tasks could be solved just by using JavaScript in your browser, I think it is cool to do.

You can check full code [here](https://github.com/vflame6/ringzer0ctf-challenges/blob/main/Coding%20Challenges/i_hate_mathematics.js).

Thank you for reading, I hope it was useful for you ❤️
