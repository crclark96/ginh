#!/bin/bash

declare -a COUNTS FREQ CMDS
LINE_LEN=`expr $(/usr/bin/tput cols) - 2` # get terminal width
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
  CMDS[$N]=$(cat $HISTFILE | awk '{print $1}' | sort | uniq -c | sort -n | tail -n `expr $N + 1` | head -n 1)
  COUNTS[$N]=$(echo ${CMDS[$N]} | awk '{print $1}')
  S=$(echo ${CMDS[$N]} | cut -d' ' -f2-)
  MAX_LEN=$((
  ${#S} > $MAX_LEN ?
    ${#S}:
    $MAX_LEN
  ))
done

MAX_LEN=$(($MAX_LEN + 1))

for (( N=0; N<=`expr $NUM_ENTRIES - 1`; N++ ))
# calculate frequencies
do
  (( FREQ[N]=COUNTS[N] * `expr $LINE_LEN - $MAX_LEN - ${#COUNTS[0]} - 2` / COUNTS[0] ))
done

separator

for (( N=0; N<=`expr $NUM_ENTRIES - 1`; N++ ))
do
  S=$(echo ${CMDS[$N]} | cut -d' ' -f2-)
  for (( M=0; M<=MAX_LEN-${#S} - 2; M++ ))
  do
    printf " "
  done
  printf "%s " $(echo ${CMDS[$N]} | cut -d' ' -f2-)
  
  for (( M=0; M<=FREQ[$N]; M++ ))
  do
    printf "$CHART_CHAR"
  done
  printf "  "
  printf "%s" $(echo ${CMDS[$N]} | awk '{print $1}')
  
  printf "\n"
done

separator

