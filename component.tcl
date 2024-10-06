# Copyright (c) 2024 Nicolas ROBERT.
# Distributed under MIT license. Please see LICENSE for details.

namespace eval graphy {}

oo::class create graphy::Component::Text {

    variable _options {}

    constructor {args} {

        dict set _options text {}
        dict set _options font_family {}
        dict set _options font_size {}
        dict set _options font_color {}
        dict set _options line_height  {}
        dict set _options x  {}
        dict set _options y  {}
        dict set _options font_weight  {}
        dict set _options transform  {}
        dict set _options text_anchor "LeftAlign"
        dict set _options alignment_baseline "MiddleBaseline"
        dict set _options series {}

        if {[llength $args] % 2} {
            error "wrong args"
        }

        foreach {key value} $args {
            if {![dict exists $_options $key]} {
                error "'$key' not supported"
            }
            dict set _options $key $value
        }
    }

    method get {key} {
        return [dict get $_options {*}$key]
    }

    method set {key value} {
        if {![dict exists $_options $key]} {
            error "property '$key' doesn't exists for [info object class [self]] class."
        }
        dict set _options $key $value

        return {}
    }

    method options {} {
        return $_options
    }

    method entity {} {

        if {[my get text] eq ""} {
            return {}
        }

        set font_family [my get font_family]
        set font_size   [my get font_size]
        set text_anchor [my get text_anchor]
        set font_color  [my get font_color]
        set text        [my get text]
        set x           [my get x]
        set y           [my get y]
        set transform   [my get transform]
        set series      [my get series]

        my destroy

        return [list text [list \
            path {} \
            font_family $font_family \
            text_anchor $text_anchor \
            font_size   $font_size \
            font_color  $font_color \
            text        $text \
            x           $x \
            y           $y \
            transform   $transform \
            series      $series \
        ]]

    }

}

oo::class create graphy::Component::Legend {

    variable _options {}

    constructor {args} {

        dict set _options text {}
        dict set _options font_family {}
        dict set _options font_size {}
        dict set _options font_color {}
        dict set _options font_weight  {}
        dict set _options stroke_color  {}
        dict set _options stroke_width 1
        dict set _options fill  {}
        dict set _options left  {}
        dict set _options top  {}
        dict set _options category  {}
        dict set _options series  {}

        if {[llength $args] % 2} {
            error "wrong args"
        }

        foreach {key value} $args {
            if {![dict exists $_options $key]} {
                error "'$key' not supported"
            }
            dict set _options $key $value
        }
    }

    method get {key} {
        return [dict get $_options {*}$key]
    }

    method set {key value} {
        if {![dict exists $_options $key]} {
            error "property '$key' doesn't exists for [info object class [self]] class."
        }
        dict set _options $key $value

        return {}
    }

    method options {} {
        return $_options
    }

    method entity {} {

        set data {}

        switch -exact [my get category] {
            "normal" {
                set r 5.5

                lappend data [graphy::Component::Line new \
                    stroke_width [my get stroke_width] \
                    color [my get stroke_color] \
                    left [my get left] \
                    top [expr {[my get top] + $::graphy::LEGEND_HEIGHT / 2.0}] \
                    right [expr {[my get left] + $r + [my get stroke_width]}] \
                    bottom [expr {[my get top] + $::graphy::LEGEND_HEIGHT / 2.0}] \
                    series [my get series] \
                ]

                lappend data [graphy::Component::Circle new \
                    stroke_width [my get stroke_width] \
                    stroke_color [my get stroke_color] \
                    fill [my get fill] \
                    cx [expr {[my get left] + $::graphy::LEGEND_WIDTH / 2.0}] \
                    cy [expr {[my get top] + $::graphy::LEGEND_HEIGHT / 2.0}] \
                    r $r \
                    series [my get series] \
                ]

                lappend data [graphy::Component::Line new \
                    stroke_width [my get stroke_width] \
                    color [my get stroke_color] \
                    left [expr {[my get left] + ($r * 3) + [my get stroke_width]}] \
                    top [expr {[my get top] + $::graphy::LEGEND_HEIGHT / 2.0}] \
                    right [expr {[my get left] + $::graphy::LEGEND_WIDTH}] \
                    bottom [expr {[my get top] + $::graphy::LEGEND_HEIGHT / 2.0}] \
                    series [my get series] \
                ]
            }

            "rect" {
                set height 11
                lappend data [graphy::Component::Rect new \
                    color [my get stroke_color] \
                    fill [my get fill] \
                    left [my get left] \
                    top [expr {[my get top] + ($::graphy::LEGEND_HEIGHT - $height) / 2.0}] \
                    width $::graphy::LEGEND_WIDTH \
                    height $height \
                    radius {2 2 2 2} \
                    stroke_width [my get stroke_width] \
                    series [my get series] \
                ]

            }
            default {error "'[my get category]' legend category is not supported."}
        }

        lappend data [graphy::Component::Text new \
            text        [my get text] \
            font_family [my get font_family] \
            font_size   [my get font_size] \
            font_weight [my get font_weight] \
            font_color  [my get font_color] \
            x           [expr {[my get left] + $::graphy::LEGEND_WIDTH + $::graphy::LEGEND_TEXT_MARGIN}] \
            y           [expr {[my get top] + [my get font_size]}] \
            series      [my get series] \
        ]

        set listpath {}
        foreach obj $data {lappend listpath {*}[$obj entity]}

        my destroy

        return $listpath

    }

}

