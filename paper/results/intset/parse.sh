#!/bin/bash
cat tmp| awk -F " " '$3 == 0.8 && $1 == "thread" && $4 == 1048576' > bank_thread_locality_0_8.log
cat tmp| awk -F " " '$3 == 1 && $1 == "thread" && $4 == 1048576' > bank_thread_locality_1_0.log

#cat tmp| awk -F " " '$2 >= 48 && $1 == "global" && $4 == 1048576' > data/bank_global_locality.log
#cat tmp| awk -F " " '$2 >= 48 && $1 == "global_async" && $4 == 1048576' > data/bank_global_async_locality.log