# cmd_historgram.sh

usage: `./cmd_historgram.sh [-h] [-n entries] [-f hist_file] [-c chart_char] [-l line_len]`

`cmd_historgram.sh` generates a bar chart of your most frequently used shell commands,
according to your `.bash_history` file (or another file of your choosing, using the `-f`
flag). 

example:

```
crclark@tackbox:cmd_historgram (master *%)$ ./cmd_historgram.sh
entries=15, file=/Users/crclark/.bash_history, char==, len=80
---------------------------------------------------------------------------------
=================================================================================  258 ls
======================  68 vim cmd_historgram.sh
==================  56 ./cmd_historgram.sh
=========  28 ssh cpeg671
=========  26 cd /tmp
========  24 cd ..
=======  22 git status
=======  20 ssh fbctf
======  18 docker ps -a
=====  16 ssh hoek
=====  16 python
=====  13 docker images
=====  13 diskutil eject /Volumes/backup2/
===  9 nc localhost 8000
===  8 vim hw5.txt
---------------------------------------------------------------------------------
```
