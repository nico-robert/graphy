lappend auto_path [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]

# 05-oct-2024 v1.0 : Initial example

package require graphy

# Create a new chart.
set chart [graphy::Charts new]

# Set the x-axis data with a boundary gap of 0.
$chart XAxis -data {Mon Tue Wed Thu Fri Sat Sun} -boundaryGap "False"
$chart YAxis

$chart Add "lineSeries" -data {820 932 901 934 1290 1330 1320} \
                        -areaStyle {}

# Render the chart.
set w [$chart Render]

pack $w -expand 1 -fill both -padx 0 -pady 0
