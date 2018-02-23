#!/bin/bash
cat tmp| awk -F " " '$2 >= 48 && $1 == "thread" && $4 == 1048576' > data/bank_thread_locality.log
cat tmp| awk -F " " '$2 >= 48 && $1 == "global" && $4 == 1048576' > data/bank_global_locality.log
cat tmp| awk -F " " '$2 >= 48 && $1 == "global_async" && $4 == 1048576' > data/bank_global_async_locality.log