lappend auto_path [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]

# 05-oct-2024 v1.0 : Initial example

package require graphy

set chart [graphy::Charts new]

$chart XAxis -data {A B C D E F G}
$chart YAxis

# The -showBackground option is used to control whether or not the
# background of the bars is shown.
$chart Add "barSeries" -data {150 230 224 218 135 147 260} \
                       -showBackground "True"

set w [$chart Render]

pack $w -expand 1 -fill both -padx 0 -pady 0