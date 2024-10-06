lappend auto_path [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]

# 05-oct-2024 v1.0 : Initial example

package require graphy

set chart [graphy::Charts new]

$chart XAxis -data {Mon Tue Wed Thu Fri Sat Sun}
$chart YAxis

# The -smooth option is set to "True", which means that the line will be drawn as a smooth,
# curved line rather than a series of connected points.
$chart Add "lineSeries" -data {150 230 224 218 135 147 260} -smooth "True"

set w [$chart Render]

pack $w -expand 1 -fill both -padx 0 -pady 0