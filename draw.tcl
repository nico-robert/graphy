# Copyright (c) 2024 Nicolas ROBERT.
# Distributed under MIT license. Please see LICENSE for details.

namespace eval graphy {}

proc graphy::drawBlurImage {ctx data chart path} {
    # Draw a blurred image
    set polygonImage [pix::img::new [list [$chart get width] [$chart get height]]]

    # Draw the line on the new image. The line is drawn with the same
    # stroke color, width, and dashes as specified in the data.
    pix::img::strokePath $polygonImage $path [dict get $data stroke_color] [list \
        strokeWidth [dict get $data stroke_width] \
        dashes [dict get $data dashes] \
    ]

    set offset [list [dict get $data soffsX] [dict get $data soffsY]]
    set color  [dict get $data scolor]
    set blur   [dict get $data sblur]

    # Create a shadow effect for the line.
    set shadow [pix::img::shadow $polygonImage [list offset $offset spread 1 blur $blur color $color]]

    # Draw the shadow on the canvas at position (0,0).
    pix::ctx::drawImage $ctx $shadow {0 0}
    pix::ctx::drawImage $ctx $polygonImage {0 0}

    pix::img::destroy $shadow
    pix::img::destroy $polygonImage

    return {}

}

proc graphy::drawCircle {ctx data} {
    # Draw a circle
    set path [pix::path::new]
    pix::path::circle $path [dict get $data coordinates] [dict get $data radius]
    pix::ctx::fillPath  $ctx $path [dict get $data fill_color]
    pix::ctx::strokePath $ctx $path [dict get $data stroke_color] [list \
        strokeWidth [dict get $data stroke_width] \
    ]

    return [list [list path $path data null]]
}

proc graphy::drawBubble {ctx data} {
    # Draw a bubble
    lassign [dict get $data coordinates] x y
    set r   [dict get $data radius]

    set first [graphy::getPiePoint $x $y $r -140.0]
    set last  [graphy::getPiePoint $x $y $r 140.0]

    lassign $first fx fy
    lassign $last  lx ly

    set strPath [list \
        [format "M %s,%s" $fx $fy] \
        [format "A $r,$r 0,0,1 %s,$y" [expr {$x - $r}]] \
        [format "A $r,$r 0,0,1 %s,$y" [expr {$x + $r}]] \
        [format "A $r,$r 0,0,1 %s,%s" $lx $ly] \
        [format "L $x, %s Z" [expr {$y + $r  * 1.5}]] \
    ]

    set path [pix::svgStyleToPathObj [join $strPath " "]]
    
    pix::ctx::fillPath $ctx $path [dict get $data fill_color]

    return [list [list bubble [list path $path data null]]]
}

proc graphy::drawFillLine {ctx data} {
    # Draw a line
    set index 0
    set svgpath {}
    set circlepath {}

    foreach pt [dict get $data points] {
        set action "L"
        if {$index == 0} {set action "M"}
    
        append svgpath [format "%s %s %s " $action {*}$pt]

        incr index
    }

    if {[dict get $data is_close]} {
        append svgpath "Z"
    }

    set path [pix::svgStyleToPathObj $svgpath]

    pix::ctx::fillPath $ctx $path [dict get $data fill_color]

    return [list [list path $path data null]]

}

