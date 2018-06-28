# Gnuplot script generates charts illustating the firming of wind power dispatch
# with battery energy storage.

reset
set term epslatex size 14.4cm, 9.6cm
#set size 1.0, 1.0

#------------------------------------------------------------------------------#
roff_tol = 1e-12
set style line 1 linecolor rgb 'black' linewidth 2 dashtype 1 pointtype 1
set style line 2 linecolor rgb 'forest-green' linewidth 2 dashtype 2 pointtype 2
set style line 3 linecolor rgb 'medium-blue' linewidth 2 dashtype 3 pointtype 3

set style line 4 linecolor rgb 'red' linewidth 2 dashtype 3 pointtype 4
set style line 5 linecolor rgb 'gold' linewidth 2 dashtype 5 pointtype 6

set style line 6 linecolor rgb 'red' linewidth 1 dashtype 1 pointtype 1
set style line 7 linecolor rgb 'medium-blue' linewidth 1 dashtype 1 pointtype 1

#------------------------------------------------------------------------------#
cf = 0.328		# Capacity factor of SNOWTWN1 wind farm (2016-17)
bc = 99.0		# Energy capacity (MWh) of battery coupled to SNOWTWN1 wind farm

#------------------------------------------------------------------------------#
#------------------------------------------------------------------------------#
# Plots the normalised mean absolute error -- absolute difference between power
# dispatch to the grid and power scheduled during pre-dispatch, normalised by 
# the nameplate capacity of the wind farm -- with and without curtailment of 
# scheduled power, which depends on energy capacity and state of charge (SOC) of 
# the battery.  NMAE is plotted for all dispatch intervals in which power is 
# scheduled 
#
set output 'plot_wind_bess_nmae.tex'
set key inside right top Left reverse nobox
set key height 1.0
set key width -8.0
#unset key
set xrange [0.00:1.00]
set yrange [0.0:8.0]
set xtics 0.00, 0.10, 1.00 format '%.2f'
set mxtics 2
set ytics 0.0, 1.0, 8.0 format '%.1f'
set mytics 2
set xlabel 'Battery energy capacity, p.u.'
set ylabel 'Normalised mean absolute error, \%' 
set arrow from cf,0.0 to cf,8.0 nohead ls 6
#set label at 0.34,4.0 sprintf("Capacity factor = %.3f", cf) left
set label at 0.34,4.0 '\small Capacity factor = 0.328' left
plot	'../data/out/windbess_rslt_snowtwn1.dat' using ($5/$4):10 title '\small No curtailment' with linespoints ls 1, \
		'../data/out/windbess_rslt_snowtwn1_curtbess05.dat' using ($5/$4):10 title '\small Maximum curtailment 5\%' with linespoints ls 2, \
		'../data/out/windbess_rslt_snowtwn1_curtbess10.dat' using ($5/$4):10 title '\small Maximum curtailment 10\%' with linespoints ls 3
#		'../data/out/windbess_rslt_snowtwn1_curtbess20.dat' using ($5/$4):10 title '\small Maximum curtailment 20\%' with linespoints ls 5	
unset xlabel
unset ylabel
unset arrow
unset label

pause -1 'Hit any key to continue'

#------------------------------------------------------------------------------#
# Plots the normalised mean absolute error with and without curtailment of 
# scheduled power, which depends on generation capacity and battery SOC.
# NMAE is plotted for all dispatch intervals in which power is scheduled 
#
set output 'plot_wind_bess_nmae_curtgen.tex'
set key inside right top Left reverse nobox
#unset key
set xrange [0.00:1.00]
set yrange [0.0:8.0]
set xtics 0.00, 0.10, 1.00 format '%.2f'
set mxtics 2
set ytics 0.0, 1.0, 8.0 format '%.1f'
set mytics 2
set xlabel 'Battery energy capacity, p.u.'
set ylabel 'Normalised mean absolute error, \%' 
#set arrow from cf,0.0 to cf,8.0 nohead ls 6
#set label at 0.34,4.0 '\small Capacity factor = 0.328' left
plot	'../data/out/windbess_rslt_snowtwn1.dat' using ($5/$4):10 title '\small No curtailment' with linespoints ls 1, \
		'../data/out/windbess_rslt_snowtwn1_curtgen025.dat' using ($5/$4):10 title '\small Maximum curtailment 2.5\%' with linespoints ls 2, \
		'../data/out/windbess_rslt_snowtwn1_curtgen05.dat' using ($5/$4):10 title '\small Maximum curtailment 5\%' with linespoints ls 4, \
		'../data/out/windbess_rslt_snowtwn1_curtgen10.dat' using ($5/$4):10 title '\small Maximum curtailment 10\%' with linespoints ls 5	
unset xlabel
unset ylabel
unset arrow
unset label

pause -1 'Hit any key to continue'

