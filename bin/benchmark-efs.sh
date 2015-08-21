#!/bin/bash

source ./bin/common.sh

desired_terabytes=1

# We're creating 16 gigabyte chunks, 16 at a time
chunks_per_terabyte=$[1024 / 16 / 16]
total_chunks=$[$chunks_per_terabyte * $desired_terabytes]

# Only do 512 gb
total_chunks=$[$total_chunks / 2]

for i in $(seq 1 $total_chunks); do
  benchmark_parallel_files_of_x_gigabytes 16 16 'direct' 'keep'
done;
