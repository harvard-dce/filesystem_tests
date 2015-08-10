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

benchmark_bonnie() {
  command="$bonnie_exe -s ${optimal_file_size}M -d $test_root -f -n 0"
  echo "Running: $command"
  $command > benchmark-bonnie-$runtime.txt
}

benchmark_a_single_file_of_x_gigabytes() {
  size=$1
  # (dd if=/dev/zero bs=1M count=$[1024*16] status=none | pv -f -a -t -b > "$test_root/large_file.img") > benchmark-dd-$runtime.txt 2>&1
  { time dd if=/dev/zero bs=1M count=$[1024*$size] status=none > "$test_root/large_file.img"; } 2> benchmark-file-of-$size-gig-$runtime.txt
}

benchmark_bonnie
benchmark_a_single_file_of_x_gigabytes 1
benchmark_a_single_file_of_x_gigabytes 16
benchmark_a_single_file_of_x_gigabytes 32
benchmark_a_single_file_of_x_gigabytes 64

rm -Rf "$test_root"
