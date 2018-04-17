set term postscript color eps enhanced 22
set output "bank-speedup.eps"
load "../styles.inc"

#X_MARGIN=0.14
#Y_MARGIN=0.04
#WIDTH_IND=0.4
#HEIGHT_IND=0.4
#WIDTH_BETWEEN_X=0.05
#WIDTH_BETWEEN_Y=-0.01

set size 1,0.6
set bmargin 3.2
set tmargin 2.2
set lmargin 10
set rmargin 2
set style data histogram
set style fill solid border -1
set boxwidth 0.9
# set title "Bank Benchmark, 2\^{10} accounts"
set ylabel "Speed-up (x times)"
#set ytics font "Helvetica,12pt"
set xlabel "Locality"
set grid y
set xtics nomirror
set key horizontal top center at 2.5,80 #font "Helvetica,12pt" 

plot "data/bank_global_locality.log" u 7:xtic(3) ls 1 title "TinySTM",\
     "data/bank_thread_locality.log" u 7:xtic(3) ls 3 title "Algorithm 1"

!epstopdf "bank-speedup.eps"
!rm "bank-speedup.eps"
quit