proc graphy::drawStrokeLine {ctx data chart} {
    # Draw a line
    set index 0
    set svgpath {}
    set circlepath {}
    set points [dict get $data points]
    set bottom [dict get $data bottom]
    set fillsvgpath {}
    set fillpath "null"

    foreach pt $points {
        set action "L"
        if {$index == 0} {set action "M"}
    
        append svgpath [format "%s %s %s " $action {*}$pt]

        incr index
        
        if {[dict get $data symbol]} {
            set cpath [pix::path::new]
            lappend circlepath $cpath $pt
        }
    }

    if {[dict get $data is_close]} {
        append svgpath "Z"
    }

    if {[dict get $data fill_color] ne ""} {
        set last   [lindex $points end]
        set first  [lindex $points 0]
        set fillsvgpath $svgpath

        append fillsvgpath [format "L %s %s " [lindex $last 0]  $bottom]
        append fillsvgpath [format "L %s %s " [lindex $first 0] $bottom]
        append fillsvgpath [format "L %s %s" {*}$first]

        set fillpath [pix::svgStyleToPathObj $fillsvgpath]
        set fcolor [dict get $data fill_color]

        if {[graphy::isePaintClass $fcolor]} {
            set bounds [$chart get boundsAera]
            set xb [dict get $bounds x]
            set yb [dict get $bounds y]
            set wb [dict get $bounds width]
            set hb [dict get $bounds height]

            set p [$fcolor get]

            set fcolor [pix::paint::new [graphy::dictGet $p -type]]
            pix::paint::configure $fcolor [list \
                gradientHandlePositions [list [list $xb [expr {$yb + $hb}]] [list $xb $yb]] \
                gradientStops           [graphy::dictGet $p -gradientStops] \
            ]
        }
        pix::ctx::fillPath $ctx $fillpath $fcolor

    }

    set path [pix::svgStyleToPathObj $svgpath]

    # If the data has a blur attribute and it is set to true, create a shadow
    # effect for the line. Otherwise, just draw the line normally.
    if {[dict get $data sblur]} {
        graphy::drawBlurImage $ctx $data $chart $path
    } else {
        pix::ctx::strokePath $ctx $path [dict get $data stroke_color] [list \
            strokeWidth [dict get $data stroke_width] \
            dashes [dict get $data dashes] \
        ]
    }

    set pc {}
    if {[dict get $data symbol]} {
        set r [expr {[dict get $data stroke_width] * 1.1}]
        set i 0
        set chartsvalue [dict get $data charts_value]
        foreach {cpath points} $circlepath {
            lappend pc [list circle [list path $cpath data [lindex $chartsvalue $i] \
                coordinates $points \
                radius $r \
                stroke_color [dict get $data stroke_color] \
                stroke_width [dict get $data stroke_width] \
                series [dict get $data series] \
            ]]
            pix::path::circle $cpath $points $r
            pix::ctx::fillPath $ctx $cpath "white"
            pix::ctx::strokePath $ctx $cpath [dict get $data stroke_color] [list strokeWidth [dict get $data stroke_width]]
            incr i
        }
    }
        
    return [list \
        [list strokeLine [list path $path data null]] \
        {*}$pc \
        [list straightlinefill [list path $fillpath data null]] \
    ]
}

proc graphy::drawText {ctx data} {
    # Draw text
    pix::ctx::save $ctx

    if {[dict get $data transform] ne ""} {
        lassign [dict get $data transform] dx dy angle
        pix::ctx::transform $ctx [list 1 0 0 0 1 0 $dx $dy 1]
        pix::ctx::rotate $ctx $angle
    }

    pix::ctx::font $ctx      [dict get $data font_family]
    pix::ctx::fontSize $ctx  [dict get $data font_size]
    pix::ctx::textAlign $ctx [dict get $data text_anchor]
    pix::ctx::fillStyle $ctx [dict get $data font_color]
    # pix::ctx::textBaseline $ctx [my get alignment_baseline]
    pix::ctx::fillText $ctx  [dict get $data text] [list [dict get $data x] [dict get $data y]]
    pix::ctx::restore $ctx

    return [list [list path null data null]]
}

proc graphy::drawLine {ctx data} {
    # Draw a line
    lassign [dict get $data coordinates] x0 y0 x1 y1

    set path [pix::path::new]
    pix::path::moveTo $path [list $x0 $y0]
    pix::path::lineTo $path [list $x1 $y1]
    pix::ctx::strokePath $ctx $path [dict get $data stroke_color] [list \
        strokeWidth [dict get $data stroke_width] \
        dashes [dict get $data dashes] \
    ]

    return [list [list path $path data null]]
}

