set term postscript color eps enhanced 22
set output "bank.eps"
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

set bmargin 2.5
set tmargin 0.0
set lmargin 0.7
set rmargin 1

set multiplot
unset key
set grid y
	 
X_POS=0
Y_POS=0
set origin X_MARGIN+(X_POS*(WIDTH_IND+WIDTH_BETWEEN_X)), Y_MARGIN+(Y_POS*(HEIGHT_IND+WIDTH_BETWEEN_Y))
set size WIDTH_IND,HEIGHT_IND

#set yrange [0:30]
set style data histogram
#set style histogram cluster gap 1
#set style histogram gap 1 lw 1
set style fill solid border -1
set boxwidth 0.9
#set xtic rotate by -35 scale 0 font "Helvetica,12pt"

set title "2\^{10} accounts, locality=0.8"
set ylabel "tx/sec (10x6)"
set ytics font "Helvetica,12pt"
#set xtics font "Helvetica, 9pt"
#set xlabel "# cores"
#set yrange [0:20]
unset xtics
set label 1001 "1"      at 0,-100000000  font "Helvetica,12pt"
set label 1008 "8"      at 3,-100000000  font "Helvetica,12pt"
set label 1016 "16"   at 6.5,-100000000  font "Helvetica,12pt"
set label 1024 "24"  at 10.5,-100000000  font "Helvetica,12pt"
set label 1032 "32"  at 14.5,-100000000  font "Helvetica,12pt"
set label 1040 "40"  at 19.5,-100000000  font "Helvetica,12pt"
set label 1048 "48"  at 23.5,-100000000  font "Helvetica,12pt"
set label 1099 "# cores" at 9.5,-200000000

set key horizontal top width 0.5 sample 0.2  spacing 1 font "Helvetica,12pt"  at 22.18,800000000 font "Helvetica,12pt" 

plot "bank-global_0.8_1048576.log" u  5:xtic(2) ls 1 title "TinySTM",\
     "bank-global_async_0.8_1048576.log" u 5:xtic(2) ls 3 title "Alg3"

X_POS=1
Y_POS=0
set origin X_MARGIN+(X_POS*(WIDTH_IND+WIDTH_BETWEEN_X)), Y_MARGIN+(Y_POS*(HEIGHT_IND+WIDTH_BETWEEN_Y))
set size WIDTH_IND,HEIGHT_IND

#set yrange [0:30]
set style data histogram
#set style histogram cluster gap 1
#set style histogram gap 1 lw 1

set style fill solid border -1
set boxwidth 0.9
#set xtic rotate by -35 scale 0

set title "2\^{20} accounts, locality=1.0"
#set ylabel "Throughput (MB/s)"
unset xlabel #"# cores"
set key horizontal top width 0.5 sample 0.2  spacing 1 font "Helvetica,12pt"  at 22.18,1550000000 font "Helvetica,12pt" 
#set xtics 2,2,32

set ytics font "Helvetica,12pt"
unset xtics

unset label 1001
unset label 1008
unset label 1016
unset label 1024
unset label 1032
unset label 1040
unset label 1048
unset label 1099

set label 2001 "1"      at 0,-200000000  font "Helvetica,12pt"
set label 2008 "8"      at 3,-200000000  font "Helvetica,12pt"
set label 2016 "16"   at 6.5,-200000000  font "Helvetica,12pt"
set label 2024 "24"  at 10.5,-200000000  font "Helvetica,12pt"
set label 2032 "32"  at 14.5,-200000000  font "Helvetica,12pt"
set label 2040 "40"  at 19.5,-200000000  font "Helvetica,12pt"
set label 2048 "48"  at 23.5,-200000000  font "Helvetica,12pt"
set label 2099 "# cores" at 9.5,-400000000
#set yrange [0:90]
unset ylabel
plot "bank-global_1_1048576.log" u  5:xtic(2) ls 1 title "TinySTM",\
     "bank-global_async_1_1048576.log" u  5:xtic(2) ls 3 title "Alg3" 
	 							  
!epstopdf "bank.eps"
!rm "bank.eps"
quit
