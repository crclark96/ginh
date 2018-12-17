# cmd_historgram.sh

usage: `./cmd_historgram.sh [-h] [-n entries] [-f hist_file] [-c chart_char] [-l line_len]`

`cmd_historgram.sh` generates a bar chart of your most frequently used shell commands,
according to your `.bash_history` file (or another file of your choosing, using the `-f`
flag). 

example:

```
crclark@tackbox:cmd_historgram (master *%)$ ./cmd_historgram.sh
entries=15, file=/Users/crclark/.bash_history, char==, len=90
-------------------------------------------------------------------------------------------
                 ls ==================================================================  295
                 cd ===============================================  213
                vim ==================================  152
                ssh ==========================  116
             docker ==========================  115
                git =========================  109
./cmd_historgram.sh ====================  90
             python =============  57
                cat ===========  49
                 nc ===========  47
                scp =========  39
               find ========  34
               echo ========  34
                 rm =======  28
               open ======  25
-------------------------------------------------------------------------------------------
```

## help

if you don't see your graph updating after running a few commands, this is 
  because the working history is stored in memory, and not the history file.
  running `history -a` should update the history file and you'll be good to 
  go!
