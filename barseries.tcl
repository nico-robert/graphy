# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

namespace eval graphy {}

oo::class create graphy::series::Bar {

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
        graphy::setdef options -barWidth        -validvalue {}  -type num|null  -default "nothing"
        graphy::setdef options -show            -validvalue {}  -type bool      -default "True"
        graphy::setdef options -stacked         -validvalue {}  -type bool      -default "False"

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
        return "bar"
    }

}

proc graphy::barSeries {c chart series index indexSeries y_axis_values_list max_height xParams} {
    
    set bar_chart_margin 5.0
    set bar_chart_gap    3.0
    set decX             0.0
    set series_bar_len   0
    set optsSeries             [$series get]
    set series_data_count      [llength [dict get $xParams data]]
    set unit_width             [expr {[$c width] / double($series_data_count)}]
    set bar_chart_margin_width [expr {$bar_chart_margin * 2.0}]

    if {$index >= [llength $y_axis_values_list]} {
        set y_axis_values [lindex $y_axis_values_list 0]
    } else {
        set y_axis_values [lindex $y_axis_values_list [graphy::dictGet $optsSeries -yAxisIndex]]
    }

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
    set series_list    [lmap mys [$chart get seriesList] {if {[$mys type] eq "bar"} {list $mys} else {continue}}]
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

    set bar_chart_gap_width [expr {$bar_chart_gap * ($series_bar_len - 1)}]
    set bar_width  [expr {($unit_width - $bar_chart_margin_width - $bar_chart_gap_width) / double($series_bar_len)}]

    if {[graphy::dictGet $optsSeries -barWidth] ne "nothing"} {
        set bw [graphy::dictGet $optsSeries -barWidth]
        if {$bw < $bar_width} {
            set decX [expr {(($bar_width - $bw) / 2.0) * $series_bar_len}]
            set bar_width $bw
        }
    }

    set half_bar_width [expr {$bar_width / 2.0}]
    
    set xMin [dict get $xParams min]
    set xMax [dict get $xParams max]

    foreach value [lrange [graphy::dictGet $optsSeries -data] $xMin $xMax-1] {
        if {$value in {null _}} {
            if {($series_ms1 ne "") && [dict exists $infoms1 yPosBar($i)]} {
                $series setInfo yPosBar($i) [dict get $infoms1 yPosBar($i)]
            }
            incr i ; continue
        }

        set left [expr {$unit_width * ($i + $start_index) + $bar_chart_margin}]
        set left [expr {$left + ($bar_width + $bar_chart_gap) * $index}]
        set left [expr {$left + $decX}]

        set y      [graphy::getOffsetHeight $y_axis_values $value $max_height]
        set height [expr {$max_height - $y}]

        if {$isStacked && $series_ms1 ne ""} {
            set infoms1 [$series_ms1 getInfo]
            if {[dict exists $infoms1 yPosBar($i)]} {
                set y [expr {[dict get $infoms1 yPosBar($i)] - $height}]
            }
        }

        $series setInfo yPosBar($i) $y

        if {$showBackground} {
            $c rect [graphy::Component::Rect new \
                color $colorB \
                fill $fillcolorB \
                stroke_width $stroke_widthB \
                left $left \
                top 0 \
                width $bar_width \
                height $max_height \
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
            left $left \
            top $y \
            stroke_width $stroke_width \
            width $bar_width \
            height $height \
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
                top     {set posy $y}
                center  {set posy [expr {$y + ($height / 2.0) + [graphy::heightBox $b] / 2.0}]}
                default {error "Unknown -label 'align' option"}
            }
            lappend series_labels [list \
                point [list [expr {$left + $half_bar_width}] $posy] \
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
