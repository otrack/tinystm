set term postscript color eps enhanced 22
set output "rb-tput.eps"
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
#set style data histogram
#set style fill solid border -1
#set boxwidth 0.9
set title "Red-Black Tree Benchmark"
set ylabel "tsx(x 10^6)"
#set ytics font "Helvetica,12pt"
set xlabel "# cores"
set xtics 0,4,48
set grid y

set key horizontal top center width 0.5 sample 0.2  spacing 1 #font "Helvetica,12pt" 

plot "amd48-rb-tinystm.txt" u ($2):($4) ls 1001 title "TinySTM",\
     "amd48-rb-alg1.txt" u ($2):($4) ls 1003 title "Algorithm 1"

!epstopdf "rb-tput.eps"
!rm "rb-tput.eps"
quit