oo::class create graphy::Component::Grid {

    variable _options {}

    constructor {args} {

        dict set _options left 0
        dict set _options top 0
        dict set _options right 0
        dict set _options bottom 0
        dict set _options color  {}
        dict set _options stroke_width {}
        dict set _options verticals 0
        dict set _options stroke_dash_array 0
        dict set _options hidden_verticals  {}
        dict set _options horizontals {}
        dict set _options hidden_horizontals  {}

        if {[llength $args] % 2} {
            error "wrong args"
        }

        foreach {key value} $args {
            if {![dict exists $_options $key]} {
                error "'$key' not supported"
            }
            dict set _options $key $value
        }
    }

    method get {key} {
        return [dict get $_options {*}$key]
    }

    method set {key value} {
        if {![dict exists $_options $key]} {
            error "property '$key' doesn't exists for [info object class [self]] class."
        }
        dict set _options $key $value

        return {}
    }

    method options {} {
        return $_options
    }

    method entity {} {

        if {([my get verticals] == 0 && [my get horizontals] == 0)} {
            return {}
        }

        set points {}

        if {[my get verticals] != 0} {
            set unit [expr {([my get right] - [my get left]) / double([my get verticals])}]
            for {set index 0} {$index <= [my get verticals]} {incr index} {
                if {$index in [my get hidden_verticals]} {
                    continue
                }
                set x [expr {[my get left] + $unit * $index}]
                lappend points $x [my get top] $x [my get bottom]
            }
        }

        if {[my get horizontals] != 0} {
            set unit [expr {([my get bottom] - [my get top]) / double([my get horizontals])}]
            for {set index 0} {$index <= [my get horizontals]} {incr index} {
                if {$index in [my get hidden_horizontals]} {
                    continue
                }

                set y [expr {[my get top] + $unit * $index}]
                lappend points [my get left] $y [my get right] $y
            }
        }

        set data {}

        set stroke_width      [my get stroke_width] 
        set stroke_dash_array [my get stroke_dash_array] 

        foreach {left top right bottom} $points {
            lappend data [graphy::Component::Line new \
                stroke_width $stroke_width \
                stroke_dash_array $stroke_dash_array \
                color  [my get color] \
                left   [graphy::formatPixel $left $stroke_width] \
                top    [graphy::formatPixel $top $stroke_width] \
                right  [graphy::formatPixel $right $stroke_width] \
                bottom [graphy::formatPixel $bottom $stroke_width] \
            ]
        }

        set dataGrid {}
        foreach obj $data {lappend dataGrid [$obj entity]}

        my destroy

        return $dataGrid

    }

}

oo::class create graphy::Component::Circle {

    variable _options {}

    constructor {args} {

        dict set _options stroke_width {}
        dict set _options stroke_color {}
        dict set _options fill {}
        dict set _options cx {}
        dict set _options cy {}
        dict set _options r {}
        dict set _options series {}

        if {[llength $args] % 2} {
            error "wrong args"
        }

        foreach {key value} $args {
            if {![dict exists $_options $key]} {
                error "'$key' not supported"
            }
            dict set _options $key $value
        }
    }

    method get {key} {
        return [dict get $_options {*}$key]
    }

    method set {key value} {
        if {![dict exists $_options $key]} {
            error "property '$key' doesn't exists for [info object class [self]] class."
        }
        dict set _options $key $value

        return {}
    }

    method options {} {
        return $_options
    }

    method entity {} {

        set cx     [my get cx]
        set cy     [my get cy]
        set radius [my get r]
        set color  [my get stroke_color]
        set fill   [my get fill]
        set sw     [my get stroke_width]
        set series [my get series]

        set class [lindex [self caller] 0]

        if {$class eq "::graphy::Component::Legend"} {
            set type "legendcircle"
        } else {
            set type "circle"
        }

        my destroy

        return [list $type [list \
            coordinates [list $cx $cy] \
            stroke_color $color \
            fill_color $fill \
            radius $radius \
            stroke_width $sw \
            series $series \
        ]]
    }

}

