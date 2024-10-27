# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

namespace eval graphy {}

proc graphy::tBoxIcon {x y W chart canvas} {

    set ctx      [$chart get ctx]
    set bounds   [$chart get boundsArea]
    set ctxImg   [$chart get ctxImg]

    if {$y > [dict get $bounds y]} {
        $canvas clearCanvas $ctx
        pix::ctx::drawImage $ctx [dict get $ctxImg fullimage] {0 0}
        pix::drawSurface $ctx [$canvas surface]
        return
    }

    set ctxpath [$chart get ctxPath]

    foreach name {zoom undo restore save} {
        set type [lsearch -exact $ctxpath $name]

        if {$type == -1} {continue}

        set info [lindex $ctxpath $type+1]

        set path  [dict get $info path]
        set trans [dict get $info transform]
        set data  [dict get $info data]

        if {[pix::path::fillOverlaps $path [list $x $y] $trans]} {
            $W configure -cursor [graphy::cursor]
            $canvas clearCanvas $ctx
            pix::ctx::drawImage $ctx [dict get $ctxImg fullimage] {0 0}

            set toolbox   [dict get $data toolbox]
            set itemcolor [graphy::dictGet $toolbox itemStyle itemColor]

            pix::ctx::strokePath $ctx $path $itemcolor [list \
                strokeWidth 2.5 \
                transform $trans \
            ]

            if {[graphy::dictGet $toolbox showTitle]} {
                if {$name in {zoom undo restore}} {
                    set mykey "dataZoom"
                } else {
                    set mykey "saveAsImage"
                }

                set mytext [graphy::dictGet $toolbox $mykey text]

                set font_size   [graphy::dictGet $toolbox $mykey nameTextStyle fontSize]
                set font_color  [graphy::dictGet $toolbox $mykey nameTextStyle fontColor]
                set font_family [graphy::dictGet $toolbox $mykey nameTextStyle fontFamily]

                switch -exact $name {
                    zoom    {set text [lindex {*}$mytext 0]}
                    undo    {set text [lindex {*}$mytext 1]}
                    restore {set text [lindex {*}$mytext 2]}
                    save    {set text $mytext}
                }

                dict set ztext font_family $font_family
                dict set ztext font_size   $font_size
                dict set ztext text_anchor "CenterAlign"
                dict set ztext font_color  $font_color
                dict set ztext transform   {}
                dict set ztext text        $text
                dict set ztext x           [expr {[lindex $trans 6] + 12}]
                dict set ztext y           [expr {25 + $font_size}]

                graphy::drawText $ctx $ztext
            }

            pix::drawSurface $ctx [$canvas surface]

            break
        } else {
            $W configure -cursor arrow
            $canvas clearCanvas $ctx
            pix::ctx::drawImage $ctx [dict get $ctxImg fullimage] {0 0}
            pix::drawSurface $ctx [$canvas surface]
        }
    }
}

