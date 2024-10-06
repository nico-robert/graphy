lappend auto_path [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]

# 05-oct-2024 v1.0 : Initial example

package require graphy

set chart [graphy::Charts new]

$chart XAxis -name          "Day" \
             -data          {Mon Tue Wed Thu Fri Sat Sun} \
             -axisLine      {lineStyle {color "red"}} \
             -axisTick      {lineStyle {color "red"}} \
             -axisLabel     {fontColor "red"} \
             -minorTick     {show true} \
             -nameTextStyle {fontSize 12 fontColor "red"} \

$chart YAxis -name          "Precipitation" \
             -axisLine      {show true lineStyle {color "blue"}}  \
             -axisTick      {lineStyle {color "blue"}} \
             -minorTick     {show true} \
             -axisLabel     {formatter "@f.t ml" fontColor "blue"} \
             -nameTextStyle {fontSize 12 fontColor "blue"} \
             -nameLocation  "top"

$chart Add "lineSeries" -data {150 230 224 218 135 147 260} \
                        -show "False"

set w [$chart Render]

pack $w -expand 1 -fill both -padx 0 -pady 0