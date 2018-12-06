#!/bin/bash

declare -a COUNTS FREQ CMDS
LINE_LEN=80
NUM_ENTRIES=15
CHART_CHAR='='
HISTFILE="$HOME/.bash_history"
OPTIND=1 # reset getopts
MAX_LEN=0

function show_help {
  echo "usage: $0 [-h] [-n entries] [-f hist_file] [-c chart_char] [-l line_len]"
}

function separator {
  for (( N=0; N<=$LINE_LEN; N++ ))
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
    NUM_ENTRIES=$OPTARG
    ;;
  f)
    HISTFILE=$OPTARG
    ;;
  c)
    CHART_CHAR="$OPTARG"
    ;;
  l)
    LINE_LEN=$OPTARG
    ;;
  esac
done

shift $((OPTIND-1))

[ "${1:-}" = "--" ] && shift

echo "entries=$NUM_ENTRIES, file=$HISTFILE, char=$CHART_CHAR, len=$LINE_LEN"


for (( N=0; N<=$NUM_ENTRIES; N++ ))
# gather counts and cmds
do
  CMDS[$N]=$(cat $HISTFILE | sort | uniq -c | sort -n | tail -n `expr $N + 1` | head -n 1)
  COUNTS[$N]=$(echo ${CMDS[$N]} | awk '{print $1}')
  MAX_LEN=$((
  ${#CMDS[$N]} > MAX_LEN ?
    ${#CMDS[$N]}:
    MAX_LEN
  ))
done

for (( N=0; N<=`expr $NUM_ENTRIES - 1`; N++ ))
# calculate frequencies
do
  (( FREQ[N]=COUNTS[N] * LINE_LEN / COUNTS[0] ))
done

separator

for (( N=0; N<=`expr $NUM_ENTRIES - 1`; N++ ))
do
  for (( M=0; M<=FREQ[$N]; M++ ))
  do
    printf "$CHART_CHAR"
  done
  printf "  "
  printf "%s " ${CMDS[$N]}
  printf "\n"
done

separator

