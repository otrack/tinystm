experiments on AMD48c:
- 8 NUMA nodes
- each numa node  is equipped with a AMD Opteron(tm) Processor 6174 (6 cores) et 16GB of RAM


ll-global.log: linked list with the default parameters (Initial size : 256, Value range  : 512, duration: 10s) with a global clock
ll-global_async.log: linked list with the default parameters (Initial size : 256, Value range  : 512, duration: 10s) with a global asynchornous clock

rb_global_100k.log: performance of the global clock on rb tree (range: 10^7, initial size: 10^5)
rb_global_100k.log: performance of the global asynchronous clock on rb tree (range: 10^7, initial size: 10^5)

bank-global_0.8_1048576.log: performance of the global clock on bank (nbank=1048576, locality=0.8)
bank-global_0.8_1048576.log: performance of the global asynchronous clock on bank (nbank=1048576, locality=0.8)

bank-global_1_1048576.log: performance of the global clock on bank (nbank=1048576, locality=1)
bank-global_1_1048576.log: performance of the global asynchronous clock on bank (nbank=1048576, locality=1)

