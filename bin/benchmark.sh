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

test_root="$filesystem/filesystem_tests_tmp"

rm -Rf "$test_root"
mkdir -p "$test_root"

trap "echo; echo \"Be sure to remove the $test_root directory\"; exit" INT TERM

benchmark_bonnie() {
  output="$($bonnie_exe -q -s ${optimal_file_size}M -d $test_root -f -n 0 2> /dev/null)"
  echo "$runtime,$output" >> benchmark-bonnie.txt
}

benchmark_a_single_file_of_x_gigabytes() {
  size=$1
  elapsed_sec=$({ TIMEFORMAT=%R; time dd if=/dev/zero of="$test_root/large_file-$size.img" bs=1M count=$[1024*$size] status=none; } 2>&1 )
  file_size=$(stat --printf="%s" "$test_root/large_file-$size.img")
  write_meg_per_sec=$(echo "scale=2; $file_size / 1024 / 1024 / $elapsed_sec" | bc)

  elapsed_sec=$({ TIMEFORMAT=%R; time cat "$test_root/large_file-$size.img" > /dev/null; } 2>&1 )
  file_size=$(stat --printf="%s" "$test_root/large_file-$size.img")
  read_meg_per_sec=$(echo "scale=2; $file_size / 1024 / 1024 / $elapsed_sec" | bc)

  echo "$runtime,$size,$elapsed_sec,$read_meg_per_sec,$write_meg_per_sec" >> benchmark-single-files.txt
  rm "$test_root/large_file-$size.img"
  sleep 2
}

benchmark_bonnie
benchmark_a_single_file_of_x_gigabytes 1
benchmark_a_single_file_of_x_gigabytes $[$optimal_file_size / 1024 / 16]
benchmark_a_single_file_of_x_gigabytes $[$optimal_file_size / 1024 / 8]
benchmark_a_single_file_of_x_gigabytes $[$optimal_file_size / 1024 / 4]
benchmark_a_single_file_of_x_gigabytes $[$optimal_file_size / 1024 / 2]
benchmark_a_single_file_of_x_gigabytes $[$optimal_file_size / 1024 / 1]

rm -Rf "$test_root"
