#!/bin/bash
# don't warn about sourcing non-argument files
#   shellcheck disable=SC1091

source ./ginh.sh

function test_sudo_filter() {
  str0="hello" # no sudo
  str1="hello sudo" # sudo not as first word
  str2="visudo" # sudo within word
  str3="sudoers" # sudo as first word within word
  str4="sudo hello" # sudo as first word
  assertEquals "failed no sudo" "$(sudo_filter "$str0")" "hello"
  assertEquals "failed sudo not first word" "$(sudo_filter "$str1")" "hello sudo"
  assertEquals "failed sudo within word" "$(sudo_filter "$str2")" "visudo"
  assertEquals "failed sudo as first word within word" "$(sudo_filter \
    "$str3")" "sudoers"
  assertEquals "failed sudo as first word" "$(sudo_filter "$str4")" "hello"
}

source ./shunit2
