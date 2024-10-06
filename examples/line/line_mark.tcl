lappend auto_path [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]

# 05-oct-2024 v1.0 : Initial example

package require graphy

set chart [graphy::Charts new]

$chart XAxis -data {Mon Tue Wed Thu Fri Sat Sun}
$chart YAxis
# The markPoint option adds a visual mark to the chart at the minimum
# and maximum data points.
#
# The markLine option adds a visual line to the chart at the average
# data point.
#
$chart Add "lineSeries" -data {150 230 224 218 135 147 260} \
                        -markPoint {{category "max" label {fontColor white}} {category "min" label {fontColor white}}} \
                        -markLine  {{category "average" label {fontColor blue}}}

set w [$chart Render]

pack $w -expand 1 -fill both -padx 0 -pady 0