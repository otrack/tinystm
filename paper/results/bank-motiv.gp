load "style.inc.gp"

set terminal postscript eps enhanced color font my_font size 3,2
set output '| epstopdf --filter --outfile=bank-motiv.pdf'

set title "" textcolor rgb text_color font my_font
set xlabel "Threads" textcolor rgb text_color font my_font
set ylabel "Transactions/s (10^6)" textcolor rgb text_color font my_font

set key top left

plot [1:48] \
     'bank-motiv/default.data'  using 1:($2/1000000) title "TinySTM" with linespoints,\
     'bank-motiv/parallel.data' using 1:($2/1000000) title "Disjoint TinySTM" with linespoints,\
     (4627464/1000000)*x  title "Perfect scale-up." with linespoints
