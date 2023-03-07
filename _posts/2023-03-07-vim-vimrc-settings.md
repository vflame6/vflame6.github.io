---
layout: post
title: Vim and .vimrc settings
category: Tools
tags: vim editing configuring productivity
date: 2023-03-07 18:58 +0300
---

Hi! In this post we continue exploring Vim and its features. Today we discuss some useful settings (or configuration) in Vim. I don’t think it is a full guide for Vim settings, I’ll show just features that I do use in my work with Vim. To get a full guide you can use vimdoc and Vim Fandom, which is a classic tutorial for Vim.

{%
    include image.html
    url="/assets/tools/vim-vimrc-settings/chatgpt_joke.png"
    description="Skynet will appear faster than we expected..."
%}

# Why customize Vim?

By configuring Vim to match the user's preferences, workflow, and coding style, the editor can be tailored to the user's needs and habits, making it faster and more convenient to use.

Customizing Vim settings can also help to automate repetitive tasks, such as indentation, syntax highlighting, file formatting, and code navigation. This can save the user time and reduce the risk of errors, while improving the consistency and readability of the code.

Furthermore, Vim has a large community of users and developers who share tips, tricks, and plugins that can be used to extend Vim's functionality and customize it even further. By learning how to customize Vim, users can take advantage of this vast ecosystem of resources and improve their editing experience.

# Useful Vim settings

## Displaying and Navigating

These settings affect how text is displayed on the screen, and how the user can navigate through it. The first three settings (`set number`, `set nowrap`, `set cursorline`) control the display of line numbers, disabling line wrapping, and highlighting the current line, respectively. The `set colorcolumn=80` setting highlights the 80th column of each line, which is a common convention for code formatting. The `set scrolloff=10` setting keeps the cursor in the center of the screen while scrolling, which can make it easier to read and navigate through large files.

### number

The `set number` command displays line numbers on the left-hand side of the buffer.

{%
    include image.html
    url="/assets/tools/vim-vimrc-settings/number.gif"
    description="Using `set number` command."
%}

### nowrap

The `set nowrap` command disables line wrapping, which means that long lines will extend past the edge of the screen.

{%
    include image.html
    url="/assets/tools/vim-vimrc-settings/nowrap.gif"
    description="Using `set nowrap` command."
%}

### cursorline

The `set cursorline` command highlights the current line in the buffer.

{%
    include image.html
    url="/assets/tools/vim-vimrc-settings/cursorline.gif"
    description="Using `set cursorline` command."
%}

### colorcolumn

The `set colorcolumn=80` command highlights the 80th column of each line, making it easier to see when lines are longer than the recommended 80 characters.

{%
    include image.html
    url="/assets/tools/vim-vimrc-settings/colorcolumn.gif"
    description="Using `set colorcolumn=80` command."
%}

### scrolloff

The `set scrolloff` command specifies the number of lines that should be kept visible above and below the cursor while scrolling, helping to keep the cursor in the center of the screen.

## Editing Text

These settings control how text is edited in Vim. The first four settings (`set tabstop=4`, `set softtabstop=4`, `set expandtab`, `set shiftwidth=4`) determine how tabs and spaces are used for indentation, and how many spaces are used for each level of indentation. The `set autoindent` setting automatically indents new lines to the same level as the previous line, which can be helpful for maintaining consistent formatting.

### tabstop

The `set tabstop=4` command determines how many spaces a tab character will use when the tab key is pressed.

### softtabstop

The `set softtabstop=4` command specifies how many spaces should be inserted when the <kbd>Tab</kbd> key is pressed.

### expandtab

The `set expandtab` command changes the behavior of the <kbd>Tab</kbd> key to insert spaces instead of tab characters.

### shiftwidth

The `set shiftwidth=4` command specifies how many spaces should be used for indentation when using the <kbd><</kbd> and <kbd>></kbd> commands.

### autoindent

This setting causes Vim to automatically indent new lines based on the indentation of the previous line.

## Searching and Highlighting

