lappend auto_path [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]

# 27-oct-2024 v1.0 : Initial example

proc func {x} {
    set x [expr {$x / 10.0}]
    return [expr {sin($x) * cos($x * 2 + 1) * sin($x * 3 + 2) * 50}]
}

proc generateData {} {
    set dataX {} ; set dataY {}

    for {set i -500} {$i <= 500} {set i [expr {$i + 0.1}]} {
        lappend dataX $i
        lappend dataY [func $i]
    }
    return [list $dataX $dataY]
}

package require graphy

lassign [generateData] dx dy

set chart [graphy::Charts new]

$chart SetOptions -grid {showY "True" showX "True"} \
                  -toolbox {
                    dataZoom    {show "True"} 
                    saveAsImage {show "True"}
                }

$chart XAxis -type "value" \
             -boundaryGap "False" \
             -max -90 \
             -min -120 \
             -name "X" \
             -data $dx

$chart YAxis -name "Y"

$chart Add "lineSeries" -data $dy -clip "True" -showSymbol false

set w [$chart Render -width 900 -height 500]

pack $w -expand 1 -fill both -padx 0 -pady 0
