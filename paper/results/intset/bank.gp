set term postscript color eps enhanced 22
set output "bank.eps"
load "../styles.inc"

set size 1,0.6
set bmargin 3.2
set tmargin 2.2
set lmargin 10
set rmargin 2

set style data histogram

set style fill solid border -1
set boxwidth 0.9
set ylabel "Transactions/sec"
#set ytics font "Helvetica,12pt"

unset xtics
set grid y
set label 1001 "1"         at 0,-3800000  #font "Helvetica,18pt"
set label 1008 "8"         at 3,-3800000  #font "Helvetica,18pt"
set label 1016 "16"      at 6.5,-3800000  #font "Helvetica,18pt"
set label 1024 "24"     at 10.5,-3800000  #font "Helvetica,18pt"
set label 1032 "32"     at 14.5,-3800000  #font "Helvetica,18pt"
set label 1040 "40"     at 19.5,-3800000  #font "Helvetica,18pt"
set label 1048 "48"     at 23.5,-3800000  #font "Helvetica,18pt"
set label 1099 "# threads"at 9.5,-12000000#

set key horizontal top at 21.18,80000000 #font "Helvetica,12pt"  

plot "bank-global_0.8_1048576.log" u  5:xtic(2) ls 1 title "TinySTM",\
     "bank_thread_locality_0_8.log" u 5:xtic(2) ls 3 title "Algorithm 1"

						  
!epstopdf "bank.eps"
!rm "bank.eps"
quit
