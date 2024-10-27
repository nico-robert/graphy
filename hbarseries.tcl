# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

oo::class create graphy::series::HorizontalBar {

    variable _series {}
    variable _info   {}

    constructor {args} {

        if {[llength $args] % 2} graphy::errorEvenArgs
    
        graphy::setdef options -name            -validvalue {}  -type str       -default [graphy::seriesDefaultName barSeries [self]]
        graphy::setdef options -data            -validvalue {}  -type str       -default {}
        graphy::setdef options -startIndex      -validvalue {}  -type num       -default 0
        graphy::setdef options -indexColor      -validvalue {}  -type num|null  -default "nothing"
        graphy::setdef options -yAxisIndex      -validvalue {}  -type num       -default 0
        graphy::setdef options -label           -validvalue {}  -type dict      -default [graphy::label $args "-label"]
        graphy::setdef options -markLine        -validvalue {}  -type dict|null -default [graphy::markLine $args]
        graphy::setdef options -markPoint       -validvalue {}  -type dict|null -default [graphy::markPoint $args]
        graphy::setdef options -lineStyle       -validvalue {}  -type dict      -default [graphy::lineStyle $args "-lineStyle"]
        graphy::setdef options -itemStyle       -validvalue {}  -type dict      -default [graphy::itemStyle $args "-itemStyle"]
        graphy::setdef options -areaStyle       -validvalue {}  -type dict|null -default [graphy::areaStyle $args]
        graphy::setdef options -emphasis        -validvalue {}  -type bool      -default "False"
        graphy::setdef options -showBackground  -validvalue {}  -type bool      -default "False"
        graphy::setdef options -backgroundStyle -validvalue {}  -type dict      -default [graphy::backgroundStyle $args]
        graphy::setdef options -barHeight       -validvalue {}  -type num|null  -default "nothing"
        graphy::setdef options -show            -validvalue {}  -type bool      -default "True"
        graphy::setdef options -stacked         -validvalue {}  -type bool      -default "False"
        graphy::setdef options -clip            -validvalue {}  -type bool      -default "False"

        set args [dict remove $args -areaStyle -label -markLine -markPoint -lineStyle -itemStyle -backgroundStyle]
        
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
        return "horizontalbar"
    }

}