proc graphy::tBoxAction {x y W chart canvas} {

    set ctx    [$chart get ctx]
    set bounds [$chart get boundsArea]
    set ctxImg [$chart get ctxImg]

    if {$y > [dict get $bounds y]} {
        $canvas clearCanvas $ctx
        pix::ctx::drawImage $ctx [dict get $ctxImg fullimage] {0 0}
        pix::drawSurface $ctx [$canvas surface]
        return
    }

    set ctxpath [$chart get ctxPath]

    foreach name {zoom undo restore save} {
        set type [lsearch -exact $ctxpath $name]

        if {$type == -1} {continue}

        set info [lindex $ctxpath $type+1]

        set path  [dict get $info path]
        set trans [dict get $info transform]

        if {[pix::path::fillOverlaps $path [list $x $y] $trans]} {
            set zoomData [$chart get zoomData]
            switch -exact $name {
                zoom    {
                    if {![dict get $zoomData enable]} {
                        dict set zoomData enable 1
                        $chart set zoomData $zoomData

                        set toolbox   [dict get $info data toolbox]
                        set itemcolor [graphy::dictGet $toolbox itemStyle itemColor]

                        dict set dataz color $itemcolor
                        dict set dataz top  [dict get $info data top]
                        dict set dataz left [dict get $info data left]

                        $canvas clearCanvas $ctx
                        pix::ctx::drawImage $ctx [dict get $ctxImg fullimage] {0 0}
                        graphy::icon $ctx $dataz $chart "zoom"
                        pix::drawSurface $ctx [$canvas surface]

                        dict set ctxImg fullimage [pix::img::copy [dict get [pix::ctx::get $ctx] image addr]]
                        $chart set ctxImg $ctxImg

                    } else {
                        dict set zoomData enable 0
                        $chart set zoomData $zoomData


                        set toolbox   [dict get $info data toolbox]
                        set itemcolor [graphy::dictGet $toolbox color]

                        dict set dataz color $itemcolor
                        dict set dataz top  [dict get $info data top]
                        dict set dataz left [dict get $info data left]

                        $canvas clearCanvas $ctx
                        pix::ctx::drawImage $ctx [dict get $ctxImg fullimage] {0 0}
                        graphy::icon $ctx $dataz $chart "zoom"
                        pix::drawSurface $ctx [$canvas surface]

                        dict set ctxImg fullimage [pix::img::copy [dict get [pix::ctx::get $ctx] image addr]]
                        $chart set ctxImg $ctxImg

                    }
                }
                
                undo {
                    if {[dict get $zoomData enable] && [dict exists $zoomData undo]} {
                        set undod [dict get $zoomData undo]
                        set xdata [lindex $undod end]
                        set xaxis [$chart get xAxisConfigs]

                        $xaxis setKey -min [dict get $xdata xmin]
                        $xaxis setKey -max [dict get $xdata xmax]

                        if {[llength $undod] > 0} {
                            dict set zoomData undo [lreplace $undod end end]
                            if {![llength [dict get $zoomData undo]]} {
                                set zoomData [dict remove $zoomData undo]
                            }
                            $chart set zoomData $zoomData
                        } 

                        after 10 [list graphy::updateCharts $chart [$chart get width] [$chart get height]]
                    }
                }

                restore {
                    if {[dict get $zoomData enable] && [dict exists $zoomData undo]} {
                        set undod [dict get $zoomData undo]
                        set xdata [lindex $undod 0]
                        set xaxis [$chart get xAxisConfigs]

                        $xaxis setKey -min [dict get $xdata xmin]
                        $xaxis setKey -max [dict get $xdata xmax]

                        set zoomData [dict remove $zoomData undo]
                        $chart set zoomData $zoomData
                        
                        after 10 [list graphy::updateCharts $chart [$chart get width] [$chart get height]]
                    }
                }
                save {
                    set toolbox [dict get $info data toolbox]
                    set exclude_components [graphy::dictGet $toolbox saveAsImage excludeComponents]
                    set bg_saveAs [graphy::dictGet $toolbox saveAsImage backgroundColor]

                    set list_ec [list {*}$exclude_components "fullimage"]
                    set sctx    [pix::ctx::new [list [$canvas wCanvas] [$canvas hCanvas]]]

                    if {$bg_saveAs eq "auto"} {
                        set bg [graphy::dictGet [$chart get global] background]
                    } else {
                        set bg $bg_saveAs
                    }

                    set extension [graphy::dictGet $toolbox saveAsImage type]
                    set filePath  [tk_getSaveFile -parent $W -confirmoverwrite "true" -defaultextension $extension]

                    if {$filePath ne ""} {
                        $canvas clearCanvas $sctx $bg
                        foreach {key image} $ctxImg {
                            set ec "false"
                            foreach compo $list_ec {
                                if {[string match $compo* $key]} {set ec "true" ; break}
                            }
                            if {$ec} {continue}
                            pix::ctx::drawImage $sctx $image {0 0}
                        }
                        set image [pix::img::copy [dict get [pix::ctx::get $sctx] image addr]]
                        pix::img::writeFile $image $filePath
                        pix::img::destroy $image
                        pix::ctx::destroy $sctx
                    }

                }
            }

            break
        }
    }
}

