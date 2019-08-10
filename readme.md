# ginh.sh

[![Codacy Badge](https://api.codacy.com/project/badge/Grade/b6429fde76ae4e529ec53f6ee613fcea)](https://app.codacy.com/app/crclark96/ginh?utm_source=github.com&utm_medium=referral&utm_content=crclark96/ginh&utm_campaign=Badge_Grade_Dashboard)
![no.](https://img.shields.io/github/last-commit/crclark96/ginh.svg?style=popout)
![no.](https://img.shields.io/github/languages/top/crclark96/ginh.svg?colorB=purple&style=popout)


ginh is not a histogram

usage: `./ginh.sh [-h] [-a] [-n entries] [-f hist_file] [-c chart_char] [-l line_len]`

`ginh.sh` generates a bar chart of your most frequently used shell commands,
according to your shell's history file (or another file of your choosing, using
the `-f` flag).

other flags include `-n` for specifying the number of bars, `-c` to select
the character used in each bar, `-l` to change the maximum line length
(bar "height"), and `-a` to treat aliases as first class entries (default
behavior is to revert aliases into their target command).

example:

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

## help

if you don't see your graph updating after running a few commands, this is
  because the working history is stored in memory, and not the history file.
  running `history -a` should update the history file and you'll be good to
  go!
