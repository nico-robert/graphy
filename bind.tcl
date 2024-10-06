# Copyright (c) 2024 Nicolas ROBERT.
# Distributed under MIT license. Please see LICENSE for details.

namespace eval graphy {}

proc graphy::axisPointer {x y W chart self} {

    set ctx    [$chart get ctx]
    set bounds [$chart get boundsAera]

    if {
        ($x < [dict get $bounds x] - 1) ||
        ($x >= [dict get $bounds x] + [dict get $bounds width] + 1) ||
        ($y < [dict get $bounds y]) ||
        ($y >= [dict get $bounds y] + [dict get $bounds height] + 1)
    } {
        $self clearCanvas $chart
        pix::ctx::drawImage $ctx [$chart get ctxImg] {0 0}
        pix::drawSurface $ctx [$chart get surface]
        return
    }
    
    set best_dist [expr {[dict get $bounds width] * 2}]
    set best_x 0
    set epoch ""
    set dist 0

    set ctxpath [$chart get ctxPath]
    set allc    [lsearch -all $ctxpath circle]
    
    foreach p $allc {
        set info [lindex $ctxpath $p+1]
        set xc [lindex [dict get $info coordinates] 0]
        set dist [expr {abs($xc - $x)}]
        if {$dist < $best_dist} {
            set best_dist $dist
            set epoch $xc
        }
    }

    if {$epoch eq ""} {return}

    set infoSeries {}

    foreach p $allc {
        set info [lindex $ctxpath $p+1]
        set xc [lindex [dict get $info coordinates] 0]

        if {$xc == $epoch} {
            lappend infoSeries $info
        }
    }

    $self clearCanvas $chart
    pix::ctx::drawImage $ctx [$chart get ctxImg] {0 0}
    set line 0
    
    dict set crosshair stroke_color "lightgray"
    dict set crosshair stroke_width 1
    dict set crosshair dashes {15 3 3 3}
    
    set xOpts [[$chart get xAxisConfigs] get]
    
    set font_size   [graphy::dictGet $xOpts -axisLabel fontSize]
    set font_family [graphy::dictGet $xOpts -axisLabel fontFamily]
    set name_rotate [graphy::dictGet $xOpts -axisLabel nameRotate]
    set tick_length [graphy::dictGet $xOpts -axisTick length]
    set decX 2

    dict set dataRect radius       {1 1 1 1}
    dict set dataRect stroke_width 0.5
    dict set dataRect stroke_color "rgb(80,87,101)"
    dict set dataRect fill_color   "rgb(80,87,101)"
    dict set dataRect sblur        0

    dict set dataText font_family $font_family
    dict set dataText font_size $font_size
    dict set dataText font_color "white"

    foreach info $infoSeries {
        set xc [lindex [dict get $info coordinates] 0]
        set yc [lindex [dict get $info coordinates] 1]
        set text_anchor "LeftAlign"
        set transform {}

        if {!$line} {
            # Vertical line
            dict set crosshair coordinates [list \
                [expr {int($xc) + 0.5}] \
                [dict get $bounds y]  \
                [expr {int($xc) + 0.5}] \
                [expr {[dict get $bounds y] + [dict get $bounds height]}]]
                            
            graphy::drawLine $ctx $crosshair
            
            # X values
            set xtext [dict get $info data xValue]
            set b [graphy::measuretextwidth $font_family $font_size $xtext]

            set xrect [expr {($xc - (([dict get $b right] - $decX) / 2.0)) - $decX}]
            set yrect [expr {[dict get $bounds y] + [dict get $bounds height] + $tick_length + 1}]

            set x [expr {$xc - ([dict get $b right] / 2.0)}]
            set y [expr {[dict get $bounds y] + [dict get $bounds height] + $tick_length + $font_size}]

            set rect [list \
                [list $xrect $yrect] \
                [list [expr {[dict get $b right] + $decX}] [dict get $b bottom]] \
            ]

            dict set dataRect rect $rect

            graphy::drawRoundedRect $ctx $dataRect $chart

            dict set dataText text_anchor $text_anchor
            dict set dataText transform $transform
            dict set dataText text $xtext
            dict set dataText x $x
            dict set dataText y $y

            graphy::drawText $ctx $dataText
        }
        
        # Horizontal line
        dict set crosshair coordinates [list \
            [dict get $bounds x] \
            [expr {int($yc) + 0.5}]  \
            [expr {[dict get $bounds x] + [dict get $bounds width]}] \
            [expr {int($yc) + 0.5}] \
        ]
        
        graphy::drawLine $ctx $crosshair
        
        set series     [dict get $info series]
        set optsSeries [$series get]

        set ytext         [dict get $info data yValue]
        set y_axis_index  [graphy::dictGet $optsSeries -yAxisIndex]
        set y_axis_config [$chart GetYAxisConfig $y_axis_index]

        dict set param thousands_format [graphy::isThousandFormat $y_axis_config]

        set yvalue        [graphy::formatParamsValue $param $ytext]
        set b             [graphy::measuretextwidth $font_family $font_size $yvalue]
        set yConfig       [$y_axis_config get]
        set axis_name_gap [graphy::dictGet $yConfig -axisLabel nameGap]
        
        
        if {$y_axis_index > 0} {
            set xx [expr {([dict get $bounds x] + [dict get $bounds width]) + ($axis_name_gap * 2)}]
        } else {
            set xx [expr {[dict get $bounds x] - [dict get $b right]}]
        }

        set rect [list \
            [list [expr {($xx - $axis_name_gap) - $decX}] [expr {$yc - ([dict get $b bottom] / 2.0)}]] \
            [list [expr {[dict get $b right] + ($decX * 2)}] [dict get $b bottom]] \
        ]
        dict set dataRect rect $rect

        graphy::drawRoundedRect $ctx $dataRect $chart

        dict set dataText text $yvalue
        dict set dataText x [expr {$xx - $axis_name_gap}]
        dict set dataText y [expr {$yc + ([dict get $b bottom] / 2.0) - (($font_size / 2.0) - 2)}]
        dict set dataText transform {}
        dict set dataText text_anchor "LeftAlign"

        graphy::drawText $ctx $dataText

        dict set info radius [expr {[dict get $info radius] + 1}]
        dict set info fill_color "white"
        
        graphy::drawCircle $ctx $info

        set line 1
    }

    pix::drawSurface $ctx [$chart get surface]

}