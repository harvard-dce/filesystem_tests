#!/bin/bash

filesystem="$1"
runtime=$(date +"%s")

total_ram=$(grep MemTotal /proc/meminfo | awk -F' ' '{print $2}')
optimal_file_size=$(echo "($total_ram / 1024) * 2" | bc)
bonnie_exe=$(which bonnie++)

if [ -z "$bonnie_exe" ]; then
  bonnie_exe="/usr/sbin/bonnie++"
fi

if [ -z "$filesystem" ]; then
  echo 'Please define a root filesystem to test by passing it to this script'
  exit 1
fi

if [ ! -d "$filesystem" ]; then
  echo "That directory doesn't exist. Please give us another."
  exit 1
fi

test_root="$filesystem/bonnie_tests"
mkdir -p "$test_root"

trap "echo; echo \"Be sure to remove the $test_root directory\"; exit" INT TERM

command="$bonnie_exe -s ${optimal_file_size}M -d $test_root -f -n 0"
echo "Running: $command"
$command > benchmark-$runtime.txt

rm -Rf "$test_root"


