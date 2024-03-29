---
layout: post
title: RingZer0 CTF - Classic Sudoku
category: CTF
tags: ringzer0 coding python
date: 2022-07-19 12:25 +0300
---

![Challenge banner](/assets/ringzer0/coding_challenges/classic-sudoku/classic-sudoku.png)

# The challenge

In this challenge we have to login in via ssh to get the task. Let's see what it is:

```bash
ssh -p 10143 sudoku@challenges.ringzer0team.com
```

![The challenge](/assets/ringzer0/coding_challenges/classic-sudoku/challenge.png)

We have to solve 3x3 Sudoku challenge in less than 10 seconds. I don't think human can do it easily, so we need some coding here and we will use `Python3`. Let’s solve it step-by-step 👨‍💻

# Configuration

## Preparation

It was so hard to find a library which would work correctly in our case. After some hours of exploring, I've found that we can interact with a child process created by a `pty` and `os` libraries. I thought to write sudoku solver myself, but luckly for us there is a library that can do it - [py-sudoku](https://pypi.org/project/py-sudoku/). We install it in terminal with command below:

```bash
pip3 install py-sudoku
```

## Libraries and globals

Now the code starts:

```python
import os
import pty
from sudoku import Sudoku

HOST = 'challenges.ringzer0team.com'
PORT = '10143'
USER = "sudoku"
PASS = "dg43zz6R0E"

ssh_command = [
    "/usr/bin/sshpass",
    "-p",
    PASS,
    "ssh",
    "-p",
    PORT,
    f"{USER}@{HOST}",
]
```

After imports we specify variables for login into `ssh`. Then, we specify list with command strings, we will use it later to create our child process. 

We are using `sshpass` to provide the password in one command, I did it just to make things easier, never do it in real work.

# Get the challenge

## Connect via ssh

After preparation, we are creating a `child process`, which will connect to the server via ssh. We use `fork` function from pty library to get the process, then we execute our `ssh_command` and start interact with it. We get `raw_challenge` string and parse it by creating the list, slicing it and converting into a string again.

```python
pid, child_fd = pty.fork()

if not pid:
    os.execv(ssh_command[0], ssh_command)

# Skip pty message
output = os.read(child_fd, 1024)

raw_challenge = os.read(child_fd, 1024).decode()
raw_challenge = raw_challenge.split("\n")

challenge = "\n".join(raw_challenge[3:22])

board = parse_sudoku(challenge)
```

We interact with child process by reading it STDOUT with `os.read` and writing into STDIN by `os.write`. We skip ssh's message about PTY by reading 1 line.

## Parse the challenge

To work with py_sudoku we have to convert challenge string into two-dimensional list. It is a requirement, I've made a function called `parse_sudoku` to do it.

```python
def parse_sudoku(plain_text):
    result = []
    lines = plain_text.split("\n")
    lines = lines[1::2]

    for line in lines:
        res_line = []
        for num in line.split("|"):
            if num == " " * 3:
                res_line.append(0)
            elif num.strip().isdigit():
                num_ = int(num.strip())
                res_line.append(num_)
        result.append(res_line)
    return result
```

We use slicing to get lines one by one. Then, we split the line and checking if there is 3 spaces or a number. 3 spaces are equal to 0 here.

# Solve the Sudoku

## Just solve it

The solution is really simple. We already have what we need, just provide the `board` to `Sudoku` class with 3x3 size and call the `solve` function. The library presents the solution in many formats, but list is the most preferred for us, so we specify `board` attribute. Then, we have to convert the solution into right format and write it to STDIN of our child process.

```python
puzzle = Sudoku(3, 3, board=board)
solution = puzzle.solve().board
answer = []
for line in solution:
    line_ = map(str, line)
    answer.append(",".join(line_))
answer = ",".join(answer) + "\n"

os.write(child_fd, answer.encode())
# Skip our written answer
os.read(child_fd, 1024)

flag = os.read(child_fd, 1024).decode()
print(flag)
```

We have to skip 1 line of STDOUT because there is our answer there. I don't know why our STDIN appears in our STDOUT...

## Run the script

Let's run our script and get the flag.

![Flag](/assets/ringzer0/coding_challenges/classic-sudoku/flag.png)

It worked! Paste the flag on the site to get your points!

![Solved!](/assets/ringzer0/coding_challenges/classic-sudoku/solved.png)

# Conclusion

I've spent a lot of time to find a way to interact with ssh session as a pseudo-terminal subprocess. I'm really glad to learn it. There are so much libraries written in Python. I think you can find everything written in this language 😂.

You can check full code [here](https://github.com/vflame6/ringzer0ctf-challenges/blob/main/Coding%20Challenges/classic_sudoku.py).

Thank you for reading, I hope it was useful for you ❤️