proc graphy::horizontalBarSeries {c chart series index indexSeries y_axis_values_list max_width x_axis_values} {

    set bar_chart_margin 5.0
    set bar_chart_gap    3.0
    set decY             0.0
    set optsSeries [$series get]
    if {$index >= [llength $y_axis_values_list]} {
        set y_axis_values [lindex $y_axis_values_list 0]
    } else {
        set y_axis_values [lindex $y_axis_values_list [graphy::dictGet $optsSeries -yAxisIndex]]
    }

    set series_data_count       [llength [dict get $y_axis_values data]]
    set unit_height             [expr {[$c height] / double($series_data_count)}]
    set bar_chart_margin_height [expr {$bar_chart_margin * 2.0}]

    set indexcolor [expr {
        [graphy::dictTypeOf $optsSeries -indexColor] eq "null" 
        ? $indexSeries 
        : [graphy::dictGet $optsSeries -indexColor]
    }]

    set tradius [graphy::dictTypeOf $optsSeries -itemStyle borderRadius]
    set radius  [graphy::dictGet    $optsSeries -itemStyle borderRadius]

    if {$tradius eq "num"} {
        set radius [lrepeat 4 $radius]
    } else {
        set radius {*}$radius
    }

    set gopts              [graphy::getDictValueOrDefault $chart "color"]
    set series_colors      [graphy::dictGet $gopts color]
    set color              [graphy::getColor $series_colors $indexcolor]
    set series_labels_list [dict create]
    set start_index        [graphy::dictGet $optsSeries -startIndex]
    set label_show         [graphy::dictGet $optsSeries -label show]
    set fillcolor $color
    set series_labels {}
    set i 0

    if {[graphy::dictGet $optsSeries -areaStyle] ne "nothing"} {
        set opacity [graphy::dictGet $optsSeries -areaStyle opacity]
        if {[graphy::dictGet $optsSeries -areaStyle color] eq "nothing"} {
            lassign [pix::colorHTMLtoRGBA $color] r g b
            set fillcolor "rgba($r,$g,$b,$opacity)"
        } else {
            if {[graphy::dictTypeOf $optsSeries -areaStyle color] eq "str"} {
                set aeraColor [graphy::dictGet $optsSeries -areaStyle color]
                lassign [pix::colorHTMLtoRGBA $aeraColor] r g b
                set fillcolor "rgba($r,$g,$b,$opacity)"
            } else {
                set fillcolor [graphy::dictGet $optsSeries -areaStyle color]
            }
        }
    }
    
    if {[graphy::dictTypeOf $optsSeries -lineStyle color] ne "null"} {
        set color [graphy::dictGet $optsSeries -lineStyle color]
    }
    
    set stroke_width [graphy::dictGet $optsSeries -lineStyle width]
    set sblur        [graphy::dictGet $optsSeries -lineStyle shadowBlur]
    set scolor       [graphy::dictGet $optsSeries -lineStyle shadowColor]
    set soffsX       [graphy::dictGet $optsSeries -lineStyle shadowOffsetX]
    set soffsY       [graphy::dictGet $optsSeries -lineStyle shadowOffsetY]
    
    # Style background
    set showBackground [graphy::dictGet $optsSeries -showBackground]
    set tbradius       [graphy::dictTypeOf $optsSeries -backgroundStyle borderRadius]
    set rbadius        [graphy::dictGet    $optsSeries -backgroundStyle borderRadius]
    set stroke_widthB  [graphy::dictGet    $optsSeries -backgroundStyle width]
    set colorB         [graphy::dictGet    $optsSeries -backgroundStyle borderColor]
    set fillcolorB     [graphy::dictGet    $optsSeries -backgroundStyle color]
    set sblurB         [graphy::dictGet    $optsSeries -backgroundStyle shadowBlur]
    set scolorB        [graphy::dictGet    $optsSeries -backgroundStyle shadowColor]
    set soffsXB        [graphy::dictGet    $optsSeries -backgroundStyle shadowOffsetX]
    set soffsYB        [graphy::dictGet    $optsSeries -backgroundStyle shadowOffsetY]

    if {$tbradius eq "num"} {
        set rbadius [lrepeat 4 $rbadius]
    } else {
        set rbadius {*}$rbadius
    }

    # Stacked bars.
    set isStacked      [graphy::dictGet $optsSeries -stacked]
    set series_list    [lmap mys [$chart get seriesList] {if {[$mys type] eq "horizontalbar"} {list $mys} else {continue}}]
    set firstSeriesBar [lindex $series_list 0]
    set index_series   [lsearch -exact $series_list $series]
    set series_ms1     [lindex $series_list $index_series-1]


    for {set j $index_series} {$j > 0} {incr j -1} {
        set mys [lindex $series_list $j]
        if {[graphy::dictGet [$mys get] -stacked]} {
            incr index -1
        }
    }

    foreach myseries $series_list {
        # The first series does not need to be stacked.
        if {$myseries eq $firstSeriesBar || ![graphy::dictGet [$myseries get] -stacked]} {
            incr series_bar_len
        }
    }

    if {!$series_bar_len} {
        set series_bar_len 1
    }

    set bar_chart_gap_height [expr {$bar_chart_gap * ($series_bar_len - 1)}]
    set bar_height           [expr {($unit_height - $bar_chart_margin_height - $bar_chart_gap_height) / double($series_bar_len)}]

    if {[graphy::dictGet $optsSeries -barHeight] ne "nothing"} {
        set bh [graphy::dictGet $optsSeries -barHeight]
        if {$bh < $bar_height} {
            set decY [expr {(($bar_height - $bh) / 2.0) * $series_bar_len}]
            set bar_height $bh
        }
    }

    set half_bar_height [expr {$bar_height / 2.0}]

    foreach value [lreverse [graphy::dictGet $optsSeries -data]] {
        if {$value in {null _}} {
            if {$series_ms1 ne "" && [dict exists $infoms1 xPosBar($i)]} {
                $series setInfo xPosBar($i) [dict get $infoms1 xPosBar($i)]
            }
            incr i ; continue
        }

        set top [expr {$unit_height * double($series_data_count - $i - 1) + $bar_chart_margin}]
        set top [expr {$top + ($bar_height + $bar_chart_gap) * $index}]
        set top [expr {$top + $decY}]

        set w [graphy::getOffsetWidth $x_axis_values $value $max_width]
        set x 0.0

        if {$isStacked && $series_ms1 ne ""} {
            set infoms1 [$series_ms1 getInfo]
            if {[dict exists $infoms1 xPosBar($i)]} {
                set x [dict get $infoms1 xPosBar($i)]
            }
        }

        $series setInfo xPosBar($i) [expr {$x + $w}]

        if {$showBackground} {
            $c rect [graphy::Component::Rect new \
                color $colorB \
                fill $fillcolorB \
                stroke_width $stroke_widthB \
                left 0 \
                top $top \
                width $max_width \
                height $bar_height \
                radius $rbadius \
                series $series \
                sblur  $sblurB \
                scolor $scolor \
                soffsX $soffsXB \
                soffsY $soffsYB \
            ]
        }

        $c rect [graphy::Component::Rect new \
            color $color \
            fill $fillcolor \
            top $top \
            left $x \
            stroke_width $stroke_width \
            width $w \
            height $bar_height \
            radius $radius \
            series $series \
            sblur  $sblur \
            scolor $scolor \
            soffsX $soffsX \
            soffsY $soffsY \
        ]

        if {$label_show} {

            set font_family [graphy::dictGet $optsSeries -label fontFamily]
            set font_size   [graphy::dictGet $optsSeries -label fontSize]
            set name_rotate [graphy::dictGet $optsSeries -label nameRotate]
            set name_format [graphy::dictGet $optsSeries -label formatter]

            set textformat [graphy::formatSeriesValue $value $name_format]
            set textformat [graphy::formatString $textformat $name_format]

            set b [graphy::measuretextwidth $font_family $font_size $textformat]
            switch -exact [graphy::dictGet $optsSeries -label align] {
                center  {
                    set posx [expr {($x + $w / 2.0)}]
                    set posy [expr {$top + $half_bar_height + ([graphy::heightBox $b] / 2.0)}]
                }
                top  {
                    set posx [expr {$x + $w + ([graphy::widthBox $b] / 2.0) + 1.0}]
                    set posy [expr {$top + $half_bar_height + ([graphy::heightBox $b] / 2.0)}]
                }
                default {error "Unknown -label 'align' option"}
            }
            lappend series_labels [list \
                point [list $posx $posy] \
                text $textformat \
            ]
        }

        incr i
    }

    if {$label_show} {
        dict set series_labels_list $series $series_labels
    }

    return $series_labels_list

}