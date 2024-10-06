lappend auto_path [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]

# 05-oct-2024 v1.0 : Initial example

package require graphy

set chart [graphy::Charts new]

$chart SetOptions -legend {} -margin {left 20 top 10 right 20 bottom 5}

# Add X and Y axis.
$chart XAxis -data {Mon Tue Wed Thu Fri Sat Sun}
$chart YAxis -name "Precipitation" -nameLocation "top" -axisLabel {formatter "@f.c ml"}
$chart YAxis -name "Temperature"   -nameLocation "top" -axisLabel {formatter "@f.c °C"}

# Add bars series.
$chart Add "barSeries" -name "Evaporation" \
                       -data {2.0 4.9 7.0 23.2 25.6 76.7 135.6}
                    
$chart Add "barSeries" -name "Precipitation" \
                       -data {2.6 5.9 9.0 26.4 28.7 70.7 175.6}


# Add line series. 
$chart Add "lineSeries" -data {2.0 2.2 3.3 4.5 6.3 10.2 20.3} \
                        -yAxisIndex 1 \
                        -name "Temperature"

set w [$chart Render -width 900 -height 500]

pack $w -expand 1 -fill both -padx 0 -pady 0