proc graphy::drawRoundedRect {ctx data chart} {
    # Draw a rounded rectangle
    set path [pix::path::new]
    pix::path::roundedRect $path {*}[dict get $data rect] [dict get $data radius]
    
    # If the data has a blur attribute and it is set to true, create a shadow
    # effect for the line. Otherwise, just draw the line normally.
    if {[dict get $data sblur]} {
        graphy::drawBlurImage $ctx $data $chart $path
    } else {
        pix::ctx::strokePath $ctx $path [dict get $data stroke_color] [list \
            strokeWidth [dict get $data stroke_width] \
        ]
    }
    
    pix::ctx::fillPath $ctx $path [dict get $data fill_color]

    return [list [list path $path data null]]
}

proc graphy::drawSmoothCurve {ctx data chart} {
    # Draw a smooth curve
    set svgpath [dict get $data path]
    set bottom  [dict get $data bottom]
    set points  [dict get $data points]
    set fillsvgpath {}
    set fillpath "null"

    if {[dict get $data fill_color] ne ""} {
        set last   [lindex $points end]
        set first  [lindex $points 0]
        set fillsvgpath $svgpath

        append fillsvgpath [format "L %s %s " [lindex $last 0]  $bottom]
        append fillsvgpath [format "L %s %s " [lindex $first 0] $bottom]
        append fillsvgpath [format "L %s %s" {*}$first]

        set fillpath [pix::svgStyleToPathObj $fillsvgpath]
        pix::ctx::fillPath $ctx $fillpath [dict get $data fill_color]
    }

    set path [pix::svgStyleToPathObj $svgpath]
    
    # If the data has a blur attribute and it is set to true, create a shadow
    # effect for the line. Otherwise, just draw the line normally.
    if {[dict get $data sblur]} {
        graphy::drawBlurImage $ctx $data $chart $path
    } else {
        pix::ctx::strokePath $ctx $path [dict get $data stroke_color] [list \
            strokeWidth [dict get $data stroke_width] \
            dashes [dict get $data dashes] \
        ]
    }

    set pc {}

    if {[dict get $data symbol]} {
        set r [expr {[dict get $data stroke_width] * 1.1}]
        set i 0
        set chartsvalue [dict get $data charts_value]
        foreach points [dict get $data points] {
            set cpath [pix::path::new]
            lappend pc [list circle [list path $cpath data [lindex $chartsvalue $i] \
                coordinates $points \
                radius $r \
                stroke_color [dict get $data stroke_color] \
                stroke_width [dict get $data stroke_width] \
                series [dict get $data series] \
            ]]
            pix::path::circle $cpath $points $r
            pix::ctx::fillPath $ctx $cpath "white"
            pix::ctx::strokePath $ctx $cpath [dict get $data stroke_color] [list strokeWidth [dict get $data stroke_width]]
            incr i
        }
    }
        
    return [list \
        [list smoothCurve [list path $path data null]]\
        {*}$pc \
        [list smoothCurvefill [list path $fillpath data null]] \
    ]
}

proc graphy::drawToolTip {chart infoSeries} {

    set start 35

    foreach series $infoSeries {
        incr start 14
    }

    set tImg [pix::img::new [list 160 [expr {$start + 10}]]]
    
    set path [pix::path::new]
    pix::path::roundedRect $path {5 5} [list 150 $start] {5 5 5 5}
    pix::img::fillPath $tImg $path "white"

    set t [$chart get tooltip]
    set font_family [pix::font::readFont [$t get font_family]]
    set stroke_color [$t get stroke_color]
    set font_size [$t get font_size]

    pix::font::configure $font_family [list size $font_size paint $stroke_color]
    # pix::img::fillText $tImg $font_family [my formatDate $epoch [my getOptions dateRange]] {transform {1 0 0 0 1 0 8 8 1}}
    set start 35
    foreach series $infoSeries {
        set path3 [pix::path::new]
        pix::path::circle $path3 [list 15 $start] 6
        pix::img::fillPath $tImg $path3 [dict get $series stroke_color]
        pix::img::fillText $tImg $font_family [dict get $series data yValue] [list transform [list 1 0 0 0 1 0 25 $start 1] vAlign MiddleAlign]
        incr start 16
    }
    
    
    return $tImg

}