oo::class create graphy::Component::Rect {

    variable _options {}

    constructor {args} {

        dict set _options color {}
        dict set _options fill {}
        dict set _options left {}
        dict set _options top {}
        dict set _options width {}
        dict set _options height {}
        dict set _options radius {0 0 0 0}
        dict set _options stroke_width 1
        dict set _options series {}
        dict set _options stroke_dash_array {}
        dict set _options sblur 0
        dict set _options scolor {}
        dict set _options soffsX {}
        dict set _options soffsY {}

        if {[llength $args] % 2} {
            error "wrong args"
        }

        foreach {key value} $args {
            if {![dict exists $_options $key]} {
                error "'$key' not supported"
            }
            dict set _options $key $value
        }
    }

    method get {key} {
        return [dict get $_options {*}$key]
    }

    method set {key value} {
        if {![dict exists $_options $key]} {
            error "property '$key' doesn't exists for [info object class [self]] class."
        }
        dict set _options $key $value

        return {}
    }

    method options {} {
        return $_options
    }

    method entity {} {

        set radius       [my get radius]
        set color        [my get color]
        set series       [my get series]
        set sblur        [my get sblur]
        set scolor       [my get scolor]
        set soffsX       [my get soffsX]
        set soffsY       [my get soffsY]
        set fill_color   [my get fill]
        set dashes       [my get stroke_dash_array]
        set stroke_width [my get stroke_width]

        set rect [list [list [my get left] [my get top]] [list [my get width] [my get height]]]
        set class [lindex [self caller] 0]

        if {$class eq "::graphy::Component::Legend"} {
            set type "legendroundedrect"
        } else {
            set type "roundedrect"
        }

        my destroy

        return [list $type [list \
            rect $rect \
            fill_color $fill_color \
            stroke_color $color \
            stroke_width $stroke_width \
            dashes $dashes \
            radius $radius \
            series $series \
            sblur  $sblur \
            scolor $scolor \
            soffsX $soffsX \
            soffsY $soffsY \
        ]]

    }

}


oo::class create graphy::Component::SmoothLineFill {

    variable _options {}

    constructor {args} {

        dict set _options fill {}
        dict set _options points {}
        dict set _options bottom {}

        if {[llength $args] % 2} {
            error "wrong args"
        }

        foreach {key value} $args {
            if {![dict exists $_options $key]} {
                error "'$key' not supported"
            }
            dict set _options $key $value
        }
    }

    method get {key} {
        return [dict get $_options {*}$key]
    }

    method set {key value} {
        if {![dict exists $_options $key]} {
            error "property '$key' doesn't exists for [info object class [self]] class."
        }
        dict set _options $key $value

        return {}
    }

    method options {} {
        return $_options
    }

    method entity {} {
        set fill_color [my get fill]
        set points     [my get points]
        set bottom     [my get bottom]

        my destroy

        return [list smoothlinefill [list \
            points $points \
            fill_color $fill_color \
            bottom $bottom \
        ]]

    }

}

oo::class create graphy::Component::StraightLineFill {

    variable _options {}

    constructor {args} {

        dict set _options fill {}
        dict set _options points {}
        dict set _options bottom {}
        dict set _options is_close true

        if {[llength $args] % 2} {
            error "wrong args"
        }

        foreach {key value} $args {
            if {![dict exists $_options $key]} {
                error "'$key' not supported"
            }
            dict set _options $key $value
        }
    }

    method get {key} {
        return [dict get $_options {*}$key]
    }

    method set {key value} {
        if {![dict exists $_options $key]} {
            error "property '$key' doesn't exists for [info object class [self]] class."
        }
        dict set _options $key $value

        return {}
    }

    method options {} {
        return $_options
    }

    method entity {} {

        set fill_color [my get fill]
        set is_close   [my get is_close]
        set pts        [my get points]
        set bottom     [my get bottom]

        my destroy

        return [list straightlinefill [list \
            points $pts \
            fill_color $fill_color \
            is_close $is_close \
            bottom $bottom \
        ]]

    }

}

oo::class create graphy::Component::SmoothLine {

    variable _options {}

    constructor {args} {

        dict set _options points {}
        dict set _options color {}
        dict set _options fill {}
        dict set _options stroke_width {}
        dict set _options symbol {}
        dict set _options stroke_dash_array {}
        dict set _options series {}
        dict set _options charts_value {}
        dict set _options sblur 0
        dict set _options scolor {}
        dict set _options soffsX {}
        dict set _options soffsY {}
        dict set _options bottom {}

        if {[llength $args] % 2} {
            error "wrong args"
        }

        foreach {key value} $args {
            if {![dict exists $_options $key]} {
                error "'$key' not supported"
            }
            dict set _options $key $value
        }
    }

    method get {key} {
        return [dict get $_options {*}$key]
    }

    method set {key value} {
        if {![dict exists $_options $key]} {
            error "property '$key' doesn't exists for [info object class [self]] class."
        }
        dict set _options $key $value

        return {}
    }

    method options {} {
        return $_options
    }

    method entity {} {

        set obj [graphy::Component::BaseLine new \
            color             [my get color] \
            fill              [my get fill] \
            points            [my get points] \
            stroke_width      [my get stroke_width] \
            symbol            [my get symbol] \
            is_smooth         true \
            is_close          false \
            stroke_dash_array [my get stroke_dash_array] \
            charts_value      [my get charts_value] \
            series            [my get series] \
            sblur             [my get sblur] \
            scolor            [my get scolor] \
            soffsX            [my get soffsX] \
            soffsY            [my get soffsY] \
            bottom            [my get bottom] \
        ]

        my destroy

        return [$obj entity]
        
    }

}

