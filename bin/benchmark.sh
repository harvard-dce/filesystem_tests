#!/bin/bash

source ./bin/common.sh

benchmark_parallel_files_of_x_gigabytes 1 $parallelism 'direct'
benchmark_parallel_files_of_x_gigabytes 1 $parallelism ''
benchmark_parallel_files_of_x_gigabytes 5 $parallelism 'direct'
benchmark_parallel_files_of_x_gigabytes 5 $parallelism ''
benchmark_parallel_files_of_x_gigabytes 10 $parallelism 'direct'
benchmark_parallel_files_of_x_gigabytes 10 $parallelism ''
benchmark_parallel_files_of_x_gigabytes 20 $parallelism 'direct'
benchmark_parallel_files_of_x_gigabytes 20 $parallelism ''
