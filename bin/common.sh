#!/bin/bash

filesystem="$1"
parallelism="$2"
files_output_base="$3"

if [ -z "$files_output_base" ]; then
  files_output_base="benchmark"
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

if [ ! -e "${files_output_base}.csv" ]; then
  echo '"runtime_epoch","parallelism","total_fs_size","dd_flags","file_size","read_elapsed_sec","write_elapsed_sec","read_meg_per_sec","write_meg_per_sec"' > "${files_output_base}.csv"
fi

if [ ! -e "${files_output_base}direct.csv" ]; then
  echo '"runtime_epoch","parallelism","total_fs_size","dd_flags","file_size","read_elapsed_sec","write_elapsed_sec","read_meg_per_sec","write_meg_per_sec"' > "${files_output_base}direct.csv"
fi

test_root="$filesystem/filesystem_tests_tmp"
mkdir -p "$test_root"

trap "echo; echo \"Be sure to remove the $test_root directory\"; exit" INT TERM

benchmark_parallel_files_of_x_gigabytes() {
  size=$1
  parallel_actions=$2
  dd_flags=$3
  keep_files=$4
  filename_base="file-$$-$RANDOM"
  runtime=$(date +"%s")
  if [ ! -z "$dd_flags" ]; then
    of_dd_flag="oflag=direct"
    if_dd_flag="iflag=direct"
  else
    of_dd_flag=""
    if_dd_flag=""
  fi

  write_elapsed_sec=$({ TIMEFORMAT=%R; time seq 1 $parallel_actions | parallel -k "dd if=/dev/zero of=\"$test_root/$filename_base-{}-$size.img\" bs=1M count=$[1024*$size] $of_dd_flag status=none"; } 2>&1 )
  file_size=$(stat --printf="%s" "$test_root/$filename_base-1-$size.img")
  write_meg_per_sec=$(echo "scale=2; $file_size / 1024 / 1024 / $write_elapsed_sec" | bc)

  read_elapsed_sec=$({ TIMEFORMAT=%R; time seq 1 $parallel_actions | parallel -k "dd if=\"$test_root/$filename_base-{}-$size.img\" bs=1M status=none $if_dd_flag > /dev/null"; } 2>&1 )
  read_meg_per_sec=$(echo "scale=2; $file_size / 1024 / 1024 / $read_elapsed_sec" | bc)

  total_fs_size=$(du -BM --max-depth=0 "$test_root" | cut -f1 -d'	')

  echo "$runtime,$parallel_actions,$total_fs_size,$dd_flags,$size,$read_elapsed_sec,$write_elapsed_sec,$read_meg_per_sec,$write_meg_per_sec" >> "${files_output_base}${dd_flags}.csv"
  if [ "$keep_files" != "keep" ]; then
    rm $test_root/$filename_base-*-$size.img
  fi
  sleep 2
}
