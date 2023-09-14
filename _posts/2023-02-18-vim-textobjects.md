---
layout: post
title: Vim Text Objects
category: Tools
tags: vim editing productivity
date: 2023-02-18 09:04 +0300
---

Hi! Today I want to demonstrate a very powerful Vim feature - text objects. These objects make work with basic entities, like words, sentences or even paragraphs, much more effective.

## Introduction

For example, imagine you have a text with several sentences, like the one below. You can copy and paste this text for testing.

```plaintext
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent consequat gravida ante fermentum fringilla. Integer vulputate tincidunt euismod. Donec ornare malesuada nisi sit amet blandit. Curabitur quis interdum risus. Proin mattis placerat justo, ut luctus ante tristique sit amet. Pellentesque nulla nisi, placerat id enim id, venenatis sagittis enim. Proin ut accumsan dui. 
```

Let's suppose you want to select, delete, or change the second and the third sentences in this text. You can do it manually with your mouse, or by movin with Vim, but you can do it much easier with an operator, like `v` for visual mode and `2as` command.

{%
    include image.html
    url="/assets/tools/vim-textobjects/selecting_2_sentences.gif"
    description="Selecting 2 sentences with `v2as` command."
%}

## an object or inner object

The feature has 2 modes: `a` for "an" object and `i` for "inner" object. When using the "a" command, it will select an object with whitespace after it. The "i" command does select only the inner object without whitespace. Thus the "i" commands always select less text than the "a" commands. Focus on the cursor in the example below.

{%
    include image.html
    url="/assets/tools/vim-textobjects/an_and_inner.gif"
    description="The difference between `an` and `inner` commands. The command `vas` used in the first selecting, and the command `vis` used in second."
%}

## Text objects

### word

A word consists of a sequence of letters, digits and underscores, separated with white space.

- `aw` - A word. Includes leading and trailing whitespace, but not counts them as words (for using with number, like "3aw).
- `iw` - Inner word. Counts whitespace between words as words. For example, selecting 3 words with "3iw" command will select 2 words and a whitespace between them.

{%
    include image.html
    url="/assets/tools/vim-textobjects/word.gif"
    description="Selecting 3 words with `v3aw` command, then selecting 2 words and whitespace between them with `v3iw` command."
%}

### WORD

A WORD consists of a sequence of non-blank characters, separated with white space.  An empty line is also considered to be a WORD.

- `aW` - A WORD. Includes leading and trailing whitespace, but not counts them.
- `iW` - Inner WORD. Does not include leading and trailing whitespace, count whitespace between WORDs.

{%
    include image.html
    url="/assets/tools/vim-textobjects/big_word.gif"
    description="Selecting a WORD with `vaW` command."
%}

### Sentence

A sentence in Vim is some text ending at a ".", "!" or "?", followed by end of line or whitespace.

- `as` - A sentence. Includes leading and trailing whitespace, but not counts them.
- `is` - Inner sentence. Counts whitespace between sentences.

{%
    include image.html
    url="/assets/tools/vim-textobjects/sentence.gif"
    description="Selecting a sentence with `vas` command. Then, selecting inner sentence with `vis` command."
%}

### Paragraph

A paragraph begins after each empty line and ends at empty line. Splitted with end of line lines are parts of the paragraph too.

- `ap` - A paragraph. Includes whitespace, but not counts it.
- `ip` - Inner paragraph. Counts whitespace.

{%
    include image.html
    url="/assets/tools/vim-textobjects/paragraph.gif"
    description="Selecting first paragraph with `vap` command and then selecting next paragraph with `ap` command."
%}

## Block text objects

The second type of text objects is blocks. We can select matching parentheses, quotes and even tags in Vim. 

The behavior is different there. The "a" command selects the block, including matching block endings, for example: matching parentheses "()". The "i" command selects the block, excluding matching block endings. 

The basic blocks are:

- `()` block.
- `[]` block.
- `{}` block.
- `<>` block.

{%
    include image.html
    url="/assets/tools/vim-textobjects/basic_block.gif"
    description="Selecting a matching parenthesis block, including parentheses, with `va)` command and selecting a parenthesis block, excluding parentheses, with `vi)` command."
%}

### blocks

There is an alias for parenthesis "()" block - "b".

- `ab` - A block. Select entire matching parentheses, including the parentheses.
- `ib` - Inner block. Select entire matching parentheses, excluding the parentheses.

### Blocks

There is an alias for curly brackets "{}" block - "B".

- `aB` - A block. Select entire matching parentheses, including the parentheses.
- `iB` - Inner block. Select entire matching parentheses, excluding the parentheses.

### Tags

The tags work like the HTML and XML tag blocks. The normal method for it is to select a `<tag>` until the matching `</tag>`.

- `at` - A tag block. Select an entire block, including tags themselves.
- `it` - Inner tag block. Select the inner of the block, excluding tags themselves.

{%
    include image.html
    url="/assets/tools/vim-textobjects/tags.gif"
    description="Selecting entire HTML tag with `vat` command and then selecting the inner of the tag with `vit` command."
%}

In HTML it is possible to have a tag like `<br>` or `<meta ...>` without a matching end tag. These are ignored.

### Quoted strings

There are 3 types of quoted strings supported there:

- `"` - Double quotes.
- `'` - A single quote.
- ``` ` ``` - A backtick.

The "a" command selects a text from previous quote until the next quote, including the quotes themselves. The "i" command does the same, but doesn't include the quotes. It only works within one line.

{%
    include image.html
    url="/assets/tools/vim-textobjects/quoted_strings.gif"
    description="Selecting a quoted string and inner quoted string with `va` and `vi` commands."
%}

There is an option to make it work with escaped quotes - `quoteescape`. It makes Vim to not include escaped quotes when searching for the matching quote of the string.

{%
    include image.html
    url="/assets/tools/vim-textobjects/escaped_quotes.gif"
    description="Selecting a quoted string with escaped quoted. The `quoteescape` enabled here."
%}

## Conclusion

Today we understood how we can move, select and work with Vim objects. Spend some time to test this feature and see how it can improve your editing efficiency. I'm going to explore and share with you more features of Vim later!

Thank you for reading, I hope it was useful for you ❤️
