#!/bin/bash

source ./bin/common.sh

desired_terabytes=10
# We're creating 16 gigabyte chunks
chunks_per_terabyte=64

total_chunks=$[64 * $desired_terabytes]

for i in $(seq 1 $total_chunks); do
  benchmark_parallel_files_of_x_gigabytes 16 1 'direct' 'keep'
done;
