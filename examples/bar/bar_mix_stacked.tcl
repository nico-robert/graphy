lappend auto_path [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]

# 11-oct-2024 v1.0 : Initial example

package require graphy

set chart [graphy::Charts new]

$chart XAxis -data {A B C D E F G}
$chart YAxis

$chart Add "barSeries" -data {150 230 224 218 135 100 260} \
                       -itemStyle {borderRadius {{15 15 0 0}}}

$chart Add "barSeries" -data {60 600 224 218 50 200 260}

$chart Add "barSeries" -data {150 230 224 218 135 50 260} \
                       -stacked "True"

$chart Add "barSeries" -data {60 230 65 1200 50 100 1000} \
                       -label {show true align center fontColor white fontSize 13 formatter "@f.t"}

set w [$chart Render -width 900 -height 500]

pack $w -expand 1 -fill both -padx 0 -pady 0