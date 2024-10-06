lappend auto_path [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]

# 05-oct-2024 v1.0 : Initial example

package require graphy

set chart [graphy::Charts new]

$chart XAxis -data {Mon Tue Wed Thu Fri Sat Sun}
$chart YAxis
$chart Add "lineSeries" -data {150 230 224 218 135 147 260}

set w [$chart Render]

pack $w -expand 1 -fill both -padx 0 -pady 0

# Adds interacive event handler.
# Simple demo : will be probably integrated in the next release.
bind $w <Motion> [list graphy::axisPointer %x %y %W $chart [$chart get canvas]]