oo::class create graphy::Component::StraightLine {

    variable _options {}

    constructor {args} {

        dict set _options points {}
        dict set _options color {}
        dict set _options fill {}
        dict set _options stroke_width 1
        dict set _options symbol {}
        dict set _options stroke_dash_array {}
        dict set _options is_close false
        dict set _options charts_value {}
        dict set _options series {}
        dict set _options sblur  0
        dict set _options scolor {}
        dict set _options soffsX {}
        dict set _options soffsY {}
        dict set _options bottom {}

        if {[llength $args] % 2} {
            error "wrong args"
        }

        foreach {key value} $args {
            if {![dict exists $_options $key]} {
                error "'$key' not supported"
            }
            dict set _options $key $value
        }
    }

    method get {key} {
        return [dict get $_options {*}$key]
    }

    method set {key value} {
        if {![dict exists $_options $key]} {
            error "property '$key' doesn't exists for [info object class [self]] class."
        }
        dict set _options $key $value

        return {}
    }

    method options {} {
        return $_options
    }

    method entity {} {

        set obj [graphy::Component::BaseLine new \
            color             [my get color] \
            fill              [my get fill] \
            points            [my get points] \
            stroke_width      [my get stroke_width] \
            symbol            [my get symbol] \
            is_smooth         false \
            is_close          [my get is_close] \
            stroke_dash_array [my get stroke_dash_array] \
            charts_value      [my get charts_value] \
            series            [my get series] \
            sblur             [my get sblur] \
            scolor            [my get scolor] \
            soffsX            [my get soffsX] \
            soffsY            [my get soffsY] \
            bottom            [my get bottom] \
        ]

        my destroy

        return [$obj entity]
    }

}

oo::class create graphy::Component::BaseLine {

    variable _options {}

    constructor {args} {

        dict set _options stroke_width {}
        dict set _options color {}
        dict set _options fill {}
        dict set _options points {}
        dict set _options symbol {}
        dict set _options is_smooth {}
        dict set _options is_close {}
        dict set _options stroke_dash_array {}
        dict set _options charts_value {}
        dict set _options series {}
        dict set _options sblur  0
        dict set _options scolor {}
        dict set _options soffsX {}
        dict set _options soffsY {}
        dict set _options bottom {}

        if {[llength $args] % 2} {
            error "wrong args"
        }

        foreach {key value} $args {
            if {![dict exists $_options $key]} {
                error "'$key' not supported"
            }
            dict set _options $key $value
        }
    }

    method get {key} {
        return [dict get $_options {*}$key]
    }

    method set {key value} {
        if {![dict exists $_options $key]} {
            error "property '$key' doesn't exists for [info object class [self]] class."
        }
        dict set _options $key $value

        return {}
    }

    method options {} {
        return $_options
    }


    method entity {} {

        if {[my get points] eq "" || [my get stroke_width] <= 0.0} {
            return {}
        }

        set path  {}
        set lpath {}
        set color [my get color]
        if {[my get is_smooth]} {
            set smc [graphy::Component::SmoothCurve new \
                points   [my get points] \
                is_close [my get is_close] \
            ]

            lappend lpath smoothcurve [list \
                points       [my get points] \
                path         [$smc path] \
                stroke_color $color \
                fill_color   [my get fill] \
                dashes       [my get stroke_dash_array] \
                symbol       [my get symbol] \
                stroke_width [my get stroke_width] \
                series       [my get series] \
                symbol       [my get symbol] \
                charts_value [my get charts_value] \
                sblur        [my get sblur] \
                scolor       [my get scolor] \
                soffsX       [my get soffsX] \
                soffsY       [my get soffsY] \
                bottom       [my get bottom] \
            ]
        } else {

            lappend lpath strokeLine [list \
                points [my get points] \
                stroke_color $color \
                fill_color [my get fill] \
                stroke_width [my get stroke_width] \
                dashes [my get stroke_dash_array] \
                symbol [my get symbol] \
                is_close [my get is_close] \
                charts_value [my get charts_value] \
                series [my get series] \
                sblur  [my get sblur] \
                scolor [my get scolor] \
                soffsX [my get soffsX] \
                soffsY [my get soffsY] \
                bottom [my get bottom] \
            ]
        }

        my destroy

        return $lpath
    }

}