#------------------------------------------------------------------------------#
# Plots the normalised mean absolute error accounting for only dispatch intervals
# where power dispatched falls short of scheduled power 
#
set output 'plot_wind_bess_nmae_deficit.tex'
#set key inside left bottom Left reverse nobox
unset key
set xrange [0.00:1.00]
set yrange [0.0:60.0]
set y2range [0.0:20.0]
set xtics 0.00, 0.10, 1.00 format '%.2f'
set mxtics 2
set ytics border nomirror 0.0, 5.0, 60.0 format '%.1f'
set mytics 2
set y2tics border nomirror 0.0, 2.0, 20.0 format '%.1f'
set my2tics 2
set xlabel 'Battery energy capacity, p.u.'
set ylabel '\shortstack{Proportion of dispatch intervals in which\\power dispatched is less than scheduled, \%}'
set arrow 1 from 0.05,32.5 to 0.10,32.5 backhead filled ls 1
set arrow 2 from 0.90,15.0 to 0.95,15.0 head filled ls 2
set y2label '\shortstack{Normalised mean absolute error for dispatch intervals\\in which power dispatched is less than scheduled, \%}'
plot	'../data/out/windbess_rslt_snowtwn1.dat' using ($5/$4):($15/$8*100) notitle with linespoints ls 1 axes x1y1, \
		'../data/out/windbess_rslt_snowtwn1.dat' using ($5/$4):17 notitle with lines ls 2 axes x1y2 smooth csplines		
unset xlabel
unset mxtics
unset mytics
unset ylabel
unset y2label
unset y2tics
unset my2tics
unset arrow

pause -1 'Hit any key to continue'

#------------------------------------------------------------------------------#
# Plots the normalised mean absolute error for varying (MPC) control horizons 
#
set output 'plot_wind_bess_nmae_hrzn.tex'
set key inside right top Left reverse nobox
set key width -10
#unset key
set xrange [0.00:1.00]
set yrange [0.0:12.0]
set xtics 0.00, 0.10, 1.00 format '%.2f'
set mxtics 2
set ytics 0.0, 1.0, 12.0 format '%.1f'
set mytics 2
set xlabel 'Battery energy capacity, p.u.'
set ylabel 'Normalised mean absolute error, \%' 
set arrow from cf,0.0 to cf,12.0 nohead ls 6
set label at 0.34,8.0 '\small Capacity factor = 0.328' left
plot	'../data/out/windbess_rslt_snowtwn1.dat' using ($5/$4):10 title '\small 30-minute control horizon' with linespoints ls 1, \
		'../data/out/windbess_rslt_snowtwn1_hrzn60.dat' using ($5/$4):10 title '\small 60-minute control horizon' with linespoints ls 2, \
		'../data/out/windbess_rslt_snowtwn1_hrzn90.dat' using ($5/$4):10 title '\small 90-minute control horizon' with linespoints ls 3	
unset xlabel
unset ylabel
unset arrow
unset label

pause -1 'Hit any key to continue'

#------------------------------------------------------------------------------#
# Plots battery state of charge (SOC) during virtual trial.
# Note that with 'xdata time' the abscissa (column 2) is read as a date-time
# field (YYYY-mm-dd HH:MM:SS), while the ordinate reads the date-time field as
# two columns, date and time separated by whitespace
#
set output 'plot_wind_bess_soc.tex'
#set key inside left bottom Left reverse nobox
unset key
set xdata time
set timefmt '%Y-%m-%d %H:%M:%S'
set xrange ['2017-04-01 00:05:00':'2018-04-01 00:00:00']
#set xtics '2017-11-01 00:00:00',86400,'2017-11-30 23:55:00'
#set xtics '2017-04-01 00:05:00',2592000,'2018-04-01 00:00:00'
set xtics ( '2017-04-01 00:05:00', '2017-05-01 00:05:00', '2017-06-01 00:05:00', \
			'2017-07-01 00:05:00', '2017-08-01 00:05:00', '2017-09-01 00:05:00', \
			'2017-10-01 00:05:00', '2017-11-01 00:05:00', '2017-12-01 00:05:00', \
			'2018-01-01 00:05:00', '2018-02-01 00:05:00', '2018-03-01 00:05:00', \
			'2018-04-01 00:05:00' )
set xtics add ("" '2017-04-16 00:05:00' 1, "" '2017-05-16 00:05:00' 1, "" '2017-06-16 00:05:00' 1, \
			"" '2017-07-16 00:05:00' 1, "" '2017-08-16 00:05:00' 1, "" '2017-09-16 00:05:00' 1, \
			"" '2017-10-16 00:05:00' 1, "" '2017-11-16 00:05:00' 1, "" '2017-12-16 00:05:00' 1, \
			"" '2018-01-16 00:05:00' 1, "" '2018-02-15 00:05:00' 1, "" '2018-03-16 00:05:00' 1 )
set mxtics 5
set xtics axis rotate by 90 offset 0,-2.25 font '\textnormal, 8pt'
#set format x '%d %b'
set format x '%b-%y'
unset xlabel
set yrange [0.0:29.7]
set ytics out 0.0, 2.97, 29.7 format '%.1f'
set mytics 2
set ylabel 'Battery state of charge, MWh'
set y2range [0.0:100.0]
set y2tics out 0.0, 10.0, 100.0 format '%.0f'
set my2tics 2
set y2label 'Battery state of charge, \%'
plot	'../data/out/windbess_sim_snowtwn1_soc.dat' using 4:($13/bc*100) notitle with lines ls 7
unset xlabel
unset mxtics
unset mytics
unset ylabel
unset y2label
unset y2tics
unset my2tics

pause -1 'Hit any key to continue'

#------------------------------------------------------------------------------#
reset
set output 'plot_dummy.tex'
plot	 sin(x)
#------------------------------------------------------------------------------#