These settings control how text is searched for and highlighted in Vim. The `set hlsearch` setting highlights all occurrences of a search term in the current buffer, while the `set incsearch` setting highlights matches as the user types their search term. The `set ignorecase` setting makes searches case-insensitive by default, while the `set smartcase` setting makes searches case-sensitive if they contain uppercase letters. The `set showmatch` setting highlights matching parentheses, which can be helpful for navigating through code.

### hlsearch

The `set hlsearch` command highlights all matches of the current search pattern.

{%
    include image.html
    url="/assets/tools/vim-vimrc-settings/hlsearch.gif"
    description="Searching with `set hlsearch` command enabled."
%}

### incsearch

The `set incsearch` command highlights matches of the current search pattern as you type.

{%
    include image.html
    url="/assets/tools/vim-vimrc-settings/incsearch.gif"
    description="Searching with `set incsearch` setting enabled."
%}

### ignorecase

The `set ignorecase` command causes Vim to perform case-insensitive searches.

### smartcase

The `set smartcase` command makes Vim perform case-sensitive searches if the search pattern contains any uppercase letters.

### showmatch

The `set showmatch` command highlights the matching parentheses or brackets when the cursor is on them, making it easier to identify where a code block ends.

## File Types

These settings enable file type detection, filetype-specific plugins, and syntax highlighting in Vim. The `filetype on` setting enables file type detection, while `filetype plugin on` enables filetype-specific plugins. The `filetype indent on` setting enables indentation rules for specific file types. The `syntax on` setting enables syntax highlighting, which can make it easier to read and understand code.

### filetype

- `filetype on` command tells Vim to detect the file type automatically based on its content. This is useful when editing files with different file types that require different syntax highlighting and indentation.
- `filetype plugin on` command enables filetype-specific plugins that provide additional features and settings for specific file types.
- `filetype indent on` command enables filetype-specific indentation rules that automatically indent code based on the language syntax.

### syntax on

The `syntax on` command enables syntax highlighting in Vim, which colors different parts of the code based on their syntax, making it easier to read and edit.

{%
    include image.html
    url="/assets/tools/vim-vimrc-settings/syntax.gif"
    description="Using `syntax on` command."
%}

## Buffers 

These settings control how Vim handles buffers and navigation between them. The `set hidden` setting allows files to be hidden when switching buffers, which can be useful for keeping the buffer list tidy. The `set wildmenu` setting provides command-line completion for certain commands, and the `set wildmode=list:longest` setting configures tab completion to show the longest common substring of matches. The `set wildignore` setting ignores specific patterns when using tab completion in Vim.

### set hidden

The `set hidden` command allows you to switch between open files without closing them. When a file is hidden, it remains in the background, ready to be switched back to later.

### wildmenu

The `set wildmenu` command provides command-line completion, making it easier to enter commands in Vim. When enabled, the command-line will display a menu of available options as you type. Press a <kbd>Tab</kbd> key, like in a classic shell. 

### wildmode

The `set wildmode=list:longest` command makes the tab completion behave in a way that shows the longest common substring of matches.

### wildignore

The `set wildignore=.docx,.jpg,.png,.gif,.pdf,.pyc,.exe,.flv,.img,.xlsx` command is used to ignore files or directories when using tab completion in Vim. It can be useful for excluding generated files, object files, or backup files.

## User Interface and Behavior

These settings control the behavior of the Vim user interface. The `set nobackup` prevents the creation of backup files. The `set belloff=all` setting turns off all bell sounds. The `set showmode` setting displays the current mode in the status line, which can be helpful for knowing whether the user is in insert mode or command mode. The `set showcmd` setting shows partial commands in progress, which can be helpful for knowing what the user is currently typing. The `set mouse=a` setting enables mouse support in Vim, which can be helpful for navigating through large files.

### set nobackup

The `set nobackup` command prevents Vim from creating backup files when editing files, which can clutter the file system and consume disk space.

### set belloff=all

The `set belloff` command can be used to turn off Vim's bell sounds, which can be distracting when editing text. The all option disables all bells, including visual bells and beeps.

### showmode

The `set showmode` command displays the current mode (insert, visual, command, etc.) in the status line, making it easier to keep track of which mode you are in.

{%
    include image.html
    url="/assets/tools/vim-vimrc-settings/showmode.gif"
    description="We can see the mode we are in when the `set showmode` command enabled."
%}