oo::class create graphy::Component::SmoothCurve {

    variable _options {}

    constructor {args} {

        dict set _options points {}
        dict set _options is_close false

        if {[llength $args] % 2} {
            error "wrong args"
        }

        foreach {key value} $args {
            if {![dict exists $_options $key]} {
                error "'$key' not supported"
            }
            dict set _options $key $value
        }
    }

    method get {key} {
        return [dict get $_options {*}$key]
    }

    method set {key value} {
        if {![dict exists $_options $key]} {
            error "property '$key' doesn't exists for [info object class [self]] class."
        }
        dict set _options $key $value

        return {}

    }

    method options {} {
        return $_options
    }

    method path {} {

        set tension 0.25
        set close [my get is_close]
        set lpoints [my get points]
        set count [llength $lpoints]
        set control_points {}
        set index 0

        foreach point $lpoints {
            set left ""
            set right ""

            if {$index >= 1} {
                set left [lindex $lpoints $index-1]
            } elseif {$close} {
                set left [lindex $lpoints end]
            }
            if {($index + 1) < $count} {
                set right [lindex $lpoints $index+1]
            } elseif {$close} {
                set right [lindex $lpoints 0]
            }

            lappend control_points [graphy::getControlPoints $point $left $right $tension]
            incr index
        }

        set index 0
        set arr {}
        foreach point $lpoints {
            lassign $point px py
            if {$index == 0} {
                append arr [format "M%s,%s " [graphy::format_float $px] [graphy::format_float $py]]
            }

            set cp1 [dict get [lindex $control_points $index] right]
            set cp2 ""


            if {[lindex $control_points $index+1] ne ""} {
                set cp2 [dict get [lindex $control_points $index+1] left]
            } elseif {$close} {
                set cp2 [dict get [lindex $control_points 0] left]
            }

            set next_point [lindex $lpoints $index+1]

            if {$close && ($index == $count - 1)} {
                set next_point [lindex $lpoints 0]
            }

            if {$next_point ne ""} {
                lassign $next_point npx npy
                set next_point_value [format "%s %s" [graphy::format_float $npx] [graphy::format_float $npy]]
                if {$cp1 ne ""} {
                    if {$cp2 ne ""} {
                        lassign $cp1 cp1x cp1y
                        lassign $cp2 cp2x cp2y
                        set c1 [format "%s %s" [graphy::format_float $cp1x] [graphy::format_float $cp1y]]
                        set c2 [format "%s %s" [graphy::format_float $cp2x] [graphy::format_float $cp2y]]

                        append arr [format "C%s, %s, %s " $c1 $c2 $next_point_value]
                        incr index ; continue
                    }
                }
            }
            incr index
        }

        my destroy

        return $arr
    }

}

oo::class create graphy::Component::Line {

    variable _options {}

    constructor {args} {

        dict set _options stroke_width {}
        dict set _options left {}
        dict set _options top {}
        dict set _options right {}
        dict set _options bottom {}
        dict set _options stroke_dash_array {}
        dict set _options color {}
        dict set _options series {}

        if {[llength $args] % 2} {
            error "wrong args"
        }

        foreach {key value} $args {
            if {![dict exists $_options $key]} {
                error "'$key' not supported"
            }
            dict set _options $key $value
        }
    }

    method get {key} {
        return [dict get $_options {*}$key]
    }

    method set {key value} {
        if {![dict exists $_options $key]} {
            error "property '$key' doesn't exists for [info object class [self]] class."
        }
        dict set _options $key $value

        return {}

    }

    method options {} {
        return $_options
    }

    method entity {} {

        set x0           [my get left]
        set y0           [my get top]
        set x1           [my get right]
        set y1           [my get bottom]
        set color        [my get color]
        set stroke_width [my get stroke_width]
        set dashes       [my get stroke_dash_array]
        set series       [my get series]

        my destroy

        return [list line [list \
            coordinates [list $x0 $y0 $x1 $y1] \
            stroke_color $color \
            stroke_width $stroke_width \
            dashes $dashes \
            series $series \
        ]]

    }

}

