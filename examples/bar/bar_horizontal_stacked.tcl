lappend auto_path [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]

# 16-oct-2024 v1.0 : Initial example

package require graphy

set chart [graphy::Charts new]

$chart SetOptions -grid {showY "False" showX "True"}

$chart XAxis -type "value" \
             -boundaryGap "False" \
             -axisLine {show "False"} \
             -name "Value"

$chart YAxis -data {Brazil Indonesia USA India China UK World} \
             -type "category" \
             -axisLine {show "True"} \
             -name "Category"

$chart Add "horizontalBarSeries" -data {30 230 224 50 100 147 10}  -label {show true align center fontColor white fontSize 13} -stacked "True"
$chart Add "horizontalBarSeries" -data {150 20 30 218 135 100 200} -label {show true align center fontColor white fontSize 13} -stacked "True"
$chart Add "horizontalBarSeries" -data {150 35 30 218 135 100 200} -label {show true align center fontColor white fontSize 13} -stacked "True"

set w [$chart Render -width 900 -height 500]

pack $w -expand 1 -fill both -padx 0 -pady 0