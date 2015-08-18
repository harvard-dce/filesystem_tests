#!/bin/bash

source ./bin/common.sh

desired_terabytes=10

# We're creating 16 gigabyte chunks, four at a time
chunks_per_terabyte=$[1024 / 16 / 4]
total_chunks=$[$chunks_per_terabyte * $desired_terabytes]

for i in $(seq 1 $total_chunks); do
  benchmark_parallel_files_of_x_gigabytes 16 4 'direct' 'keep'
done;