proc graphy::drawEntities {ctx entities chart dictimg} {
    # Draws the entities.
    #
    # ctx      - The pix::ctx object to draw.
    # entities - The list of entities to draw.
    # chart    - The chart object to draw.
    # dictimg  - The image dictionary.
    #
    # Returns the list of objects.

    upvar 1 $dictimg ctximg
    set ctxpath {}

    foreach {entity data} $entities {
        switch -exact $entity {
            lineSeries  {
                foreach {type element} $data {
                    switch -exact $type {
                        strokeLine       {lappend ctxpath {*}[graphy::drawStrokeLine $ctx $element $chart]}
                        smoothcurve      {lappend ctxpath {*}[graphy::drawSmoothCurve $ctx $element $chart]}
                        bubble           {lappend ctxpath {*}[graphy::drawBubble $ctx $element]}
                        text             {lappend ctxpath $type [graphy::drawText $ctx $element]}
                        default          {error "'$type' not supported yet."}
                    }
                }
            }
            labelSeries {
                foreach {type element} $data {
                    switch -exact $type {
                        text    {lappend ctxpath $type [graphy::drawText $ctx $element]}
                        default {error "'$type' not supported yet."}
                    }
                }
            }
            marklineSeries {
                foreach {type element} $data {
                    switch -exact $type {
                        text       {lappend ctxpath marktext   [graphy::drawText $ctx $element]}
                        circle     {lappend ctxpath markcircle [graphy::drawCircle $ctx $element]}
                        line       {lappend ctxpath markline   [graphy::drawLine $ctx $element]}
                        fillLine   -
                        straightlinefill {lappend ctxpath markline [graphy::drawFillLine $ctx $element]}
                        default  {error "'$type' not supported yet."}
                    }
                }
            }
            title - subtitle {
                foreach {type element} $data {
                    switch -exact $type {
                        text    {lappend ctxpath $type [graphy::drawText $ctx $element]}
                        default {error "'$type' not supported yet."}
                    }
                }
            }
            legend {
                foreach {type element} $data {
                    switch -exact $type {
                        text              {lappend ctxpath $type [graphy::drawText $ctx $element]}
                        line              {lappend ctxpath $type [graphy::drawLine $ctx $element]}
                        legendcircle      {lappend ctxpath $type [graphy::drawCircle $ctx $element]}
                        legendroundedrect {lappend ctxpath $type [graphy::drawRoundedRect $ctx $element $chart]}
                        default           {error "'$type' not supported yet."}
                    }
                }
            }
            grid {
                foreach el $data {
                    foreach {type element} $el {
                        switch -exact $type {
                            line    {lappend ctxpath $type [graphy::drawLine $ctx $element]}
                            default {error "'$type' not supported yet."}
                        }
                    }
                }
            }
            leftYAxis - rightYAxis {
                foreach el $data {
                    foreach {type element} $el {
                        switch -exact $type {
                            line    {lappend ctxpath $type [graphy::drawLine $ctx $element]}
                            text    {lappend ctxpath $type [graphy::drawText $ctx $element]}
                            default {error "'$type' not supported yet."}
                        }
                    }
                }
            }
            xAxis {
                foreach el $data {
                    foreach {type element} $el {
                        switch -exact $type {
                            line    {lappend ctxpath $type [graphy::drawLine $ctx $element]}
                            text    {lappend ctxpath $type [graphy::drawText $ctx $element]}
                            default {error "'$type' not supported yet."}
                        }
                    }
                }
            }
            barSeries - background {
                foreach {type element} $data {
                    switch -exact $type {
                        roundedrect {lappend ctxpath $type [graphy::drawRoundedRect $ctx $element $chart]}
                        default     {error "'$type' not supported yet."}
                    }
                }
            }
            default {error "'$entity' not supported yet."}
        }
    }

    return [join $ctxpath " "]

}