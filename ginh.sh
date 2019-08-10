#!/bin/bash

declare -a counts freq cmds filters
line_len=$(($(/usr/bin/tput cols) - 2)) # get terminal width
num_entries=15
chart_char='='
OPTIND=1 # reset getopts
max_len=0
ppid=$PPID
alias=1

zsh_extended_filter_string="^:[0-9 ]*:[0-9];"
fish_filter_string="^\\- cmd: "
sudo_filter_string="^sudo "

# define colors
lpurple="\033[1;35m"
lcyan="\033[1;36m"
white="\033[1;37m"

nocolor='\033[0m' # no color

color1=$lcyan
color2=$lpurple

function debug() {
  echo "commit: $(git rev-parse HEAD)"
  echo "uname: $(uname -a)"
  get_shell
  echo "shell: $shell"
  get_history_file
  echo "histfile: $histfile"
}

function show_help() {
  echo "usage: $0 [-h] [-d] [-a] [-n entries] [-f hist_file] [-c chart_char] [-l line_len]"
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
  echo "${1//$sudo_filter_string//}"
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
    | grep -o "\w\+ '\w\+" \
    | tr -d \"\'\(\)\{\" \
    | sed -e 's| |\\\\>\||' \
    | awk '{print $1}' \
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
if [ $alias -eq 1 ]; then
  filters+=("reverse_aliases_filter")
fi
filters+=("sudo_filter")
filters+=("final_filter")

calc=$(grep -v -E '^\s*$|^\s+' "$histfile")
for (( n=0; n<${#filters[@]}; n++ )); do
  calc=$(${filters[n]} "$calc")
done

# choose smaller of requested number of entries and actual number
num_lines=$(wc -l <<< "$calc")
num_entries=$((num_lines < num_entries
                ? num_lines
                : num_entries))

echo "entries=$num_entries, file=$histfile, char=$chart_char, len=$line_len"

for (( n=0; n<num_entries; n++ )); do
# gather counts and cmds
  cmds[n]=$(sed -ne "$((1 + n))p" <<< "$calc") # isolate line n+1
  counts[n]=$(awk '{print $1}' <<< "${cmds[n]}")
  s=$(awk '{print $2}' <<< "${cmds[n]}")
  max_len=$((
  ${#s} > max_len
    ? ${#s}
    : max_len
  ))
done

max_len=$((max_len + 1))

for (( n=0; n<num_entries; n++ )); do
# calculate frequencies
  (( freq[n]=counts[n] * \
    $((line_len - max_len - ${#counts[0]} - 2)) \
    / counts[0] ))
done

separator

for (( n=0; n<num_entries; n++ )); do
  if [[ $((n % 2)) == 0 ]]; then
    color=$color1
  else
    color=$color2
  fi
  s=$(awk '{print $2}' <<< "${cmds[n]}")
  for (( m=0; m<=max_len-${#s} - 2; m++ )); do
    printf " "
  done
  printf "${color}%s${nocolor} " "$(awk '{print $2}' <<< "${cmds[n]}")"

  for (( m=0; m<=freq[n]; m++ )); do
    printf "${color}%s${nocolor}" "$chart_char"
  done

  printf "  "
  printf "${color}%s${nocolor}" "${counts[n]}"

  printf "\\n"
done

separator

