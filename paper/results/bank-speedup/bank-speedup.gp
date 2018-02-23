set term postscript color eps enhanced 22
set output "bank-speedup.eps"
load "../styles.inc"

X_MARGIN=0.14
Y_MARGIN=0.04
WIDTH_IND=0.4
HEIGHT_IND=0.4
WIDTH_BETWEEN_X=0.05
WIDTH_BETWEEN_Y=-0.01

set size 1,0.6
# do not change the plot width. This is what keeps the font size the same
# in all the paper and plots.

set bmargin 2.2
set tmargin 2.2
set lmargin 12
set rmargin 2

#set multiplot
#unset key
#set grid y
	 
#X_POS=0
#Y_POS=0
#set origin X_MARGIN+(X_POS*(WIDTH_IND+WIDTH_BETWEEN_X)), Y_MARGIN+(Y_POS*(HEIGHT_IND+WIDTH_BETWEEN_Y))
#set size WIDTH_IND,HEIGHT_IND

set style data histogram
set style fill solid border -1
set boxwidth 0.9
set title "Bank Benchmark, 2\^{10} accounts, from 0\% to 100\% locality"
set ylabel "tx/sec (10x6)"
set ytics font "Helvetica,12pt"
#set xtics font "Helvetica, 9pt"
#set xlabel "# cores"
#set yrange [0:20]
#unset xtics
#set label 1001 "1"      at 0,-100000000  font "Helvetica,12pt"
#set label 1008 "8"      at 3,-100000000  font "Helvetica,12pt"
#set label 1016 "16"   at 6.5,-100000000  font "Helvetica,12pt"
#set label 1024 "24"  at 10.5,-100000000  font "Helvetica,12pt"
#set label 1032 "32"  at 14.5,-100000000  font "Helvetica,12pt"
#set label 1040 "40"  at 19.5,-100000000  font "Helvetica,12pt"
#set label 1048 "48"  at 23.5,-100000000  font "Helvetica,12pt"
#set label 1099 "# cores" at 9.5,-200000000

set key horizontal top center width 0.5 sample 0.2  spacing 1 font "Helvetica,12pt"  #at 22.18,800000000 font "Helvetica,12pt" 

plot "data/bank_global_locality.log" u 5:xtic(3) ls 1 title "Global Clock",\
     "data/bank_thread_locality.log" u 5:xtic(3) ls 3 title "Thread Clock"


!epstopdf "bank-speedup.eps"
!rm "bank-speedup.eps"
quit
