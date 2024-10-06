lappend auto_path [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]

# 05-oct-2024 v1.0 : Initial example

package require graphy

set chart [graphy::Charts new]

$chart SetOptions -title {
                    text "Title 'graphy'" 
                    textStyle {fontSize 20 align center} 
                    subtext "SubText 'graphy'" 
                  } \
                  -legend {} \
                  -margin {left 20 top 10 right 40 bottom 5}

$chart XAxis -data {Mon Tue Wed Thu Fri Sat Sun}
$chart YAxis
$chart Add "lineSeries" -data {150 230 224 218 135 147 260} -name "line Basic"

set w [$chart Render]

pack $w -expand 1 -fill both -padx 0 -pady 0