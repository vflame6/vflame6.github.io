---
layout: post
title: Vim Commands
category: Tools
tags: vim editing productivity
date: 2023-02-04 03:18 +0300
---

Hi! Today I want to talk and share my notes about `Vim`. You can find notes about basic Vim command here. There won't be settings commands like `:set number`, we will explore them later. Here I want to show you basic Vim usage.

## Table of contents

- [First steps](#first-steps)
  * [What is Vim?](#what-is-vim-)
  * [Install and start Vim](#install-and-start-vim)
- [Modes](#modes)
- [Normal mode](#normal-mode)
  * [Moving](#moving)
  * [Using a count](#using-a-count)
  * [Scrolling](#scrolling)
  * [Jumping](#jumping)
  * [Searching](#searching)
  * [Deleting](#deleting)
  * [Changing](#changing)
  * [Change case](#change-case)
  * [Replace one character](#replace-one-character)
  * [Find and replace](#find-and-replace)
  * [Repeating a change](#repeating-a-change)
  * [Undo and Redo](#undo-and-redo)
  * [Copying](#copying)
  * [Putting](#putting)
  * [Copy-pasting from clipboard](#copy-pasting-from-clipboard)
  * [Finding help](#finding-help)
  * [Getting out](#getting-out)
- [Insert mode](#insert-mode)
  * [Inserting](#inserting)
- [Visual mode](#visual-mode)
  * [Entering Visual mode](#entering-visual-mode)
  * [Change case](#change-case-1)
  * [Change the end of the selection](#change-the-end-of-the-selection)
- [Replace mode](#replace-mode)
- [Conclusion](#conclusion)

## First steps

![You opened Vim for the first time](/assets/tools/vim-commands/open_vim_first_time.jpeg)

### What is Vim?

Vim is a text editor, created to work with text faster and more effictevily. In my opinion, you can become 10 times faster with typing/redacting your texts with Vim. It has a lot of cool features to make you perform a changes quickly by simple combinations of commands.

It is very useful to study Vim and combine it with blind 10 fingers typing. Take your time to reach that level and you will work with your texts like on steroids 🔥.

### Install and start Vim

I used a default Vim without configurations on the Ubuntu desktop VM. You can install it with apt.

```bash
sudo apt install vim
```

You can start Vim in 2 different ways: open it in current terminal session, or like a new window application. When you choose, specify the filename to enter Vim.

```bash
# Current terminal window
vim file.txt

# New window
gvim file.txt
```

## Modes

The editor behaves differently, depending on which mode you are in.. There are a lot of modes in Vim:

- In `Normal` mode the characters you type are commands.
- In `Insert` mode the characters are inserted as text.
- In `Visual` mode you selecting the text.
- In `Replace` mode you replacing the text character-by-character.

## Normal mode

### Moving

#### Move by 1 character, just like arrow keys

- `h` - Left.
- `j` - Down.
- `k` - Up.
- `l` - Right.

Vim do remember the position on the cursor when you switching the lines up and down. If there are enough characters on the line, the cursor will be placed on the same position, else, it will be placed on the end of line.

{%
    include image.html
    url="/assets/tools/vim-commands/move_hjkl.gif"
    description="Moving with `hjkl`"
%}

These commands are placed especially for 10 fingers typing format, they are the fastest you can type. Also, you can move the cursor with arrow keys, but it will take a lot of your time and slow your editing because you will always move your hand to the arrow keys.

#### Word movement

- `w` - Move the cursor forward one word. Moves to the start of the word. If the current word is the last word of a line, moves you to the first word in the next line. Much faster when moving through paragraphs than `l`.
- `b` - Move backward to the start of the previous word. If the current word is the first word of a line, moves you to the start of the last word of a previous line.
- `e` - Move to the next end of a word.
- `ge` - Move to the previous end of a word.

{%
    include image.html
    url="/assets/tools/vim-commands/move_word.gif"
    description="Move by words with `w` and `b` commands"
%}

#### Move by white-space separated WORDs

In Vim, the word ends with a non-word character, so you may want to move through white-spaces. These are called `WORDs` (case-sensitive).

- `W` - Move to the start of next word.
- `B` - Move to the start of a previous word.
- `E` - Move to the next end of a word.
- `gE` - Move to the previous end of a word.

{%
    include image.html
    url="/assets/tools/vim-commands/move_white_space_word.gif"
    description="Move by WORDs with `W` and `B` commands"
%}

#### Moving to the start or end of a line

- `$` - Moves the cursor to the end of a line. Also works with keyboard `<End>` key. Works with numbers, for example `2$` moves to the end of the next line.
- `^` - Moves the cursor to the first non-blank character of a line. 
- `0` - Moves the cursor to the start of a line.

{%
    include image.html
    url="/assets/tools/vim-commands/move_start_end_line.gif"
    description="Moving to the end of line with `$` command, and then to the non-blank beginning of the line with `^` command"
%}

#### Moving to a character

- `f` - Find. Single-character search forward in the line. Works with numbers.
- `F` - Find backwards.
- `t` - To. Stops one character before the searched character forward in the line.
- `T` - To backwards.

These commands can be repeated with `;`. `,` repeats in the other direction.

{%
    include image.html
    url="/assets/tools/vim-commands/find_character.gif"
    description="Example with `fo` and `;` commands. Think of this like: `Find character o, find the next character o and do it again`."
%}

#### Matching a parenthesis

- `%` - Moves to a matching parenthesis, works with `()`, `[]` and `{}`.

{%
    include image.html
    url="/assets/tools/vim-commands/parenthesis.gif"
    description="Matching parenthesis with `%` command"
%}

### Using a count

Many command can be used with numbers. For example: 
- `9x` - Deletes 9 characters.
- `9k` - Moves 9 lines up.
- `9w` - Moves through 9 words.

{%
    include image.html
    url="/assets/tools/vim-commands/count.gif"
    description="Using a count with `d` command. Here we do the `d3w` command, which deletes 3 words"
%}

It is important to know where to put the count number. For example: the command `3dw` deletes one word three times and the command `d3w` deletes three words once. Also, it is possible to put two counts, like the command `3d2w`, which deletes two words three times, for a total of six words.

### Scrolling

It is boring to scroll with `jk` commands by one line. So there are much commands to make it easier in Vim.

#### Scroll the screen

- `CTRL-U` - Scroll half of a screen up.
- `CTRL-D` - Scroll half of a screen down.
- `CTRL-E` - Scroll one line up.
- `CTRL-Y` - Scroll one line down.
- `CTRL-F` - Forward. Scroll one screen up.
- `CTRL-B` - Backward. Scroll one screen down.

#### Scroll to cursor position

- `zz` - Center the screen on cursor line.
- `zt` - Make a cursor line on top of a screen.
- `zb` - Make a cursor line on top of a screen.

{%
    include image.html
    url="/assets/tools/vim-commands/center_to_cursor.gif"
    description="Centering the screen to the cursor position with `zz` command."
%}

### Jumping

When use jumping, Vim remebers the position before the jump. You can jump back using ``` `` ```. If you type this again you will jump back to the search, because the vim remebers this jump too. When you use searching, Vim also jumps to the matches.

I enabled the `:set number` feature to demonstrate line numbers when jumping to lines.

- `:jumps` - Command that gives a list of positions you've jumped to.
- `CTRL-O` - Jump back.
- `CTRL-I` - Jump forward.

#### Jumping to a specific line

- `<Count>G` - Jump to a `<Count>` line.
- `gg` - Jump to the start of a file.
- `G` - Jump to the end of a file.
- `<COUNT>%` - Percent jumping. Jump to `<COUNT>` percent of a file.
- `H` - Home. Jump to the start of a visible area.
- `M` - Middle. Jump to the middle of a visible area.
- `L` - Last. Jump to the end of a visible area.

{%
    include image.html
    url="/assets/tools/vim-commands/jump_line.gif"
    description="Jumping on the ninth line with `9G` command. Then, we do jump to the start of a file with `gg` and to the end of the file with `G` commands."
%}

#### Named marks

You can set up to 26 marks by using command `m<letter>`

- ``` `<mark> ``` - Move to a mark.
- `'<mark>` - Move to a begging of the marks line.
- `:marks` - Get list of marks.

{%
    include image.html
    url="/assets/tools/vim-commands/using_named_mark.gif"
    description="Using named marks. We make a mark named `a` with `ma` command. Then, we can jump to that mark with ``a` command."
%}

#### Special marks

- ``` `` ``` - Cursor position before doing a jump.
- `''` - Cursor position when last editing the file.
- `[` - Start of the last change.
- `]` - End of the last change.

### Searching

> Note: The searching feature uses `Regular Expressions` in its work. The characters .*[]^%/\?~$ have special meanings.  If you want to use them in a search you must put a \ in front of them.

#### Search forward

- `/include` - Search for a word "include" after the cursor.
- `n` - Move to next match. Works with numbers.

#### Search backward

- `?word` - Search for a word "word" before the cursor.
- `N` - Move to the previous match. Works with numbers.

{%
    include image.html
    url="/assets/tools/vim-commands/search_forward_backward.gif"
    description="Search for the word `void` with `/void` command. Jumping to the next and previous matches with `n` and with `N` commands respectively."
%}

#### Search history

Let's imagine you have search for these patterns:

- "/one"
- "/two"
- "/three"

You can use `<UP>` and `<DOWN>` arrow keys to move through the search history. Works with patterns, for example `/o<UP>` can move you to "/one".

{%
    include image.html
    url="/assets/tools/vim-commands/search_history.gif"
    description="Using search history with arrow keys."
%}

#### Searching for a word in the text

To demonstrate this feature I used `:set hlsearch` setting to highlight all matches when searching.

- `*` - Grabs a whole word under the cursor and use it as the search string. Searches only the same word.
- `#` - Same but in the other direction.
- `g*` - Grabs a whole word and uses it as the search string. Matches the partial words.
- `g#` - Same but in the other direction.

{%
    include image.html
    url="/assets/tools/vim-commands/search_word.gif"
    description="Searching for a specific word with `*` command."
%}


There are some special markers which do specify a search:

- `\>` - Special marker that matches only at the end of a word.
- `\<` - Special marker that matches only at the begin of a word.

### Deleting

- `dl` = `x` - Delete 1 character under the cursor, the cursor stays at its place. Works with numbers.
- `dh` = `X` - Delete character left of the cursor.
- `dd` - Delete a line, move you up 1 line.
- `J` - Delete a line break. Joins 2 lines together.
- `dw` - Delete word. Doesn't delete next first word character.
- `de` - Delete word and set cursor on the end of that word.
- `d$` = `D` - Delete from the cursor to the end of the line.
In fact, `d` command may be followed by any motion command, and it deletes from the current location to the place where the cursor winds up. Also, the `d` command works with number.

{%
    include image.html
    url="/assets/tools/vim-commands/deleting.gif"
    description="Using `d` command with several behaviour. Here we delete 5 character with `x` command repeated 5 times. Then, we deleted a word with `dw` command. Then, we deleted a WORD with `dW` command. And finally, we deleted the line with `dd` command."
%}

### Changing

Operator `c` is reffered to "Change". It works just like the `d` operator, except it leaves you in Insert mode. Works with numbers.

- `cl` = `s` - Change one character.
- `cw` - Change word. Deletes a word and then puts you in Insert mode. It works as `ce` command, change to end of word, and doesn't move you to the next word. It is an exception in Vim that dates to the old Vi.
- `cc` = `S` - Changes a whole line.
- `c$` = `C` - Changes from a cursor to the end of line. Works like `dd` and then `a` commands.

### Change case

You can use `~` to change the case of character under the cursor.

{%
    include image.html
    url="/assets/tools/vim-commands/change_case_character.gif"
    description="Changing a single character case with `~` command."
%}

### Replace one character

We can replace one character without using a `cl` or `s` commands, which do enter us in Insert mode. It can be done without entering an Insert mode with `r` command.

- `rx` - Replace current character with x.
- `r<Enter>` - Replace a character with a line break.

{%
    include image.html
    url="/assets/tools/vim-commands/replacing_one_character.gif"
    description="Replacing the character `x` with `ro` command."
%}

### Find and replace

You can find and replace text using the `:s` command. It has a behaviour like a UNIX `sed` command. The syntax is similar too.

```
:[range]s/{pattern}/{string}/[flags] [count]
```

The command searches each line in `[range]` for a `{pattern}`, and replaces it with a `{string}`. `[count]` is a positive integer that multiplies the command.

- `:s/foo/bar/` - Replace the first occurrence of the string "foo" in the current line with "bar".
- `:s/foo/bar/g` - Replace all occurrences of the string "foo" in the current line with "bar".
- `:%s/foo/bar/g` - Replace all occurrences of the string "foo" in the entire file with "bar".

{%
    include image.html
    url="/assets/tools/vim-commands/search_and_replace.gif"
    description="Using `:s` command to search and replace all occurrences of the string `foo` with `bar`."
%}

### Repeating a change

The `.` command is one of the most simple yet powerful commands in Vim. It repeats the last change done. The command works for all changes you make, except for the undo, redo and `:commands`.

For example: find and change the word "four" to word "five" several times

- `/four` - Find the first string "four".
- `cwfive<Esc>` - Change the word to "five".
- `n` - Find the next "four".
- `.` - Repeat the change to "five".
- `n` - Find the next "four".
- `.` - Repeat the change to "five".

{%
    include image.html
    url="/assets/tools/vim-commands/repeating_a_change.gif"
    description="Searching for word `foo`, then changing the word to `bar` and then repeating the change with `n` and `.` commands."
%}

### Undo and Redo

- `u` - Undo the last edit.
- `Ctrl-R` - Redo, reverse the preciding command. It undoes the undo.
- `U` - Undo line. Undoes all the changes made on the last line that was edited.

{%
    include image.html
    url="/assets/tools/vim-commands/undo.gif"
    description="Deleting a word `System` with `dt.` command and then undo the delete."
%}

### Copying

The `y` (yanking) operator copies text into a register. Then a `p` command can be used to put it.

- `yw` - Yank a word. Note that it includes the white space after a word.
- `yy` = `Y` - Yank a whole line.
- `y$` - Yank from the cursor to the end of line.

### Putting

When you delete something, the text is saved in the register. You can paste it back by using the `p` command. You can repeat putting. The same text will be used.

- `p` - Put. Paste after the cursor.
- `P` - Paste before the cursor.

You can use `xp` command to swap the left character with the right character.

### Copy-pasting from clipboard

To use clipboard with Vim you have to prepend `"*` before the yank and put commands.

- `"*yy` - Copy the whole line to the clipboard.
- `"*p` - Put text from the clipboard.

### Finding help

To get help we can use a special command `:help` with specified subject. The usage examples below:

- `:help {subject}` - The structure of help command.
- `:help` - Enters help files. `ZZ` to exit, in this case the command does not exit Vim.
- `:help x` - Get help on the `x` command.
- `:help :command` - Get help on specific command.
- `:help CTRL-<character>` - Get help on control character.

#### Helpgrep

Searches for pattern in whole text of all help files. Jumps to the first match.

- `:helpgrep pattern` - The command syntax. 
- `:cn` - Jump next match.
- `:cprev` or `:cN` - Jump previous match.

### Getting out

![Typical exit vim meme](/assets/tools/vim-commands/exit_vim.jpeg){:height="600px" width="400px"}

- `ZZ` - Writes the file and exits.
- `:q!` - The quit-and-throw-things-away command. Doesn't write changes and exits. `:q` will throw an error when the changes exist.
- `:e` - Reloads the file without saving changes. Doesn't quit, continue editing.

## Insert mode

The Insert mode interprets all typed keys as a text. Press `i` to enter the insert mode. Press `<Esc>` to back to the normal mode.

### Inserting 

All commands in this section do enter the Insert mode.

- `i` - Before current character.
- `I` - Before the first character at the first word in the line.
- `a` - After current character.
- `A` - At the end of line.

#### Opening up a new line

- `o` - Creates new line below the cursor.
- `O` - Creates new line above the cursor.

{%
    include image.html
    url="/assets/tools/vim-commands/insert_mode_new_line.gif"
    description="Entering Insert mode with creating a new line above the cursor with `O` command, then creating a new line below the cursor with `o` command."
%}

## Visual mode

The Visual mode selects and highlights the text, which then can be processed with operator. Press `v` to enter the Visual mode. Press `Esc` to go back to the Normal mode. 

### Entering Visual mode

- `v` - Just enter Visual mode.
- `V` - Enter selecting lines mode. Left-right moves do nothing, moves up and down selecting the whole lines.
- `CTRL-V` - Enter selecting blocks mode. Useful for tables.

{%
    include image.html
    url="/assets/tools/vim-commands/visual_mode.gif"
    description="Entering visual mode with `v` command, selecting the text and changing it with `c` command."
%}

### Change case

You can use `~` to change the case of selected characters.

{%
    include image.html
    url="/assets/tools/vim-commands/change_case_line.gif"
    description="Selecting the whole line with `V` command and then changing the case for all characters in a line with `~` command."
%}

### Change the end of the selection

- `o` - Moves cursor to the other direction in the whole selected text.
- `O` - Moves cursor to the other direction in the selected line (does not impact on the selected text/block).

{%
    include image.html
    url="/assets/tools/vim-commands/visual_change_end.gif"
    description="Changing the end of the selection in visual mode with `o` command."
%}

## Replace mode

The `R` command causes Vim to enter replace mode. In this mode, each character you type replaces the one under the cursor. It automaticly extends the line if it runs out of characters to replace.

- `R` - Enter replace mode.
- `<Insert>` - Switch between Insert mode and Replace mode.
- `<BS>` - Undo the replace of the last character.

{%
    include image.html
    url="/assets/tools/vim-commands/replace_mode.gif"
    description="Using replace mode."
%}

## Conclusion

Today I showed you basic commands in Vim. I'm going to explore it much more and in the next post we will explore the settings and configurations of Vim. 

Thank you for reading, I hope it was useful for you ❤️