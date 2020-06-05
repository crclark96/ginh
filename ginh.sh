#!/bin/bash

declare -a filters
line_len=$(($(/usr/bin/tput cols) - 2)) # get terminal width
num_entries=15
chart_char='='
OPTIND=1 # reset getopts
ppid=$PPID

zsh_extended_filter_string="^:[0-9 ]*:[0-9];"
fish_filter_string="^\\- cmd: "
sudo_filter_string="^sudo "

# define colors
white="\033[1;37m"

nocolor='\033[0m' # no color

function debug() {
  echo "commit: $(git rev-parse HEAD)"
  echo "uname: $(uname -a)"
  get_shell
  echo "shell: $shell"
  get_history_file
  echo "histfile: $histfile"
}

function show_help() {
  echo "\
Usage: $0 [-h] [-d] [-a] [-n entries] [-f hist_file] [-c chart_char] [-l line_len]
$0 generates a bar chart of your most frequently used shell commands.

Options:
  -a            disable reversing aliases to find the command they reference
  -n NUM        number of entries to include in the chart, default $num_entries
  -f FILE       history file use, default determined by the calling shell
  -c CHAR       character to use for chart bars, default '='
  -l NUM        width of chart, default width of terminal

Miscellaneous:
  -h            display this help message and exit
  -d            print useful debug info

Report bugs to: https://github.com/crclark96/ginh/issues"
}

function err() {
  echo "$1"
  exit 1
}

function separator() {
  for (( n=0; n<=line_len; n++ ))
  do
    # shellcheck disable=SC2059
    printf "${white}-${nocolor}"
  done
  printf "\\n"
}

# generic shell formatting filter
function shell_filter() {
  if grep -E "$2" <<< "$1" >/dev/null; then
    grep -E "$2" <<< "$1" \
      | sed -e "s/$2//g"
  else
    echo "$1"
  fi
}

# if match fish history format, remove fish formatting
function fish_filter() {
  shell_filter "$1" "$fish_filter_string"
}

# if match zsh_extended history format, remove zsh_extended formatting
function zsh_extended_filter() {
  shell_filter "$1" "$zsh_extended_filter_string"
}

# remove 'sudo's
function sudo_filter() {
# shellcheck disable=SC2001
  sed -e "s/$sudo_filter_string//g" <<< "$1"
}

# use alias command to reverse aliases found in history
function reverse_aliases_filter() {
  if [ "$shell" == "fish" ]; then
    flags="c"
  else
    flags="ci"
  fi
  # compiles a slew of sed substitution commands, e.g.
  # s/alias_name/command_name/g
  sed_replacements=$($shell -$flags \'alias\' \
    | grep -v "/" \
    | grep -v "='nocorrect" \
    | tr "=" " " \
    | grep -E -o "[[:alnum:]]+ '.*'" \
    | tr -d \"\'\(\)\{\" \
    | tr -d \"\\\\\" \
    | sed -E -e 's|([^[:space:]]+) |\1\\\\>\||' \
    | awk -F "|" 'BEGIN { OFS = FS }{print $1, $2}' \
    | xargs -I _ echo s\|\\\<_\|g\;\ \
    | tr -d "\n")
  sed -e "$sed_replacements" <<< "$1"
}

# get command name, sort, and count
function final_filter() {
  awk '{print $1}' <<< "$1" \
    | sort \
    | uniq -c \
    | sort -rn
}

# check the shell used to instantiate ginh
function get_shell() {
  shell=$(ps -p $ppid -o comm= | sed -e 's/^-//')
  if [ -z "$shell" ]; then
    err "unable to autodetect shell, try specifying a file using -f"
  fi
}

# get location of history file for the shell used to instantiate ginh
function get_history_file() {
  get_shell
  if [ "$shell" == "fish" ]; then
    # fish history cannot be changed, determine location based on version
    fish_version="$(fish -v | awk '{print $3}')"
    if version_gt "$fish_version" "2.3.0"; then
      histfile="$HOME/.local/share/fish/fish_history"
    else
      histfile="$HOME/.config/fish/fish_history"
    fi
  else
    histfile=$($shell -ci "echo \$HISTFILE")
  fi
  if [ -z "$histfile" ]; then
    err "unable to autodetect history file, try specifying a file using -f"
  fi
}

# test if the first argument is greater than the second argument,
# following versioning logic
function version_gt() {
  test "$(sort -V <<< "$@" | head -n 1)" != "$1"
}

while getopts "h?dan:f:c:l:t:" opt; do
  case "$opt" in
  h|\?)
    show_help
    exit 0
    ;;
  d)
    debug
    exit 0
    ;;
  n)
    num_entries=$OPTARG
    ;;
  f)
    histfile=$OPTARG
    alias=0
    ;;
  c)
    chart_char="$OPTARG"
    ;;
  l)
    line_len=$OPTARG
    ;;
  t)
    ppid=$OPTARG
    ;;
  a)
    alias=0
    ;;
  esac
done

shift $((OPTIND-1))

[ "${1:-}" = "--" ] && shift

if [ -z "$histfile" ]; then
  get_history_file
fi

filters+=("fish_filter")
filters+=("zsh_extended_filter")
if [ ! "$(uname | grep Darwin)" ]; then
if [ -z $alias ]; then
  filters+=("reverse_aliases_filter")
fi
fi
filters+=("sudo_filter")
filters+=("final_filter")

calc=$(grep -v -E '^\s*$|^\s+' "$histfile")
for (( n=0; n<${#filters[@]}; n++ )); do
  calc=$(${filters[n]} "$calc")
done

./chart -n "$num_entries" -c "$chart_char" -l "$line_len" <<< "$calc"