oo::class create graphy::Component::Axis {

    variable _options {}

    constructor {args} {

        dict set _options position bottom
        dict set _options split_number 0
        dict set _options font_size {}
        dict set _options font_family {}
        dict set _options data {}
        dict set _options formatter "nothing"
        dict set _options font_color {}
        dict set _options font_weight {}
        dict set _options stroke_color {}
        dict set _options stroke_width 1
        dict set _options name_gap 6
        dict set _options name_rotate 0
        dict set _options name_align "center"
        dict set _options left 0
        dict set _options top 0
        dict set _options width 0
        dict set _options height 0
        dict set _options tick_length {}
        dict set _options tick_start {}
        dict set _options tick_interval {}
        dict set _options tick_color {}
        dict set _options show_axis true
        dict set _options minor_tick false
        dict set _options name_axis "nothing"
        dict set _options name_loc {}
        dict set _options name_style {}
        dict set _options type {}
        
        if {[llength $args] % 2} {
            error "wrong args"
        }

        foreach {key value} $args {
            if {![dict exists $_options $key]} {
                error "'$key' not supported"
            }
            dict set _options $key $value
        }
    }

    method get {key} {
        return [dict get $_options $key]
    }

    method set {key value} {
        if {![dict exists $_options $key]} {
            error "property '$key' doesn't exists for [info object class [self]] class."
        }
        dict set _options $key $value

        return {}
    }

    method options {} {
        return $_options
    }

    method entity {} {

        set left          [my get left]
        set top           [my get top]
        set width         [my get width]
        set height        [my get height]
        set stroke_width  [my get stroke_width] 
        set tick_length   [my get tick_length]
        set data_axis     {}
        set data_ticks    {}
        set data_minticks {}

        if {[my get position] in {bottom top}} {
            set is_horizontal true
        } else {
            set is_horizontal false
        }

        if {[my get show_axis]} {
            switch -exact [my get position] {
                top    {
                    set y [expr {$top + $height}]
                    set values [list $left $y [expr {$left + $width}] $y]
                }
                right  {
                    set y [expr {$top + $height}]
                    set values [list $left $top $left $y]
                }
                bottom {
                    set values [list $left $top [expr {$left + $width}] $top]
                }
                left  {
                    set x [expr {$left + $width}]
                    set values [list $x $top $x [expr {$top + $height}]]
                }
            }

            lappend data_axis [graphy::Component::Line new \
                stroke_width $stroke_width \
                color  [my get stroke_color] \
                left   [graphy::formatPixel [lindex $values 0] $stroke_width] \
                top    [graphy::formatPixel [lindex $values 1] $stroke_width] \
                right  [graphy::formatPixel [lindex $values 2] $stroke_width] \
                bottom [graphy::formatPixel [lindex $values 3] $stroke_width] \
            ]
        }

        set axis_length [expr {$is_horizontal ? [my get width] : [my get height]}]

        set font_size [my get font_size]
        set formatter [my get formatter]

        set text_list {}
        set text_unit_count 1

        set data [my get data]
        set split_number [my get split_number]

        if {$split_number == 0} {
            set split_number [llength $data]
        }

        set text_list {}
        foreach item $data {
            lappend text_list [graphy::formatString $item $formatter]
        }

        if {[my get position] in {bottom top}} {
            set f [my get font_family]
            set total_measure [graphy::measuretextwidth $f $font_size $text_list]
            if {[graphy::widthBox $total_measure] > $axis_length} {
                set text_unit_count [expr {ceil($text_unit_count + [graphy::widthBox $total_measure] / $axis_length)}]
                set text_unit_count [expr {int($text_unit_count)}]
            }
        }

        if {[my get show_axis]} {
            set unit [expr {$axis_length / double($split_number)}]
            set tick_interval [expr {max([my get tick_interval], $text_unit_count)}]
            set tick_start [my get tick_start]
            set newindex 0

            for {set i 0} {$i <= $split_number} {incr i} {
                if {$i < $tick_start} {continue}

                set index [expr {($i > $tick_start) ? ($i - $tick_start) : $i}]
                if {($i != $tick_start) && (($tick_interval != 0) && ($index % $tick_interval != 0))} {
                    continue
                }

                switch -exact [my get position] {
                    top    {
                        set x [expr {double($left + $unit * $i)}]
                        set y [expr {$top + $height}]
                        set values [list $x [expr {$y - $tick_length}] $x $y]
                    }
                    right  {
                        set y [expr {double($top + $unit * $i)}]
                        set values [list $left $y [expr {$left + $tick_length}] $y]
                    }
                    bottom {
                        set x [expr {double($left + $unit * $i)}]
                        set values [list $x $top $x [expr {$top + $tick_length}]]
                    }
                    left  {
                        set y [expr {double($top + $unit * $i)}]
                        set x [expr {$left + $width}]
                        set values [list $x $y [expr {$x - $tick_length}] $y]
                    }
                }

                incr newindex

                lappend data_ticks [graphy::Component::Line new \
                    stroke_width $stroke_width \
                    color  [my get tick_color] \
                    left   [graphy::formatPixel [lindex $values 0] $stroke_width]  \
                    top    [graphy::formatPixel [lindex $values 1] $stroke_width] \
                    right  [graphy::formatPixel [lindex $values 2] $stroke_width] \
                    bottom [graphy::formatPixel [lindex $values 3] $stroke_width] \
                ]
            }
            
            if {[my get minor_tick]} {
                set typeticks "horizontal"
                for {set i 0} {$i < [llength $data_ticks] - 1} {incr i} {
                    set options  [[lindex $data_ticks $i] options]
                    set options1 [[lindex $data_ticks $i+1] options]
                    if {[dict get $options left] == [dict get $options right]} {
                        set typeticks "vertical"
                    }

                    switch -exact -- $typeticks {
                        "horizontal" {
                            set t  [dict get $options top]
                            set t1 [dict get $options1 top]
                            set yy [expr {(($t1 - $t) / 2.0) + $t}]
                            set fmrt [graphy::formatPixel $yy $stroke_width]
                            lappend data_minticks [graphy::Component::Line new \
                                stroke_width $stroke_width \
                                color  [my get tick_color] \
                                left   [dict get $options left]  \
                                top    $fmrt \
                                right  [expr {[dict get $options left] - ($tick_length / 2.0) - $stroke_width}]  \
                                bottom $fmrt \
                            ]

                        }
                        "vertical" {
                            set l  [dict get $options left]
                            set l1 [dict get $options1 left]
                            set xx [expr {(($l1 - $l) / 2.0) + $l}]
                            set fmrt [graphy::formatPixel $xx $stroke_width] 
                            lappend data_minticks [graphy::Component::Line new \
                                stroke_width $stroke_width \
                                color  [my get tick_color] \
                                left   $fmrt  \
                                top    [dict get $options top] \
                                right  $fmrt  \
                                bottom [expr {[dict get $options top] + ($tick_length / 2.0) + $stroke_width}] \
                            ]
                        }
                    }     
                }
            }

            # The new value for the split_number attribute.
            my set split_number $newindex
        }

        set text_data {}

        if {$text_list ne ""} {
            set name_gap [my get name_gap]
            set data_len [llength $data]

            if {[my get name_align] eq "left"} {
                set data_len [expr {$data_len - 1}]
            }

            set unit [expr {$axis_length / double($data_len)}]
            set f [my get font_family]
            set index 0
            foreach text $text_list {

                if {($index % $text_unit_count) != 0} {
                    incr index ; continue
                }

                set b [graphy::measuretextwidth $f $font_size $text]
                set unit_offset [expr {$unit * $index + $unit / 2.0}]
                
                if {[my get name_align] eq "left"} {
                    set unit_offset [expr {$unit_offset - $unit / 2.0}]
                }

                set text_width [graphy::widthBox $b]

                switch -exact [my get position] {
                    top    {
                        set x [expr {$left + $unit_offset - $text_width / 2.0}]
                        set y [expr {$top + $height - $name_gap}]
                        set values [list $x $y]
                    }
                    right  {
                        set x [expr {$left + $name_gap}]
                        set y [expr {$top + $unit_offset + $font_size / 2.0 - 2.0}]
                        set values [list $x $y]
                    }
                    bottom {
                        set x [expr {$left + $unit_offset - $text_width / 2.0}]
                        set y [expr {$top + $font_size + $name_gap}]
                        set values [list $x $y]
                    }
                    left  {
                        set x [expr {$left + $width - $text_width - $name_gap}]
                        set y [expr {$top + $unit_offset + $font_size / 2.0 - 2.0}]
                        set values [list $x $y]
                    }
                }

                set transform {}
                lassign $values x y

                set text_anchor "LeftAlign"

                if {[my get name_rotate] > 0.0} {
                    set name_rotate [expr {[my get name_rotate] * ($::graphy::PI / 180.0)}]
                    set w [expr {abs(sin($name_rotate)) * [graphy::widthBox $b]}]
                    set transx [expr {int($x + [graphy::widthBox $b] / 2.0)}]
                    set transy [expr {int($y + $w / 2.0)}]
                    set text_anchor "CenterAlign"
                    set transform [list $transx $transy $name_rotate]
                    set x 0.0
                    set y 0.0
                }

                lappend text_data [graphy::Component::Text new \
                    text        $text \
                    font_family [my get font_family] \
                    font_size   [my get font_size] \
                    font_weight [my get font_weight] \
                    font_color  [my get font_color] \
                    x           $x \
                    y           $y \
                    transform   $transform \
                    text_anchor $text_anchor \
                ]

                incr index
            }
        }

        if {[my get name_axis] ne "nothing"} {

            set style       [my get name_style]
            set text        [my get name_axis]
            set font_family [graphy::dictGet $style fontFamily]
            set font_weight [graphy::dictGet $style fontWeight]
            set font_size   [graphy::dictGet $style fontSize]
            set font_color  [graphy::dictGet $style fontColor]
            set bname       [graphy::measuretextwidth $font_family $font_size $text]

            switch -exact [my get type] {
                yleft  {
                    switch -exact [my get name_loc] {
                        "middle" {
                            set decx  [expr {([graphy::heightBox $bname] / 2.0) + 5.0}]
                            set decy  [expr {($top + $height) / 2.0}]
                            set angle [expr {270 * ($::graphy::PI / 180.0)}]
                            set text_anchor "CenterAlign"
                            set x 0.0 ; set y 0.0
                            set transform [list $decx $decy $angle]
                        }
                        "top"    {
                            set x [expr {$width + ([graphy::heightBox $bname])}]
                            set y [expr {$top - $font_size}]
                            set transform {}
                            set text_anchor "CenterAlign"
                        }
                        default  {error "name_loc must be 'middle' or 'top'."}
                    }
                }
                yright {
                    switch -exact [my get name_loc] {
                        "middle" {
                            set angle [expr {90 * ($::graphy::PI / 180.0)}]
                            set decx  [expr {($left + $width) - ([graphy::heightBox $bname] / 2.0) + 5.0}]
                            set decy  [expr {($top + $height) / 2.0}]
                            
                            set text_anchor "CenterAlign"
                            set x 0.0 ; set y 0.0
                            set transform [list $decx $decy $angle]
                        }
                        "top"    {
                            set x $left
                            set y [expr {$top - $font_size}]
                            set transform {}
                            set text_anchor "CenterAlign"
                        }
                        default  {error "name_loc must be 'middle' or 'top'."}
                    }
                }
                
                x {
                    set text_anchor "CenterAlign"
                    set transform {}
                    set y [expr {$top + $height - ([graphy::heightBox $bname] / 2.0)}]

                    switch -exact [my get name_loc] {
                        "middle" {
                            set x [expr {($left + ($width / 2.0))}]
                        }
                        "left" {
                            set x $left
                        }
                        "right" {
                            set x [expr {$left + $width}]
                        }
                        default  {error "name_loc must be 'middle', 'left' or 'right'."}
                    }
                }
                default {error "'type' must be 'yleft' or 'yright'."}
            }

            lappend text_data [graphy::Component::Text new \
                text        $text \
                font_family $font_family \
                font_size   $font_size \
                font_weight $font_weight \
                font_color  $font_color \
                x           $x \
                y           $y \
                transform   $transform \
                text_anchor $text_anchor \
            ]
            
        }
        
    
        set data {}

        foreach obj $data_axis     {lappend data [$obj entity]}
        foreach obj $data_ticks    {lappend data [$obj entity]}
        foreach obj $data_minticks {lappend data [$obj entity]}
        foreach obj $text_data     {lappend data [$obj entity]}

        my destroy

        return $data

    }

}

