# ginh.sh

[![Codacy Badge](https://api.codacy.com/project/badge/Grade/b6429fde76ae4e529ec53f6ee613fcea)](https://app.codacy.com/app/crclark96/ginh?utm_source=github.com&utm_medium=referral&utm_content=crclark96/ginh&utm_campaign=Badge_Grade_Dashboard)
![no.](https://img.shields.io/github/last-commit/crclark96/ginh.svg?style=popout)
![no.](https://img.shields.io/github/languages/top/crclark96/ginh.svg?colorB=purple&style=popout)


ginh is not a histogram

## Usage

```
Usage: `ginh [-h] [-a] [-n entries] [-f hist_file] [-c chart_char] [-l line_len]`

`ginh` generates a bar chart of your most frequently used shell commands,
according to your shell's history file.

Options:
  -a            disable reversing aliases to find the command they reference
  -n NUM        number of entries to include in the chart, default $num_entries
  -f FILE       history file use, default determined by the calling shell
  -c CHAR       character to use for chart bars, default '='
  -l NUM        width of chart, default width of terminal

Miscellaneous:
  -h            display this help message and exit
  -d            print useful debug info
```

Example:

```
entries=15, file=/Users/crclark/.bash_history, char==, len=78
-------------------------------------------------------------------------------
      git =================================================================  40
      cat ==================================  21
      vim =========================  15
       ls ====================  12
./ginh.sh ===============  9
       cd ============  7
       mv ==========  6
      sed =========  5
     echo =========  5
       rm =======  4
     find =======  4
  history =====  3
   export ====  2
      env ====  2
 diskutil ====  2
-------------------------------------------------------------------------------
```

## Installation

### From source

```
git clone https://github.com/crclark96/ginh.git
cd ginh
sudo make install
```

### From packages

#### Debian

Debian packages are available [here](https://github.com/crclark96/ginh/releases).

#### Arch

[Install ginh through the Arch User Repositores](https://aur.archlinux.org/packages/ginh/)

## Help

if you don't see your graph updating after running a few commands, this is
because the working history is stored in memory, and not the history file.
running `history -a` should update the history file and you'll be good to
go!
