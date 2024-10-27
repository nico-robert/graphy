# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

oo::class create graphy::series::Line {

    variable _series {}
    variable _info   {}

    constructor {args} {
    
        if {[llength $args] % 2} graphy::errorEvenArgs
    
        graphy::setdef options -name        -validvalue {}  -type str       -default [graphy::seriesDefaultName lineSeries [self]]
        graphy::setdef options -type        -validvalue {}  -type str       -default "line"
        graphy::setdef options -data        -validvalue {}  -type str       -default {}
        graphy::setdef options -startIndex  -validvalue {}  -type num       -default 0
        graphy::setdef options -indexColor  -validvalue {}  -type num|null  -default "nothing"
        graphy::setdef options -yAxisIndex  -validvalue {}  -type num       -default 0
        graphy::setdef options -label       -validvalue {}  -type dict      -default [graphy::label $args "-label"]
        graphy::setdef options -markLine    -validvalue {}  -type dict|null -default [graphy::markLine $args]
        graphy::setdef options -markPoint   -validvalue {}  -type dict|null -default [graphy::markPoint $args]
        graphy::setdef options -lineStyle   -validvalue {}  -type dict      -default [graphy::lineStyle $args "-lineStyle"]
        graphy::setdef options -areaStyle   -validvalue {}  -type dict|null -default [graphy::areaStyle $args]
        graphy::setdef options -smooth      -validvalue {}  -type bool      -default "False"
        graphy::setdef options -emphasis    -validvalue {}  -type bool      -default "False"
        graphy::setdef options -symbol      -validvalue {}  -type str       -default "circle"
        graphy::setdef options -showSymbol  -validvalue {}  -type bool      -default "True"
        graphy::setdef options -show        -validvalue {}  -type bool      -default "True"
        graphy::setdef options -clip        -validvalue {}  -type bool      -default "False"

        set args [dict remove $args -areaStyle -label -markLine -markPoint -lineStyle]
        
        set _series [graphy::merge $options $args]
        set _info {}

    }
    
    method setInfo {key args} {
        dict set _info $key {*}$args
        return {}
    }
    
    method getInfo {} {
        return $_info
    }

    method get {} {
        return $_series
    }

    method type {} {
        return "line"
    }

}