oo::class create graphy::Component::Arrow {

    variable _options {}

    constructor {args} {

        dict set _options x {}
        dict set _options y {}
        dict set _options width 10.0
        dict set _options stroke_color {}

        if {[llength $args] % 2} {
            error "wrong args"
        }

        foreach {key value} $args {
            if {![dict exists $_options $key]} {
                error "'$key' not supported"
            }
            dict set _options $key $value
        }
    }

    method get {key} {
        return [dict get $_options {*}$key]
    }

    method set {key value} {
        if {![dict exists $_options $key]} {
            error "property '$key' doesn't exists for [info object class [self]] class."
        }
        dict set _options $key $value

        return {}

    }

    method options {} {
        return $_options
    }

    method entity {} {

        set x_offset [expr {[my get width] / 2.0}]
        set y_offset $x_offset

        set points {}

        lappend points [list [my get x] [my get y]]
        lappend points [list [expr {[my get x] - $x_offset}] [expr {[my get y] - $y_offset}]]
        lappend points [list [expr {[my get x] + [my get width]}] [my get y]]
        lappend points [list [expr {[my get x] - $x_offset}] [expr {[my get y] + $y_offset}]]

        set sl [graphy::Component::StraightLineFill new \
            fill  [my get stroke_color] \
            points $points \
            is_close true \
        ]

        my destroy

        return [$sl entity]

    }

}

oo::class create graphy::Component::Bubble {

    variable _options {}

    constructor {args} {

        dict set _options x {}
        dict set _options y {}
        dict set _options r {}
        dict set _options fill {}

        if {[llength $args] % 2} {
            error "wrong args"
        }

        foreach {key value} $args {
            if {![dict exists $_options $key]} {
                error "'$key' not supported"
            }
            dict set _options $key $value
        }
    }

    method get {key} {
        return [dict get $_options {*}$key]
    }

    method set {key value} {
        if {![dict exists $_options $key]} {
            error "property '$key' doesn't exists for [info object class [self]] class."
        }
        dict set _options $key $value

        return {}

    }

    method options {} {
        return $_options
    }

    method entity {} {
        set x [my get x]
        set y [my get y]
        set r [my get r]

        set fill_color [my get fill]

        my destroy

        return [list bubble [list \
            fill_color $fill_color \
            coordinates [list $x $y] \
            radius $r \
        ]]
    }
}