proc graphy::zoomDragStart {x y W chart canvas} {

    set ctx      [$chart get ctx]
    set bounds   [$chart get boundsArea]
    set zoomData [$chart get zoomData]

    if {
        ($y < [dict get $bounds y]) ||
        ($y >= [dict get $bounds y] + [dict get $bounds height] + 1)
    } {
        return
    }
    
    if {[dict exists $zoomData enable] && [dict get $zoomData enable]} {
        dict set zoomData click  true
        dict set zoomData xstart $x
        dict set zoomData ystart [dict get $bounds y]

        $chart set zoomData $zoomData
    }
}

proc graphy::zoomDragMove {x y W chart canvas} {

    set ctx    [$chart get ctx]
    set bounds [$chart get boundsArea]
    set ctxImg [$chart get ctxImg]

    if {
        ($y < [dict get $bounds y]) ||
        ($y >= [dict get $bounds y] + [dict get $bounds height] + 1)
    } {
        return
    }

    set zoomData [$chart get zoomData]

    if {[dict exists $zoomData click] && [dict get $zoomData click]} {
        $canvas clearCanvas $ctx
        pix::ctx::drawImage $ctx [dict get $ctxImg fullimage] {0 0}

        set x0 [dict get $zoomData xstart]
        set y0 [dict get $zoomData ystart]
        set x1 $x
        set y1 $y

        set w [expr {$x1 - $x0}]
        set h [dict get $bounds height]

        set rectPath [pix::path::new]
        pix::path::rect $rectPath [list $x0 $y0] [list $w $h]

        pix::ctx::strokePath $ctx $rectPath "gray" {
            strokeWidth 0.1 dashes {15 3 3 3}
        }
        pix::ctx::fillPath $ctx $rectPath "rgba(211,211,211,0.3)"

        pix::drawSurface $ctx [$canvas surface]
    }
}

proc graphy::zoomDragEnd {x y W chart canvas} {

    set ctx    [$chart get ctx]
    set bounds [$chart get boundsArea]

    if {
        ($y < [dict get $bounds y]) ||
        ($y >= [dict get $bounds y] + [dict get $bounds height] + 1)
    } {
        return
    }

    set zoomData [$chart get zoomData]

    if {[dict exists $zoomData click] && [dict get $zoomData click]} {

        set x0        [dict get $zoomData xstart]
        set xaxis     [$chart get xAxisConfigs]
        lappend items [graphy::coordToPixX $x0 $chart]
        lappend items [graphy::coordToPixX $x $chart]

        set max_ms1 [$xaxis getKey -max]
        set min_ms1 [$xaxis getKey -min]
        
        set min [tcl::mathfunc::min {*}$items]
        set max [tcl::mathfunc::max {*}$items]

        if {($max - $min) < 0.001} {return}

        dict set zoomData click false
        dict lappend zoomData undo [list xmin $min_ms1 xmax $max_ms1]
        
        $chart set zoomData $zoomData

        $xaxis setKey -min [list $min num]
        $xaxis setKey -max [list $max num]

        after 10 [list graphy::updateCharts $chart [$chart get width] [$chart get height]]

    }
}

proc graphy::axisPointer {x y W chart canvas} {

    set ctx    [$chart get ctx]
    set bounds [$chart get boundsArea]
    set ctxImg [$chart get ctxImg]

    if {
        ($x < [dict get $bounds x] - 1) ||
        ($x >= [dict get $bounds x] + [dict get $bounds width] + 1) ||
        ($y < [dict get $bounds y]) ||
        ($y >= [dict get $bounds y] + [dict get $bounds height] + 1)
    } {
        $canvas clearCanvas $ctx
        pix::ctx::drawImage $ctx [dict get $ctxImg fullimage] {0 0}
        pix::drawSurface $ctx [$canvas surface]
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

    $canvas clearCanvas $ctx
    pix::ctx::drawImage $ctx [dict get $ctxImg fullimage] {0 0}
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
    pix::drawSurface $ctx [$canvas surface]
}