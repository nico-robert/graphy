# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

namespace eval graphy {}

oo::class create graphy::Canvas {
    variable _canvas     {}
    variable _margin     {}
    variable _width      {}
    variable _height     {}
    variable _components {}
    variable _surface    {}

    constructor {width height {margin ""}} {

        set _width  $width
        set _height $height
        set _components {}
        set _surface {}

        if {$margin eq ""} {
            set _margin [graphy::newBox 5]
        } else {
            set _margin $margin
        }
    }

    method width {} {
        return [expr {
            [my wCanvas] - [graphy::leftBox [my margin]] - [graphy::rightBox [my margin]]
        }]
    }

    method wCanvas {} {
        return $_width
    }

    method canvas {} {
        return $_canvas
    }

    method height {} {
        return [expr {
            [my hCanvas] - [graphy::topBox [my margin]] - [graphy::bottomBox [my margin]]
        }]
    }

    method hCanvas {} {
        return $_height
    }

    method margin {} {
        return $_margin
    }

    method surface {{value ""}} {
        if {$value eq ""} {
            return $_surface
        } else {
            set _surface $value
        }
    }

    method components {} {
        return $_components
    }

    method lappend {args} {
        lappend _components {*}$args

        return {}
    }

    method set {key value} {
        set $key $value

        return {}
    }

    method clearCanvas {ctx {color ""}} {

        pix::ctx::clearRect $ctx {0 0} [list [my wCanvas] [my hCanvas]]

        if {$color ne ""} {
            pix::ctx::save $ctx
            pix::ctx::fillStyle $ctx $color
            pix::ctx::fillRect $ctx {0 0} [list [my wCanvas] [my hCanvas]]
            pix::ctx::restore $ctx
        }
    }

    method text {ttext} {

        set font_family [$ttext get font_family]
        set font_size   [$ttext get font_size]
        set text        [$ttext get text]

        set cx [$ttext get x]
        set cy [$ttext get y]

        if {$cx ne ""} {
            set cx [expr {$cx + [graphy::leftBox [my margin]]}]
        } else {
            set cx [graphy::leftBox [my margin]]
        }

        if {$cy ne ""} {
            set cy [expr {$cy + [graphy::topBox [my margin]]}]
        } else {
            set cy [graphy::topBox [my margin]]
        }

        set b [graphy::newBox left $cx top $cy right 0.0 bottom 0.0]
        set result [graphy::measuretextwidth $font_family $font_size $text]
        graphy::setBox b right  [expr {[graphy::leftBox $b]   + [graphy::widthBox $result]}]
        graphy::setBox b bottom [expr {[graphy::bottomBox $b] + [graphy::heightBox $result]}]

        $ttext set x $cx
        $ttext set y $cy

        my lappend $ttext

        return $b
    }

    method legend {legend} {

        set font_family [$legend get font_family]
        set font_size   [$legend get font_size]
        set text        [$legend get text]

        set cl [$legend get left]
        set ct [$legend get top]
        set cl [expr {$cl + [graphy::leftBox [my margin]]}]
        set ct [expr {$ct + [graphy::topBox [my margin]]}]

        set measurement [graphy::measuretextwidth $font_family $font_size $text]

        set b [graphy::newBox \
            left $cl \
            top $ct \
            right [expr {$cl + [graphy::widthBox $measurement] + $::graphy::LEGEND_WIDTH}] \
            bottom [expr {$ct + [graphy::heightBox $measurement]}] \
        ]

        $legend set left $cl
        $legend set top $ct

        my lappend $legend

        return $b
    }

    method axis {axis} {
    
        set cleft [expr {[$axis get left] + [graphy::leftBox [my margin]]}]
        set ctop  [expr {[$axis get top]  + [graphy::topBox [my margin]]}]

        $axis set left $cleft
        $axis set top $ctop

        my lappend $axis

        return {}
    }

    method tbox {tbox} {
    
        $tbox set left [expr {[$tbox get left] + [graphy::leftBox [my margin]]}]

        my lappend $tbox

        return {}
    }

    method child {margin} {

        dict set m left   [expr {[graphy::leftBox $margin]   + [graphy::leftBox   [my margin]]}]
        dict set m top    [expr {[graphy::topBox $margin]    + [graphy::topBox    [my margin]]}]
        dict set m right  [expr {[graphy::rightBox $margin]  + [graphy::rightBox  [my margin]]}]
        dict set m bottom [expr {[graphy::bottomBox $margin] + [graphy::bottomBox [my margin]]}]

        set c [graphy::Canvas new [my wCanvas] [my hCanvas] $m]

        return $c
    }

    method grid {grid} {

        set cleft   [expr {[$grid get left]   + [graphy::leftBox [my margin]]}]
        set ctop    [expr {[$grid get top]    + [graphy::topBox  [my margin]]}]
        set cright  [expr {[$grid get right]  + [graphy::leftBox [my margin]]}]
        set cbottom [expr {[$grid get bottom] + [graphy::topBox  [my margin]]}]

        $grid set left $cleft
        $grid set top $ctop
        $grid set right $cright
        $grid set bottom $cbottom

        my lappend $grid

        return {}
    }

    method line {line} {

        set cleft   [expr {[$line get left]   + [graphy::leftBox [my margin]]}]
        set ctop    [expr {[$line get top]    + [graphy::topBox [my margin]]}]
        set cright  [expr {[$line get right]  + [graphy::leftBox [my margin]]}]
        set cbottom [expr {[$line get bottom] + [graphy::topBox [my margin]]}]

        $line set left $cleft
        $line set top $ctop
        $line set right $cright
        $line set bottom $cbottom

        my lappend $line

        return {}
    }

    method smooth_line {line} {

        set smoothpoints {}
        foreach p [$line get points] {
            lassign $p px py
            set px [expr {$px + [graphy::leftBox [my margin]]}]
            set py [expr {$py + [graphy::topBox [my margin]]}]
            lappend smoothpoints [list $px $py]
        }
        
        set cbottom [expr {[$line get bottom] + [graphy::topBox [my margin]]}]

        $line set points $smoothpoints
        $line set bottom $cbottom

        my lappend $line

        return {}
    }

    method circle {circle} {

        set ccx [expr {[$circle get cx] + [graphy::leftBox [my margin]]}]
        set ccy [expr {[$circle get cy] + [graphy::topBox [my margin]]}]

        $circle set cx $ccx
        $circle set cy $ccy

        my lappend $circle

        return {}
    }

    method arrow {arrow} {

        set cx [expr {[$arrow get x] + [graphy::leftBox [my margin]]}]
        set cy [expr {[$arrow get y] + [graphy::topBox [my margin]]}]

        $arrow set x $cx
        $arrow set y $cy

        my lappend $arrow

        return {}
    }

    method bubble {bubble} {

        set cx [expr {[$bubble get x] + [graphy::leftBox [my margin]]}]
        set cy [expr {[$bubble get y] + [graphy::topBox [my margin]]}]

        $bubble set x $cx
        $bubble set y $cy

        my lappend $bubble

        return {}

    }

    method rect {rect} {
    
        set cleft [expr {[$rect get left] + [graphy::leftBox [my margin]]}]
        set ctop  [expr {[$rect get top] + [graphy::topBox [my margin]]}]

        $rect set left $cleft
        $rect set top $ctop

        my lappend $rect

        return {}
    }

    method straight_line {line} {

        set lbm [graphy::leftBox [my margin]]
        set tbm [graphy::topBox [my margin]]

        set straightpoints [lmap p [$line get points] {
            list [expr {[lindex $p 0] + $lbm}] [expr {[lindex $p 1] + $tbm}]
        }]

        set cbottom [expr {[$line get bottom] + $tbm}]

        $line set bottom $cbottom
        $line set points $straightpoints

        my lappend $line

        return {}
    }

    method draw {chart} {
        # Draws the chart.
        #
        # chart - The chart object to draw.
        #
        # Returns widget name.

        set ctx [pix::ctx::new [list [my wCanvas] [my hCanvas]]]
        $chart set ctx $ctx

        set gopts      [$chart get global]
        set background [graphy::dictGet $gopts background]
        set entities   {}

        foreach {key obj} [my components] {
            if {$obj eq ""} {error "no $key object"}
            switch -exact $key {
                lineSeries - marklineSeries - labelSeries - 
                barSeries  - horizontalbarSeries {
                    set bseries {}
                    foreach objCompo [dict get $obj components] {
                        set data [$objCompo entity]
                        if {$data eq ""} {error "no '$key' object"}
                        lappend bseries {*}$data
                    }
                    lappend entities $key $bseries
                }
                default {
                    foreach objCompo $obj {
                        set data [$objCompo entity]
                        
                        if {$data eq ""} {error "no '$key' object"}
                        lappend entities $key $data
                    }
                }
            }
        }

        $chart set ctxPath [graphy::drawEntities $ctx $entities $chart dictimg]

        # Clear the canvas by drawing a rectangle with the background color.
        my clearCanvas $ctx $background

        # Draw all the images on the canvas.
        foreach {key image} $dictimg {
            pix::ctx::drawImage $ctx $image {0 0}
        }

        # Copy the full image from the canvas context ($ctx) and store it.
        dict set dictimg fullimage [pix::img::copy [dict get [pix::ctx::get $ctx] image addr]]

        $chart set ctxImg $dictimg

        if {[$chart get surface] eq ""} {
            my surface [image create photo]
        } else {
            my surface [$chart get surface]
        }

        $chart set surface [my surface]

        # Draw the surface of the chart
        # $ctx is the canvas context
        # This function is used to update the chart on the canvas whenever the chart changes
        pix::drawSurface $ctx [my surface]

        set w [string cat [$chart get parent] ".w" [string map {:: ""} $chart]]
        if {![winfo exists $w]} {
            $chart set widget $w
            label $w -image [my surface] -borderwidth 0 -anchor nw -padx 0 -pady 0
        }

        # Event loop.
        graphy::reDraw $w $chart [self]
        
        set dzoom [$chart get zoomData] 
        if {$dzoom eq ""} {
            dict set zoomData enable 0
            $chart set zoomData $zoomData
        }

        # Bind toolbox
        set opts             [graphy::getDictValueOrDefault $chart "toolbox"]
        set zoom_show        [graphy::dictGet $gopts toolbox dataZoom show]
        set save_as_img_show [graphy::dictGet $gopts toolbox saveAsImage show]

        if {$zoom_show} {
            bind $w <Motion>           [list graphy::tBoxIcon      %x %y %W $chart [self]]
            bind $w <ButtonRelease-1>  [list graphy::tBoxAction    %x %y %W $chart [self]]
            bind $w <ButtonPress-1>    [list graphy::zoomDragStart %x %y %W $chart [self]]
            bind $w <Button1-Motion>   [list graphy::zoomDragMove  %x %y %W $chart [self]]
            bind $w <ButtonRelease-1> +[list graphy::zoomDragEnd   %x %y %W $chart [self]]
        } elseif {!$zoom_show && $save_as_img_show} {
            bind $w <Motion>           [list graphy::tBoxIcon      %x %y %W $chart [self]]
            bind $w <ButtonRelease-1>  [list graphy::tBoxAction    %x %y %W $chart [self]]
        }

        bind $w <Destroy> [list graphy::cleanDataCharts $chart]
        
        return $w
    }
}