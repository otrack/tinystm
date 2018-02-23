set term postscript color eps enhanced 22
set output "rb_100k_5run.eps"
load "../../styles.inc"

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

set title "2\^{10} accounts, locality=0"
set ylabel "tx/sec (10x6)"
set xtics font "Helvetica, 12pt"
set xlabel "# cores"
set yrange [0:20]
set key horizontal top width 0.5 sample 0.2  spacing 1 font "Helvetica,12pt"  at 15.18,22.5 font "Helvetica,12pt" 

plot "data/global_clock.txt" u  6:xtic(2) ls 1 title "Global Clock",\
     "data/thread_clock.txt" u  6:xtic(2) ls 3 title "Thread Clock"

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
set xtics font "Helvetica, 12pt"

set title "2\^{20} accounts, locality=0"
#set ylabel "Throughput (MB/s)"
set xlabel "# cores"
set key horizontal top width 0.5 sample 0.2  spacing 1 font "Helvetica,12pt"  at 15.18,101 font "Helvetica,12pt" 
#set xtics 2,2,32
set ytics 0,20,80
set yrange [0:90]
unset ylabel
plot "data/global_clock_2_20.txt" u  6:xtic(2) ls 1 title "Global Clock",\
     "data/thread_clock_2_20.txt" u  6:xtic(2) ls 3 title "Thread Clock"
							  
!epstopdf "b_100k_5run.eps"
!rm "b_100k_5run.eps"
quit
