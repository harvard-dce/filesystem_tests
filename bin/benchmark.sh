#!/bin/bash

filesystem="$1"
parallelism="$2"
runtime=$(date +"%s")

files_output="benchmark-files.txt"

total_ram=$(grep MemTotal /proc/meminfo | awk -F' ' '{print $2}')
optimal_file_size=$(echo "($total_ram / 1024) * 2" | bc)
bonnie_exe=$(which bonnie++)
if [ -z "$bonnie_exe" ]; then
  bonnie_exe="/usr/sbin/bonnie++"
fi

if [ -z "$parallelism" ]; then
  parallelism=3
fi

if [ -z "$filesystem" ]; then
  echo 'Please define a root filesystem to test by passing it to this script'
  exit 1
fi

if [ ! -d "$filesystem" ]; then
  echo "That directory doesn't exist. Please give us another."
  exit 1
fi

if [ ! -e "$files_output" ]; then
  echo '"runtime_epoch","parallelism","file_size","elapsed_sec","read_meg_per_sec","write_meg_per_sec"' > "$files_output"
fi

test_root="$filesystem/filesystem_tests_tmp"

rm -Rf "$test_root"
mkdir -p "$test_root"

trap "echo; echo \"Be sure to remove the $test_root directory\"; exit" INT TERM

benchmark_bonnie() {
  output="$($bonnie_exe -q -s ${optimal_file_size}M -d $test_root -f -n 0 2> /dev/null)"
  echo "$runtime,$output" >> benchmark-bonnie.txt
}

benchmark_parallel_files_of_x_gigabytes() {
  size=$1
  parallel_actions=$2
  elapsed_sec=$({ TIMEFORMAT=%R; time seq 1 $parallel_actions | parallel -k "dd if=/dev/zero of=\"$test_root/large_file-{}-$size.img\" bs=1M count=$[1024*$size] status=none"; } 2>&1 )
  file_size=$(stat --printf="%s" "$test_root/large_file-1-$size.img")
  write_meg_per_sec=$(echo "scale=2; $file_size / 1024 / 1024 / $elapsed_sec" | bc)

  elapsed_sec=$({ TIMEFORMAT=%R; time seq 1 $parallel_actions | parallel -k "cat \"$test_root/large_file-{}-$size.img\"" > /dev/null; } 2>&1 )
  read_meg_per_sec=$(echo "scale=2; $file_size / 1024 / 1024 / $elapsed_sec" | bc)

  echo "$runtime,$parallelism,$size,$elapsed_sec,$read_meg_per_sec,$write_meg_per_sec" >> "$files_output"
  rm $test_root/large_file-*-$size.img
  sleep 2
}

benchmark_bonnie
benchmark_parallel_files_of_x_gigabytes 1 $parallelism
benchmark_parallel_files_of_x_gigabytes $[$optimal_file_size / 1024 / 16] $parallelism
benchmark_parallel_files_of_x_gigabytes $[$optimal_file_size / 1024 / 8] $parallelism
benchmark_parallel_files_of_x_gigabytes $[$optimal_file_size / 1024 / 4] $parallelism
benchmark_parallel_files_of_x_gigabytes $[$optimal_file_size / 1024 / 2] $parallelism
benchmark_parallel_files_of_x_gigabytes $[$optimal_file_size / 1024 / 1] $parallelism

rm -Rf "$test_root"
