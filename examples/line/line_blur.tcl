lappend auto_path [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]

# 05-oct-2024 v1.0 : Initial example

package require graphy

set chart [graphy::Charts new]

$chart XAxis -data {Mon Tue Wed Thu Fri Sat Sun}
$chart YAxis

# The line style is set to have a shadow with a blur of 5 and a line width of 5.
# This means that the line will appear as a thick, blurred line.
$chart Add "lineSeries" -data {150 230 224 218 135 147 260} \
                        -lineStyle {shadowBlur 5 width 5}

set w [$chart Render]

pack $w -expand 1 -fill both -padx 0 -pady 0