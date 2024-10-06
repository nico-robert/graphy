lappend auto_path [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]

# 05-oct-2024 v1.0 : Initial example

package require graphy

set chart [graphy::Charts new]

# Set the global options for the chart
# The margin is set to 20px on the left, 10px on the top, 40px on the right, and 5px on the bottom
# This will leave a small gap around the chart to make it look nicer.
$chart SetOptions -legend {} -margin {left 20 top 10 right 40 bottom 5}

$chart XAxis -data {A B C D E F G}
$chart YAxis

$chart Add "barSeries" -data {150 230 224 218 135 147 260} -name "Direct"
$chart Add "barSeries" -data {250 50 100 10 100 20 5}      -name "Indirect"

set w [$chart Render]

pack $w -expand 1 -fill both -padx 0 -pady 0