load "style.inc.gp"

set terminal postscript eps enhanced color font my_font size 6,4
set output '| epstopdf --filter --outfile=bank-3d-a1048576.pdf'


#set title "" textcolor rgb text_color font my_font
set xlabel "Threads" textcolor rgb text_color font my_font
set ylabel "Locality" textcolor rgb text_color font my_font
set zlabel "Millions transfers/sec" textcolor rgb text_color font my_font

set view 80,20

# palette  pointsize 3 pointtype 7
splot 'bankall/clock-numa-a1048576.data' using 2:1:($3/1000000) with lines title "Numa", \
      'bankall/clock-thread-a1048576.data' using 2:1:($3/1000000) with lines title "DAP", \
      'bankall/tinystm-a1048576.data' using 2:1:($3/1000000) with lines title "TinySTM"
