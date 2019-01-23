#!/bin/bash

declare -a counts freq cmds
line_len=`expr $(/usr/bin/tput cols) - 2` # get terminal width
num_entries=15
chart_char='='
# Get the calling shell
shell=$(ps -o comm=$PPID | grep $(echo $0 | cut -d"/" -f2-) -B 1 | head -1)
histfile=$($shell -ci "echo \$HISTFILE")
OPTIND=1 # reset getopts
max_len=0

# check for zsh extended history format style
$shell -ci "setopt" |& grep extendedhistory >/dev/null
zsh_extended_history=$(expr 1 - $?)

function show_help {
  echo "usage: $0 [-h] [-n entries] [-f hist_file] [-c chart_char] [-l line_len]"
}

function separator {
  for (( n=0; n<=$line_len; n++ ))
  do
    printf "-"
  done
  printf "\n"
}

while getopts "h?n:f:c:l:" opt
do
  case "$opt" in
  h|\?)
    show_help
    exit 0
    ;;
  n)
    num_entries=$OPTARG
    ;;
  f)
    histfile=$OPTARG
    ;;
  c)
    chart_char="$OPTARG"
    ;;
  l)
    line_len=$OPTARG
    ;;
  esac
done

shift $((OPTIND-1))

[ "${1:-}" = "--" ] && shift

echo "entries=$num_entries, file=$histfile, char=$chart_char, len=$line_len"

if [ $zsh_extended_history -eq 1 ]
then
  calc=$(grep -v -E '^\s*$|^\s+' $histfile | awk -F ';' '{print $2}' |
    awk '{print $1}' | sort | uniq -c | sort -rn)
else
  calc=$(grep -v -E '^\s*$|^\s+' $histfile | awk '{print $1}' | sort | uniq -c |
    sort -rn)
fi

for (( n=0; n<=$num_entries; n++ ))
# gather counts and cmds
do
  cmds[$n]=$(echo "$calc" | sed -ne "`expr 1 + $n`p")
  counts[$n]=$(echo ${cmds[$n]} | awk '{print $1}')
  s=$(echo ${cmds[$n]} | cut -d' ' -f2-)
  max_len=$((
  ${#s} > $max_len ?
    ${#s}:
    $max_len
  ))
done

max_len=$(($max_len + 1))

for (( n=0; n<=`expr $num_entries - 1`; n++ ))
# calculate frequencies
do
  (( freq[n]=counts[n] * `expr $line_len - $max_len - ${#counts[0]} - 2` / counts[0] ))
done

separator

for (( n=0; n<=`expr $num_entries - 1`; n++ ))
do
  s=$(echo ${cmds[$n]} | cut -d' ' -f2-)
  for (( m=0; m<=max_len-${#s} - 2; m++ ))
  do
    printf " "
  done
  printf "%s " $(echo ${cmds[$n]} | cut -d' ' -f2-)

  for (( m=0; m<=freq[$n]; m++ ))
  do
    printf "$chart_char"
  done
  printf "  "
  printf "%s" $(echo ${cmds[$n]} | awk '{print $1}')

  printf "\n"
done

separator

