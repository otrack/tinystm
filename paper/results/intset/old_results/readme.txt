experiments on AMD48c:
- 8 NUMA nodes
- each numa node  is equipped with a AMD Opteron(tm) Processor 6174 (6 cores) et 16GB of RAM


ll_default.log: linked list with the default parameters (Initial size : 256, Value range  : 512, duration: 10s)
rb_default.log: red black tree with the default parameters (range: 512, initial size: 256)
rb_global_100k.log: performance of the global clock on rb tree (range: 10^7, initial size: 10^5)
rb_thread_100k.log: performance of the thread clock on rb tree (range: 10^7, initial size: 10^5)
rb_global_100k_5run.log:  performance of the global clock on rb tree (range: 10^7, initial size: 10^5). Each measurement is the average of 5 runs
rb_thread_100k_5run.log:  performance of the thread clock on rb tree (range: 10^7, initial size: 10^5). Each measurement is the average of 5 runs

