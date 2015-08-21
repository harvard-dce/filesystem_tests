#!/bin/bash

source ./bin/common.sh

desired_terabytes=2

# We're creating 16 gigabyte chunks, 16 at a time
chunks_per_terabyte=$[1024 / 16 / 16]
total_chunks=$[$chunks_per_terabyte * $desired_terabytes]

for i in $(seq 1 $total_chunks); do
  benchmark_parallel_files_of_x_gigabytes 16 16 '' 'keep'
done;