proc graphy::lineSeries {c chart series index indexSeries y_axis_values_list max_height xOpts xParams axis_width axis_height} {
    
    set xParamsData       [dict get $xParams data]
    set series_data_count [llength $xParamsData]
    set x_boundary_gap    [graphy::dictGet $xOpts -boundaryGap]
    set x_type            [graphy::dictGet $xOpts -type]
    set split_unit_offset 0.0

    if {!$x_boundary_gap} {
        set split_unit_offset 1.0
    }
    
    set optsSeries [$series get]

    set series_labels_list [dict create]
    if {[graphy::dictGet $optsSeries -yAxisIndex] >= [llength $y_axis_values_list]} {
        set y_axis_values [lindex $y_axis_values_list 0]
    } else {
        set y_axis_values [lindex $y_axis_values_list [graphy::dictGet $optsSeries -yAxisIndex]]
    }

    set split_unit_count [expr {double($series_data_count) - $split_unit_offset}]

    if {$split_unit_count == 0} {
        set split_unit_count 1.0
    }

    set unit_width [expr {[$c width] / $split_unit_count}]
    set points {}
    set points_list {}
    set series_labels {}
    set max_value -Inf
    set min_value Inf
    set max_index 0
    set min_index 0
    set sum 0.0
    set j 0
    set startIndex [graphy::dictGet $optsSeries -startIndex]
    set labelShow  [graphy::dictGet $optsSeries -label show]
    set markPoint  [graphy::dictTypeOf $optsSeries -markPoint]
    
    set ydata [graphy::dictGet $optsSeries -data]
    set xData [graphy::dictGet $xOpts -data]
    set len   [llength $ydata]

    for {set i $startIndex} {$i < $len} {incr i} {
    
        set yvalue [lindex $ydata $i]

        if {$yvalue in {null _}} {
            if {$points ne ""} {
                lappend points_list $points
                set points {}
            }
            incr j ; continue
        }
        set xvalue [lindex $xData $i]

        lappend tvalue($j) [list xValue $xvalue yValue $yvalue]
        
        set sum [expr {$sum + $yvalue}]

        if {$yvalue > $max_value} {
            set max_value $yvalue
            set max_index $i
        }

        if {$yvalue < $min_value} {
            set min_value $yvalue
            set min_index $i
        }

        if {$x_type eq "value"} {
            set xv $xvalue
        } else {
            set xv $i
        }

        set x [graphy::getOffsetWidth $xParams $xv $axis_width]
        if {$x_boundary_gap || ($series_data_count == 1)} {
            set x [expr {$x + $unit_width / 2.0}]
        }

        set y [graphy::getOffsetHeight $y_axis_values $yvalue $max_height]
        lappend points [list $x $y]

        if {($markPoint ne "null") || $labelShow} {
            lappend series_labels [list \
                point [list $x $y] \
                text $yvalue \
            ]
        }
    }
    
    # Store the maximum, minimum, and sum of the values
    # in the series's info dictionary.
    $series setInfo maxValue $max_value
    $series setInfo minValue $min_value
    $series setInfo sumValue $sum

    if {$labelShow} {
        dict set series_labels_list $series $series_labels
    }

    if {$points ne ""} {lappend points_list $points}

    set indexcolor [expr {
        [graphy::dictTypeOf $optsSeries -indexColor] eq "null" 
        ? $indexSeries 
        : [graphy::dictGet $optsSeries -indexColor]
    }]

    set gopts [$chart get global]
    set series_colors [graphy::dictGet $gopts color]

    set color [graphy::getColor $series_colors $indexcolor]
    set fill {}

    # Get the line style from the series options
    if {[graphy::dictTypeOf $optsSeries -lineStyle] ne "null"} {
        # Get the color from the line style
        if {[graphy::dictTypeOf $optsSeries -lineStyle color] ne "null"} {
            set color [graphy::dictGet $optsSeries -lineStyle color]
        }
    }
    
    set isTypecolor 0

    # Get the area style from the series options
    if {[graphy::dictTypeOf $optsSeries -areaStyle] ne "null"} {
        # Get the color from the area style
        if {[graphy::dictTypeOf $optsSeries -areaStyle color] ne "null"} {
            if {[graphy::dictTypeOf $optsSeries -areaStyle color] eq "paint"} {
                set isTypecolor 1
            }
            set aeraColor [graphy::dictGet $optsSeries -areaStyle color]
        } else {
            # If the color is not specified, use the color from the line style
            set aeraColor $color
        }
        if {!$isTypecolor} {
            # Convert the color to RGBA
            lassign [pix::colorHTMLtoRGBA $aeraColor] r g b

            # Get the opacity from the area style
            set opacity [graphy::dictGet $optsSeries -areaStyle opacity]

            # Create the fill color with the opacity
            set fill "rgba($r,$g,$b,$opacity)"
        } else {
            set fill $aeraColor
        }
    }

    set j 0
    set stroke_width      [graphy::dictGet $optsSeries -lineStyle width]
    set stroke_dash_array [expr {
        [graphy::dictTypeOf $optsSeries -lineStyle dashes] eq "null" 
        ? {} 
        : [graphy::dictGet $optsSeries -lineStyle dashes]
    }]

    set symbol [graphy::dictGet $optsSeries -showSymbol]
    set sblur  [graphy::dictGet $optsSeries -lineStyle shadowBlur]
    set scolor [graphy::dictGet $optsSeries -lineStyle shadowColor]
    set soffsX [graphy::dictGet $optsSeries -lineStyle shadowOffsetX]
    set soffsY [graphy::dictGet $optsSeries -lineStyle shadowOffsetY]
    
    foreach pts $points_list {
        if {[graphy::dictGet $optsSeries -smooth]} {

            set sl [graphy::Component::SmoothLine new \
                points $pts \
                color $color \
                fill  $fill \
                stroke_width $stroke_width \
                symbol $symbol \
                stroke_dash_array $stroke_dash_array \
                charts_value $tvalue($j) \
                series $series \
                sblur  $sblur \
                scolor $scolor \
                soffsX $soffsX \
                soffsY $soffsY \
                bottom $axis_height \
            ]

            $c smooth_line $sl
        } else {

            set sl [graphy::Component::StraightLine new \
                points $pts \
                color $color \
                fill  $fill \
                stroke_width $stroke_width \
                symbol $symbol \
                stroke_dash_array $stroke_dash_array \
                charts_value $tvalue($j) \
                series $series \
                sblur  $sblur \
                scolor $scolor \
                soffsX $soffsX \
                soffsY $soffsY \
                bottom $axis_height \
            ]
            $c straight_line $sl
        }

        incr j
    }
    
    if {$markPoint ne "null"} {
        foreach {k item} [graphy::dictGet $optsSeries -markPoint] {

            switch -exact [graphy::dictGet $item category] {
                max     {set indexcategory $max_index}
                min     {set indexcategory $min_index}
                default {error "'[dict get $item category]' not supported"}
            }

            set infolabel [lindex $series_labels $indexcategory]

            if {$infolabel ne ""} {
                lassign [dict get $infolabel point] x y
                set r 15.0
                set y [expr {$y - $r * 2.0}]
                $c bubble [graphy::Component::Bubble new \
                    x $x \
                    y $y \
                    r $r \
                    fill $color \
                    series $series \
                ]
                set text       [dict get $infolabel text]
                set formatter  [graphy::dictGet $item label formatter]
                set fontSize   [graphy::dictGet $item label fontSize]
                set fontFamily [graphy::dictGet $item label fontFamily]
                set fontColor  [graphy::dictGet $item label fontColor]
                set textformat [graphy::formatSeriesValue $text $formatter]

                set b [graphy::measuretextwidth $fontFamily $fontSize $textformat]

                set x [expr {$x - ([graphy::widthBox $b] / 2.0 + 1.0)}]
                $c text [graphy::Component::Text new  \
                    text        $textformat \
                    font_family $fontFamily \
                    font_size   $fontSize \
                    font_color  $fontColor \
                    x           $x \
                    y           [expr {$y + 2.0}] \
                    series      $series \
                ]
            }
        }
    }

    return $series_labels_list
}