### showcmd

The `set showcmd` command shows the partial command in progress at the bottom of the screen, making it easier to keep track of what command is being entered.

{%
    include image.html
    url="/assets/tools/vim-vimrc-settings/showcmd.gif"
    description="Using `showcmd` command."
%}

### mouse

The `set mouse=a` command enables mouse support in Vim, allowing you to click on the screen to move the cursor or select text.

{%
    include image.html
    url="/assets/tools/vim-vimrc-settings/mouse.gif"
    description="Using a mouse in Vim with `set mouse=a` setting enabled."
%}

### clipboard

The `set clipboard=unnamedplus` command setting allows Vim to access the system clipboard, making it easier to copy and paste between Vim and other programs. Anything that is yanked or deleted in Vim is automatically added to the system clipboard.

### compatible

The `set nocompatible` command turns off vi compatibility mode, which is enabled by default in Vim. Incompatible mode allows Vim to use more advanced features and settings that are not available in vi.


# vimrc example

`.vimrc` is a configuration file for the Vim editor. It is written in Vim's own scripting language, which is similar to the Ex editor language and supports commands for customizing Vim's behavior, defining mappings, and creating functions. The Vim scripting language also supports the use of variables, loops, conditionals, and expressions, which allow for complex customizations to be made to the editor.

vimrc is located in `$HOME\_vimrc` for Windows and `$HOME/.vimrc` for Linux operating systems. Create this file and add just add some commands in it.

P.S. $HOME is a common Windows environment variable referred to the path `C:\Users\{username}`. $HOME is an environment variable for Linux, it indicates the path to user home directory `/home/{username}`.

You can see the example of that file with all commands described in this article. 

```plaintext
" This is a comment in the .vimrc file
" The following lines configure settings for the Vim editor

" Displaying and Navigating Text

" Display line numbers
set number

" Disables line wrapping
set nowrap

" Highlights the current line
set cursorline

" Highlights the 80th column of each line
set colorcolumn=80

" Keep cursor in the center of the screen while scrolling
set scrolloff=10

" Text editing

" Set the number of spaces a tab character will use
set tabstop=4

" Sets the number of spaces a <Tab> should insert
set softtabstop=4

" Converts tabs to spaces
set expandtab

" Sets the number of spaces to use for indentation
set shiftwidth=4

" Automatically indents new lines
set autoindent

" Searching and Highlighting Text

" Highlights search matches
set hlsearch

" Highlights search matches as you type
set incsearch

" Makes searches case-insensitive
set ignorecase

" Makes searches case-sensitive if they contain uppercase letters
set smartcase

" Highlight matching parentheses
set showmatch

" File Types and Plugins

" Detect file type automatically
filetype on

" Enable filetype-specific plugins
filetype plugin on

" Enable filetype-specific indentation
filetype indent on

" Enable syntax highlighting
syntax on

" Buffers and Navigation

" Allows files to be hidden when switching buffers
set hidden

" Provides command-line completion
set wildmenu

" Configure tab completion to show longest common substring of matches
set wildmode=list:longest

" Ignore specific patterns when using tab completion in Vim
set wildignore=*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx

" User Interface and Behavior

" Creates a backup file for each file edited
set backup

" Displays the current mode in the status line
set showmode

" Allows access to the system clipboard
set clipboard=unnamedplus

" Enables mouse support
set mouse=a

" Turn off all bell sounds
set belloff=all

" Turn off vi compatibility mode
set nocompatible

" Prevent creation of backup files
set nobackup

" Show partial command in progress
set showcmd

" You can add more settings below this line
" ...
```

The `"`, also known as the double quote, is a character that starts a comment in Vim's configuration file, also known as .vimrc. Comments are lines in the file that are not executed as commands, but are instead used to provide context or explain what a particular setting does.

# Conclusion

We’ve explored basic vim configurations to customize Vim in this article. They can improve your work with Vim and make it look better! Take your time to explore these features and make it better for you.

Note that these settings are just the basics, and there are many more settings you can customize in Vim to suit your needs.

Thank you for reading, I hope it was useful for you ❤️
