# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

oo::class create graphy::Charts {

    variable _options {}

    constructor {} {

        dict set _options seriesList    {}
        dict set _options xAxisConfigs  {}
        dict set _options yAxisConfigs  {}
        dict set _options width         {}
        dict set _options height        {}
        dict set _options ctx           {}
        dict set _options listpath      {}
        dict set _options ctxImg        {}
        dict set _options ctxPath       {}
        dict set _options entities      {}
        dict set _options boundsAera    {}
        dict set _options global        {}
        dict set _options surface       {}
        dict set _options parent        {}
        dict set _options widget        {}
        dict set _options canvas        {}
        
    }

    method get {key} {
        # Returns the value associated with the given key
        # in the chart options.
        #
        # key - The key to look up in the options dictionary.
        #
        return [dict get $_options {*}$key]
    }

    method options {} {
        return $_options
    }

    method set {key args} {
        if {![dict exists $_options $key]} {
            error "property '$key' doesn't exists for\
                  [info object class [self]] class."
        }
    
        dict set _options $key {*}$args

        return {}
    }

    method lappend {key value} {
        if {![dict exists $_options $key]} {
            error "property '$key' doesn't exists for\
                  [info object class [self]] class."
        }

        if {[dict get $_options $key] eq ""} {
            dict set _options $key $value
        } else {
            dict lappend _options $key {*}$value
        }
        
        return {}
    }
    
    method globalOptions {{key ""} {value ""}} {

        if {($key ne "") && ($value ne "")} {
            my set global $key $value
            return {}
        }

        return [dict get $_options global]
    }

    method SetOptions {args} {

        if {[llength $args] % 2} graphy::errorEvenArgs
        
        set gopts {}

        foreach {key value} $args {
            switch -exact $key {
                -tooltip        {my globalOptions tooltip [graphy::tooltip $value]}
                -title          {my globalOptions title   [graphy::title $value]}
                -legend         {my globalOptions legend  [graphy::legend $value]}
                -grid           {my globalOptions grid    [graphy::grid $value]}
                -background     {lappend gopts $key $value}
                -areaBackground {lappend gopts $key $value}
                -margin         {lappend gopts $key $value}
                -color          {lappend gopts $key $value}
                default         {error "'$key' not supported for '[self method]' method."}
            }
        }
        
        if {$gopts ne ""} {
            set opts [graphy::globalOptions $gopts]
            foreach k [dict keys $gopts] {
                my globalOptions [string map {- ""} $k] [dict get $opts $k]
            } 
        }

        return {}
    }

    method Add {type args} {
        # Adds a new series to the chart.
        #
        # type - The type of series to add.
        # args - Additional arguments to pass to the series constructor.
        #
        # Returns nothing.
        switch -exact $type {
            "lineSeries" {
                set series [graphy::series::Line new {*}$args]
            }
            "barSeries" {
                set series [graphy::series::Bar new {*}$args]
            }
            "horizontalBarSeries" {
                set series [graphy::series::HorizontalBar new {*}$args]
            }
            default {
                error "unknown series type: '$type'"
            }
        }

        # Add the series to the list of series.
        my lappend seriesList $series

        return {}
    }

    method XAxis {args} {
        # Create a XAxis object and store it in the xAxisConfigs variable.
        #
        # args - Arguments for the XAxis object.
        #
        # Returns nothing.
        if {[llength $args] % 2} graphy::errorEvenArgs

        my set xAxisConfigs [graphy::XAxis new {*}$args]

        return {}
    }

    method YAxis {args} {
        # Create a new YAxis configuration object with the specified arguments
        # and append it to the yAxisConfigs list.
        #
        # args - Arguments for the XAxis object.
        #
        # Returns nothing.
        if {[llength $args] % 2} graphy::errorEvenArgs

        my lappend yAxisConfigs [graphy::YAxis new {*}$args]
    }

    method RenderLegend {c title_height} {

        set opts [my get global]

        if {
            ![dict exists $opts legend] || 
            ![graphy::dictGet $opts legend show] || 
            [my get seriesList] eq ""
        } {
            return 0.0
        }

        set legend_left 0.0
        set legends {}
        foreach series [my get seriesList] {
            lappend legends [graphy::dictGet [$series get] -name]
        }

        set legend_margin [graphy::dictGet $opts legend margin]

        set legend_margin_value [expr {[graphy::topBox $legend_margin] + [graphy::bottomBox $legend_margin]}]
        set legend_canvas [$c child $legend_margin]

        set font_family        [graphy::dictGet $opts legend fontFamily]
        set legend_font_size   [graphy::dictGet $opts legend fontSize]
        set legend_font_color  [graphy::dictGet $opts legend fontColor]
        set legend_font_weight [graphy::dictGet $opts legend fontWeight]
        set legend_category    [graphy::dictGet $opts legend category]

        lassign [graphy::measurelegends $font_family $legend_font_size $legends] legend_width legend_width_list

        set legend_canvas_width [$legend_canvas width]

        if {$legend_width < $legend_canvas_width} {
            switch -exact [graphy::dictGet $opts legend align] {
                center   {set legend_left [expr {($legend_canvas_width - $legend_width) / 2.0}]}
                right    {set legend_left [expr {$legend_canvas_width - $legend_width}]}
                left     -
                default  {set legend_left 0.0}
            }

            if {$legend_left < 0.0} {set legend_left 0.0}
        }

        set legend_unit_height [expr {$legend_font_size + $::graphy::LEGEND_MARGIN}]
        set legend_top $title_height
        set index 0
        
        set copts         [graphy::getDictValueOrDefault [self] "color"]
        set bopts         [graphy::getDictValueOrDefault [self] "background"]
        set series_colors [graphy::dictGet $copts color]

        foreach series [my get seriesList] {
            set optsSeries [$series get]

            if {
                [graphy::dictTypeOf $optsSeries -name] eq "null" ||
                ![graphy::dictGet $optsSeries -show]
            } {continue}

            set color [lindex $series_colors [expr {$index % [llength $series_colors]}]]

            # Get the line style from the series options
            if {[graphy::dictTypeOf $optsSeries -lineStyle] ne "null"} {
                # Get the color from the line style
                if {[graphy::dictTypeOf $optsSeries -lineStyle color] ne "null"} {
                    set color [graphy::dictGet $optsSeries -lineStyle color]
                }
            }

            if {($legend_left + [lindex $legend_width_list $index]) > $legend_canvas_width} {
                set legend_left 0.0
                set legend_top [expr {$legend_top + $legend_unit_height}]
            }

            if {[$series type] eq "bar"} {
                set legend_category rect
                set fillcolor $color
            } else {
                set legend_category normal
                set fillcolor [graphy::dictGet $bopts background]
            }

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

            set lc [graphy::Component::Legend new  \
                text         [graphy::dictGet $optsSeries -name] \
                font_family  $font_family \
                font_size    $legend_font_size \
                font_color   $legend_font_color \
                font_weight  $legend_font_weight \
                stroke_width 2 \
                stroke_color $color \
                fill         $fillcolor \
                left         $legend_left \
                top          $legend_top \
                category     $legend_category \
                series       $series \
            ]

            set b [$legend_canvas legend $lc]
            set legend_left [expr {$legend_left + [graphy::widthBox $b] + $::graphy::LEGEND_MARGIN}]
            incr index
        }

        $c lappend legend [$legend_canvas components]
        $legend_canvas destroy

        return [expr {$legend_unit_height + $legend_top + $legend_margin_value}]
    }


    method GetYAxisConfig {index} {
        # Returns the Y axis configuration object at the given index.
        #
        # index - The index of the Y axis configuration object to return.
        #
        set size [llength [my get yAxisConfigs]]

        # If there are no Y axis configuration objects, create one
        if {!$size} {
            set yconfig [graphy::YAxis new]
            my set yAxisConfigs $yconfig
        } elseif {$index < $size} {
            set yconfig [lindex [my get yAxisConfigs] $index]
        } else {
            set yconfig [lindex [my get yAxisConfigs] 0]
        }

        return $yconfig
    }

    method GetYAxisValues {index} {
        
        set y_axis_config [[my GetYAxisConfig $index] get]

        if {[graphy::dictGet $y_axis_config -type] eq "value"} {
            set lseries {}
            set series_Barlist {}
            set d [dict create]
            set series_list [my get seriesList]

            foreach series $series_list {
                dict set d $series [graphy::dictGet [$series get] -data]
                if {[$series type] eq "bar"} {
                    lappend series_Barlist $series
                }
            }

            foreach series $series_list {
                set optsSeries [$series get]
                if {[graphy::dictGet $optsSeries -yAxisIndex] == $index} {

                    # Stacked vertical bars.
                    if {[$series type] eq "bar"} {
                        if {[graphy::dictGet $optsSeries -stacked] && [llength $lseries]} {
                            set index_series [lsearch -exact $series_Barlist $series]
                            set series_Bms1  [lindex $series_Barlist $index_series-1]
                            if {
                                ($series_Bms1 ne "") && 
                                ([graphy::dictGet [$series_Bms1 get] -yAxisIndex] == $index)
                            } {
                                set newlist {}
                                set dsms    [dict get $d $series_Bms1]
                                set dseries [dict get $d $series]
                                foreach vs $dseries vsm1 $dsms {
                                    if {$vsm1 in {null _}} {set vsm1 0}
                                    if {$vs in {null _}} {set vs 0}
                                    lappend newlist [expr {$vs + $vsm1}]
                                }
                                if {[llength $newlist]} {
                                    dict set d $series $newlist
                                }
                            }
                        }
                    }
                    lappend lseries $series
                }
            }

            if {$lseries eq ""} {
                return [list {data {} min 0.0 max 0.0} 0.0]
            } else {
                set data_list {}
                foreach {k value} $d {
                    if {$k in $lseries} {lappend data_list $value}
                }
            }

            dict set params data_list        [join $data_list " "]
            dict set params split_number     [graphy::dictGet $y_axis_config -splitNumber]
            dict set params min              [graphy::dictGet $y_axis_config -min]
            dict set params max              [graphy::dictGet $y_axis_config -max]
            dict set params thousands_format [graphy::isThousandFormat [my GetYAxisConfig $index]]
            dict set params reverse          [graphy::dictGet $y_axis_config -reverse]
            
            set y_axis_values    [graphy::axisValues $params]
        } else {
            if {[graphy::dictTypeOf $y_axis_config -data] eq "null"} {
                error "no data for Y axis when type is set to 'category'"
            }
            dict set y_axis_values data [graphy::dictGet $y_axis_config -data]
        }

        set y_axis_formatter [graphy::dictGet $y_axis_config -axisLabel formatter]
        set font_family      [graphy::dictGet $y_axis_config -axisLabel fontFamily]
        set axis_font_size   [graphy::dictGet $y_axis_config -axisLabel fontSize]

        set maxBox 0
        foreach val [dict get $y_axis_values data] {
             set value [graphy::formatString $val $y_axis_formatter]
             set b     [graphy::measuretextwidth $font_family $axis_font_size $value]
             if {[graphy::widthBox $b] > $maxBox} {
                 set maxBox [graphy::widthBox $b]
             }
        }

        if {$maxBox} {
            set dec 0.0
            # Check if the y-axis has a name
            if {[graphy::dictTypeOf $y_axis_config -name] ne "null"} {
                # Get the name of the y-axis
                set text [graphy::dictGet $y_axis_config -name]

                # Check the location of the y-axis name
                if {[graphy::dictGet $y_axis_config -nameLocation] eq "middle"} {
                    # Get the font family, size, and other text style options
                    set font_family  [graphy::dictGet $y_axis_config -nameTextStyle fontFamily]
                    set font_size    [graphy::dictGet $y_axis_config -nameTextStyle fontSize]

                    # Measure the width of the y-axis name
                    set bname [graphy::measuretextwidth $font_family $font_size $text]
                    # Calculate the offset of the y-axis name
                    if {$index > 0} {
                        set mopts   [graphy::getDictValueOrDefault [self] "margin"]
                        set rmargin [graphy::dictGet $mopts margin]
                        set dec     [expr {[graphy::heightBox $bname] + ([dict get $rmargin right] / 2.0)}]
                    } else {
                        set dec [graphy::heightBox $bname]
                    }
                    
                }
            }

            set y_axis_width [expr {$maxBox + $dec}]
        } else {
            set y_axis_width $::graphy::DEFAULT_Y_AXIS_WIDTH
        }

        return [list $y_axis_values $y_axis_width]

    }

    method GetXAxisValues {} {
        
        set x_axis_config [[my get xAxisConfigs] get]
        set data [graphy::dictGet $x_axis_config -data] 

        if {[graphy::dictGet $x_axis_config -type] eq "category"} {
            if {[graphy::dictTypeOf $x_axis_config -data] eq "null"} {
                error "no data for X axis when type is set to 'category'"
            }
            return [list data $data]
        } else {
            if {[graphy::dictTypeOf $x_axis_config -data] eq "null"} {
                set lseries {}
                set series_Barlist {}
                set d [dict create]
                set series_list [my get seriesList]

                foreach series $series_list {
                    dict set d $series [graphy::dictGet [$series get] -data]
                    if {[$series type] eq "horizontalbar"} {
                        lappend series_Barlist $series
                    }
                }

                set data_list {}
                foreach series $series_list {
                    set optsSeries [$series get]

                    # Stacked horizontal bars.
                    if {[$series type] eq "horizontalbar"} {
                        if {[graphy::dictGet $optsSeries -stacked] && [llength $lseries]} {
                            set index_series [lsearch -exact $series_Barlist $series]
                            set series_Bms1  [lindex $series_Barlist $index_series-1]
                            if {$series_Bms1 ne ""} {
                                set newlist {}
                                set dsms    [dict get $d $series_Bms1]
                                set dseries [dict get $d $series]
                                foreach vs $dseries vsm1 $dsms {
                                    if {$vsm1 in {null _}} {set vsm1 0}
                                    if {$vs in {null _}} {set vs 0}
                                    lappend newlist [expr {$vs + $vsm1}]
                                }
                                if {[llength $newlist]} {
                                    dict set d $series $newlist
                                }
                            }
                        }
                    }
                    lappend lseries $series
                }

                if {$lseries eq ""} {
                    error "no data series for X axis when type is set to 'value'"
                } else {
                    set data_list {}
                    foreach {k value} $d {
                        if {$k in $lseries} {lappend data_list $value}
                    }
                }
                set data [join $data_list " "]
            } else {
                set data $data
            }
        }

        dict set params data_list        $data
        dict set params split_number     [graphy::dictGet $x_axis_config -splitNumber]
        dict set params min              [graphy::dictGet $x_axis_config -min]
        dict set params max              [graphy::dictGet $x_axis_config -max]
        dict set params reverse          "False"
        dict set params thousands_format [graphy::isThousandFormat $x_axis_config]

        return [graphy::axisValues $params]

    }

    method RenderTitle {c} {
        
        set opts [graphy::getDictValueOrDefault [self] "title"]
        set titleheight 0.0
        set title_box 0.0

        if {[graphy::dictGet $opts title show] && [graphy::dictTypeOf $opts title text] ne "null"} {

            set title_margin      [graphy::dictGet $opts title textPadding]
            set font_family       [graphy::dictGet $opts title textStyle fontFamily]
            set title_font_size   [graphy::dictGet $opts title textStyle fontSize]
            set title_text        [graphy::dictGet $opts title text]
            set title_font_weight [graphy::dictGet $opts title textStyle fontWeight]
            set title_font_color  [graphy::dictGet $opts title textStyle fontColor]
            set title_height      [graphy::dictGet $opts title itemGap]
            set title_box         [graphy::measuretextwidth $font_family $title_font_size $title_text]

            switch -exact [graphy::dictGet $opts title textStyle align] {
                center   {set x [expr {([$c width] - [graphy::widthBox $title_box]) / 2.0}]}
                right    {set x [expr {[$c width]  - [graphy::widthBox $title_box]}]}
                left     {set x 0.0}
                default  {error "invalid title align: [graphy::dictGet $opts title align]"}
            }
            
            set mopts   [graphy::getDictValueOrDefault [self] "margin"]
            set gmargin [graphy::dictGet $mopts margin]

            set ytitle [expr {
                (([graphy::heightBox $title_box] / 2.0) - [dict get $gmargin top]) + [graphy::topBox $title_margin]
            }]

            set c_child [$c child $title_margin]
            set tc [graphy::Component::Text new  \
                text        $title_text \
                font_family $font_family \
                font_size   $title_font_size \
                font_weight $title_font_weight \
                font_color  $title_font_color \
                line_height $title_height \
                x           $x \
                y           $ytitle \
            ]

            set b [$c_child text $tc]
            $c lappend title [$c_child components]
            set titleheight [expr {
                ([graphy::outerHeightBox $b] / 2.0) + [graphy::topBox $title_margin] + [graphy::bottomBox $title_margin]
            }]

            $c_child destroy

            if {[graphy::dictTypeOf $opts title subtext] ne "null"} {
                
                set x 0.0
                set sub_title_margin      [graphy::dictGet $opts title subTextPadding]
                set font_family           [graphy::dictGet $opts title subtextStyle fontFamily]
                set sub_title_font_size   [graphy::dictGet $opts title subtextStyle fontSize]
                set sub_title_text        [graphy::dictGet $opts title subtext]
                set sub_title_font_color  [graphy::dictGet $opts title subtextStyle fontColor]
                set sub_title_font_weight [graphy::dictGet $opts title subtextStyle fontWeight]
                set sub_title_height      [graphy::dictGet $opts title itemGap]

                set sub_title_box [graphy::measuretextwidth $font_family $sub_title_font_size $sub_title_text]

                switch -exact [graphy::dictGet $opts title subtextStyle align] {
                    center   {set x [expr {([$c width] - [graphy::widthBox $sub_title_box]) / 2.0}]}
                    right    {set x [expr {[$c width]  - [graphy::widthBox $sub_title_box]}]}
                    left     {set x 0.0}
                    default  {error "invalid subtitle align: [graphy::dictGet $opts title subtextStyle align]"}
                }

                set ysubtitle [expr {(([graphy::heightBox $sub_title_box] / 2.0) - [dict get $gmargin top]) + [graphy::topBox $sub_title_margin]}]

                graphy::setBox sub_title_margin top [expr {[graphy::topBox $sub_title_margin] + $titleheight}]
                set c_child [$c child $sub_title_margin]
                set tc [graphy::Component::Text new  \
                    text        $sub_title_text \
                    font_family $font_family \
                    font_size   $sub_title_font_size \
                    font_weight $sub_title_font_weight \
                    font_color  $sub_title_font_color \
                    line_height $sub_title_height \
                    x           $x \
                    y           $ysubtitle \
                ]
                set b [$c_child text $tc]
                $c lappend subtitle [$c_child components]
                set titleheight [expr {([graphy::outerHeightBox $b] / 2.0) + [graphy::topBox $sub_title_margin] + [graphy::bottomBox $sub_title_margin]}]

                $c_child destroy

            }

        }

        return $titleheight
    }

    method RenderGrid {c axis_width axis_height xAxisComponents} {

        set opts [graphy::getDictValueOrDefault [self] "grid"]

        if {![graphy::dictGet $opts grid showX] && ![graphy::dictGet $opts grid showY]} {
            return {}
        }

        set horizontals 0
        set verticals 0
        set hidden_horizontals null
        set hidden_verticals null

        # Show Y grid
        if {[graphy::dictGet $opts grid showY]} {
            set y_axis_config [[my GetYAxisConfig 0] get]

            if {[graphy::dictGet $y_axis_config -type] eq "category"} {
                set data_categories [graphy::dictGet $y_axis_config -data]
                set horizontals     [llength $data_categories]
            } else {
                set horizontals [graphy::dictGet $y_axis_config -splitNumber]
            }

            if {[graphy::dictTypeOf $opts grid hiddenY] eq "null"} {
                set hidden_horizontals $horizontals
            } else {
                set hidden_horizontals {*}[graphy::dictGet $opts grid hiddenY]
            }
        }
        # Show X grid
        if {[graphy::dictGet $opts grid showX]} {
            set verticals [dict get [$xAxisComponents options] split_number]
            if {[graphy::dictTypeOf $opts grid hiddenX] eq "null"} {
                set hidden_verticals $horizontals
            } else {
                set hidden_verticals {*}[graphy::dictGet $opts grid hiddenX]
            }
        }

        set dashes [expr {
            [graphy::dictTypeOf $opts grid lineStyle dashes] eq "null" 
            ? {} 
            : [graphy::dictGet $opts grid lineStyle dashes]
        }]

        set gr [graphy::Component::Grid new \
            right              $axis_width \
            bottom             $axis_height \
            color              [graphy::dictGet $opts grid lineStyle color] \
            stroke_width       [graphy::dictGet $opts grid lineStyle width] \
            horizontals        $horizontals \
            hidden_horizontals $hidden_horizontals \
            verticals          $verticals \
            hidden_verticals   $hidden_verticals \
            stroke_dash_array  $dashes \
        ]

        $c grid $gr

        return {}

    }

    method RenderYAxis {c data axis_height axis_width index} {

        set config        [my GetYAxisConfig $index]
        set y_axis_config [$config get]
        set c_child       [$c child [graphy::newBox 0]]

        if {[graphy::dictGet $y_axis_config -type] eq "category"} {
            set name_align   center
            set split_number [llength $data]
        } else {
            set name_align   [graphy::dictGet $y_axis_config -axisLabel align]
            set split_number [graphy::dictGet $y_axis_config -splitNumber]
        }

        set yaxis [graphy::Component::Axis new \
            position      [expr {$index > 0 ? "right" : "left"}] \
            type          [expr {$index > 0 ? "yright" : "yleft"}] \
            height        $axis_height \
            width         $axis_width \
            name_align    $name_align \
            data          $data \
            split_number  $split_number \
            font_family   [graphy::dictGet $y_axis_config -axisLabel fontFamily] \
            stroke_color  [graphy::dictGet $y_axis_config -axisLine  lineStyle color] \
            name_gap      [graphy::dictGet $y_axis_config -axisLabel nameGap] \
            font_color    [graphy::dictGet $y_axis_config -axisLabel fontColor] \
            font_size     [graphy::dictGet $y_axis_config -axisLabel fontSize] \
            font_weight   [graphy::dictGet $y_axis_config -axisLabel fontWeight] \
            formatter     [graphy::dictGet $y_axis_config -axisLabel formatter] \
            show_axis     [graphy::dictGet $y_axis_config -axisLine show] \
            tick_length   [graphy::dictGet $y_axis_config -axisTick length] \
            tick_start    [graphy::dictGet $y_axis_config -axisTick start] \
            tick_interval [graphy::dictGet $y_axis_config -axisTick interval] \
            tick_color    [graphy::dictGet $y_axis_config -axisTick lineStyle color] \
            minor_tick    [graphy::dictGet $y_axis_config -minorTick show] \
            name_axis     [graphy::dictGet $y_axis_config -name] \
            name_loc      [graphy::dictGet $y_axis_config -nameLocation] \
            name_style    [graphy::dictGet $y_axis_config -nameTextStyle] \
        ]

        $c_child axis $yaxis
        $c lappend [$c_child components]

        $c_child destroy

        return {}
    }

    method RenderXAxis {c xParamsData xOpts axis_width x_axis_height} {

        if {
            [graphy::dictGet $xOpts -boundaryGap] &&
            [graphy::dictGet $xOpts -type] eq "value"
        } {
            error "boundaryGap not implemented for type 'value'"
        }

        set xData [dict get $xParamsData data]
        set split_number [llength $xData]

        if {[graphy::dictGet $xOpts -boundaryGap]} {
            set name_align center
        } else {
            set split_number [expr {$split_number - 1}]
            set name_align left
        }

        set c_child [$c child [graphy::newBox 0]]

        set caxis [graphy::Component::Axis new \
            type          "x" \
            width         $axis_width \
            height        $x_axis_height \
            split_number  $split_number \
            font_family   [graphy::dictGet $xOpts -axisLabel fontFamily] \
            data          $xData \
            font_color    [graphy::dictGet $xOpts -axisLabel fontColor] \
            font_weight   [graphy::dictGet $xOpts -axisLabel fontWeight] \
            stroke_color  [graphy::dictGet $xOpts -axisLine  lineStyle color] \
            font_size     [graphy::dictGet $xOpts -axisLabel fontSize] \
            name_gap      [graphy::dictGet $xOpts -axisLabel nameGap] \
            name_rotate   [graphy::dictGet $xOpts -axisLabel nameRotate] \
            name_align    $name_align \
            tick_length   [graphy::dictGet $xOpts -axisTick length] \
            tick_start    [graphy::dictGet $xOpts -axisTick start] \
            tick_interval [graphy::dictGet $xOpts -axisTick interval] \
            tick_color    [graphy::dictGet $xOpts -axisTick lineStyle color] \
            minor_tick    [graphy::dictGet $xOpts -minorTick show] \
            name_axis     [graphy::dictGet $xOpts -name] \
            name_loc      [graphy::dictGet $xOpts -nameLocation] \
            name_style    [graphy::dictGet $xOpts -nameTextStyle] \
            show_axis     [graphy::dictGet $xOpts -axisLine show] \
            formatter     [graphy::dictGet $xOpts -axisLabel formatter] \
        ]

        $c_child axis $caxis
        $c lappend [$c_child components]

        $c_child destroy

        return {}

    }

    method RenderSeriesLabel {c series_labels_list} {

        if {$series_labels_list eq ""} {return {}}

        set ls {}
        foreach {series labelitems} $series_labels_list {

            set optsSeries [$series get]

            set formatter  [graphy::dictGet $optsSeries -label formatter]
            set fontSize   [graphy::dictGet $optsSeries -label fontSize]
            set fontFamily [graphy::dictGet $optsSeries -label fontFamily]
            set fontWeight [graphy::dictGet $optsSeries -label fontWeight]
            set fontColor  [graphy::dictGet $optsSeries -label fontColor]
            set offsetX    [graphy::dictGet $optsSeries -label offsetX]
            set offsetY    [graphy::dictGet $optsSeries -label offsetY]

            foreach label $labelitems {
                lassign [dict get $label point] x y
                set text [dict get $label text]

                $c text [graphy::Component::Text new  \
                    text        $text \
                    font_family $fontFamily \
                    font_size   $fontSize \
                    font_weight $fontWeight  \
                    font_color  $fontColor \
                    text_anchor "CenterAlign" \
                    x           [expr {$x + $offsetX}] \
                    y           [expr {$y + ($offsetY * -1)}] \
                    series      $series \
                ]
            }
            lappend ls labelSeries [list series $series components [$c components]]
            $c set _components {}
        }

        $c set _components $ls

        return {}
    }

    method RenderMarkLine {c seriesList y_axis_values_list max_height} {

        set index 0
        set mklines {}

        set gopts [my get global]
        set series_colors [graphy::dictGet $gopts color]

        foreach series $seriesList {
        
            set optsSeries [$series get]
            
            if {[graphy::dictTypeOf $optsSeries -markLine] eq "null"} {
                incr index ; continue
            }

            if {[graphy::dictGet $optsSeries -yAxisIndex] >= [llength $y_axis_values_list]} {
                set y_axis_values [lindex $y_axis_values_list 0]
            } else {
                set y_axis_values [lindex $y_axis_values_list [graphy::dictGet $optsSeries -yAxisIndex]]
            }

            set indexcolor [expr {
                [graphy::dictTypeOf $optsSeries -indexColor] eq "null" 
                ? $index 
                : [graphy::dictGet $optsSeries -indexColor]
            }]

            set color [graphy::getColor $series_colors $indexcolor]
            set infoS [$series getInfo]
            
            set sum [dict get $infoS sumValue]
            set max [dict get $infoS maxValue]
            set min [dict get $infoS minValue]

            foreach {k item} [graphy::dictGet $optsSeries -markLine] {
                switch -exact [graphy::dictGet $item category] {
                    average {set value [expr {$sum / double([llength [graphy::dictGet $optsSeries -data]])}]}
                    max     {set value $max}
                    min     {set value $min}
                    default {error "'[graphy::dictGet $item category]' not implanted"}
                }

                set y [graphy::getOffsetHeight $y_axis_values $value $max_height]
                set arrow_width 10.0

                $c circle [graphy::Component::Circle new \
                    stroke_width 1 \
                    stroke_color $color \
                    fill $color \
                    cx 0.0 \
                    cy $y \
                    r 3.5 \
                    series $series \
                ]

                $c line [graphy::Component::Line new \
                    stroke_width 1 \
                    color  $color \
                    left   0.0 \
                    top    [graphy::formatPixel $y 1] \
                    right  [expr {[$c width] - $arrow_width}] \
                    bottom [graphy::formatPixel $y 1] \
                    stroke_dash_array 4.2 \
                ]

                $c arrow [graphy::Component::Arrow new \
                    x [expr {[$c width] - $arrow_width}] \
                    y $y \
                    stroke_color $color \
                ]
                set line_height 20.0
                $c text [graphy::Component::Text new \
                    text        [graphy::format_float $value] \
                    font_family [graphy::dictGet $item label fontFamily] \
                    font_size   [graphy::dictGet $item label fontSize] \
                    font_color  [graphy::dictGet $item label fontColor] \
                    line_height $line_height \
                    x           [expr {[$c width] + 2.0}] \
                    y           $y \
                ]
            }

            lappend mklines marklineSeries [list series $series components [$c components]]
            $c set _components {}
            incr index
        }

        $c set _components $mklines

        return {}
    }

    method RenderBackground {c width height color} {
        
        $c rect [graphy::Component::Rect new \
            color $color \
            fill $color \
            left 0.0 \
            top 0.0 \
            width $width \
            height $height \
        ]
        
        return {}
    }

    method Render {args} {

        set width  $::graphy::WIDTH
        set height $::graphy::HEIGHT
        set parent [my get parent]

        if {[dict exists $args -width]}  {set width  [dict get $args -width]}
        if {[dict exists $args -height]} {set height [dict get $args -height]}
        if {[dict exists $args -parent]} {set parent [dict get $args -parent]}
        
        # Init global options
        set gopts  [graphy::getDictValueOrDefault [self] "margin"]
        set margin [graphy::dictGet $gopts margin]
        set c      [graphy::Canvas new $width $height $margin]

        my set width $width
        my set height $height
        my set parent $parent
        my set canvas $c

        set xAxisconfig [my get xAxisConfigs]
        if {$xAxisconfig eq ""} {error "Xaxis not set"}
        
        set xOpts [$xAxisconfig get]
        
        if {![graphy::dictGet $xOpts -show]} {
            set x_axis_height 0.0
        } else {
            set x_axis_height [graphy::dictGet $xOpts -height]
            
            if {[graphy::dictTypeOf $xOpts -name] ne "null"} {
                # Get the name of the X-axis
                set text [graphy::dictGet $xOpts -name]

                # Get the font family, size, and other text style options
                set font_family  [graphy::dictGet $xOpts -nameTextStyle fontFamily]
                set font_size    [graphy::dictGet $xOpts -nameTextStyle fontSize]

                # Measure the width of the X-axis name
                set bname [graphy::measuretextwidth $font_family $font_size $text]
                set x_axis_height [expr {$x_axis_height + [graphy::heightBox $bname]}]
            }          
        }

        set dBox [graphy::BoxDefault]

        # Render title
        set c_child [$c child $dBox]
        # my RenderTitle returns the height of the title
        set title_height [my RenderTitle $c_child]
        # Add the title components to the parent
        $c lappend {*}[$c_child components]
        # Destroy the child
        $c_child destroy

        # Render legend
        set c_child [$c child $dBox]
        # my RenderLegend returns the height of the legend
        set legend_height [my RenderLegend $c_child $title_height]
        # Add the legend components to the parent
        $c lappend {*}[$c_child components]
        # Destroy the child
        $c_child destroy


        set axis_top [expr {($legend_height > $title_height) ? $legend_height : $title_height}]

        lassign [my GetYAxisValues 0] left_y_axis_values left_y_axis_width
        set yconfig0 [[my GetYAxisConfig 0] get]

        if {![graphy::dictGet $yconfig0 -show]} {
            set left_y_axis_width 0.0
        }

        set exist_right_y_axis false

        foreach series [my get seriesList] {
            set optsSeries [$series get]
            if {[graphy::dictGet $optsSeries -yAxisIndex] != 0} {
                set exist_right_y_axis true
            }
        }

        set right_y_axis_width 0.0
        set right_y_axis_values {data {} max 0.0 min 0.0}

        if {$exist_right_y_axis} {
            lassign [my GetYAxisValues 1] right_y_axis_values right_y_axis_width
        }

        set axis_height [expr {[$c height] - $x_axis_height - $axis_top}]
        set axis_width  [expr {[$c width] - $left_y_axis_width - $right_y_axis_width}]

        if {$axis_top > 0.0} {
            set b [graphy::newBox left 0 top $axis_top right 0 bottom 0]
            set components [$c components]
            set c [$c child $b]
            $c set _components $components
        }
        
        set gopts [graphy::getDictValueOrDefault [self] "areaBackground"]
        
        if {[graphy::dictTypeOf $gopts areaBackground] ne "null"} {
            set b [graphy::newBox left $left_y_axis_width top 0 right $right_y_axis_width bottom 0]
            set c_child [$c child $b]
            set color [graphy::dictGet $gopts areaBackground]
            my RenderBackground $c_child $axis_width $axis_height $color
            $c lappend background [$c_child components]
            $c_child destroy
        }

        # Get bounds aera
        set b [graphy::newBox left $left_y_axis_width top 0 right $right_y_axis_width bottom 0]
        set c_child [$c child $b]
        $c_child rect [graphy::Component::Rect new \
            left 0.0 \
            top 0.0 \
            width $axis_width \
            height $axis_height \
        ]

        set boundsOpts [[$c_child components] options]
        my set boundsAera [dict create \
            x [dict get $boundsOpts left] \
            y [dict get $boundsOpts top] \
            width [dict get $boundsOpts width] \
            height [dict get $boundsOpts height] \
        ]

        # Render left y axis
        if {$left_y_axis_width > 0.0} {
            set c_child [$c child [graphy::newBox]]
            my RenderYAxis $c_child [dict get $left_y_axis_values data] $axis_height $left_y_axis_width 0
            $c lappend leftYAxis [$c_child components]
            $c_child destroy
        }

        # Render right y axis
        if {$right_y_axis_width > 0.0} {
            set c_child [$c child [graphy::newBox \
                left [expr {[$c width] - $right_y_axis_width}] \
                top 0 \
                right 0 \
                bottom 0 \
            ]]
            my RenderYAxis $c_child [dict get $right_y_axis_values data] $axis_height $right_y_axis_width 1
            $c lappend rightYAxis [$c_child components]
            $c_child destroy
        }

        set xParamsData [my GetXAxisValues]

        # Render x axis
        if {[graphy::dictGet $xOpts -show]} {
            set c_child [$c child [graphy::newBox \
                left $left_y_axis_width \
                top [expr {[$c height] - $x_axis_height}] \
                right $right_y_axis_width \
                bottom 0 \
            ]]
            my RenderXAxis $c_child $xParamsData $xOpts $axis_width $x_axis_height
            $c lappend xAxis [$c_child components]
            $c_child destroy
        }

        # Render grid
        set b [graphy::newBox left $left_y_axis_width top 0 right 0 bottom 0]

        set c_child [$c child $b]
        my RenderGrid $c_child $axis_width $axis_height [dict get [$c components] xAxis]
        $c lappend grid [$c_child components]
        $c_child destroy

        set series_labels_list {}
        set max_height [expr {[$c height] - $x_axis_height}]
        set y_axis_values_list [list $left_y_axis_values $right_y_axis_values]

        set indexLine   0
        set indexBar    0
        set indexHBar   0
        set indexSeries 0

        # Populate series.
        foreach series [my get seriesList] {
            set optsSeries [$series get]

            if {![graphy::dictGet $optsSeries -show]} {continue}

            switch -exact [$series type] {
                "line" {
                    # line point
                    set c_child [$c child [graphy::newBox \
                        left $left_y_axis_width \
                        right $right_y_axis_width \
                        bottom 0 \
                        top 0 \
                    ]]

                    lappend series_labels_list [graphy::lineSeries \
                        $c_child [self] $series $indexLine $indexSeries $y_axis_values_list \
                        $max_height \
                        $xOpts \
                        $xParamsData \
                        $axis_width \
                        $axis_height \
                    ]
                    $c lappend lineSeries [list series $series components [$c_child components]]

                    incr indexLine
                }
                "bar" {
                    # Bar
                    set c_child [$c child [graphy::newBox \
                        left $left_y_axis_width \
                        right $right_y_axis_width \
                        bottom 0 \
                        top 0 \
                    ]]

                    lappend series_labels_list [graphy::barSeries \
                        $c_child \
                        [self] \
                        $series \
                        $indexBar $indexSeries \
                        $y_axis_values_list \
                        $max_height \
                        $xOpts \
                    ]
                    $c lappend barSeries [list series $series components [$c_child components]]
                    incr indexBar
                }
                "horizontalbar" {
                    # Bar
                    set dec 0.0
                    set yconfig0 [[my GetYAxisConfig 0] get]

                    if {[graphy::dictGet $yconfig0 -axisLine show]} {    
                        set wl [graphy::dictGet $yconfig0 -axisLine lineStyle width]
                        set dec [expr {$wl + 1.0}]
                    }

                    set c_child [$c child [graphy::newBox \
                        left [expr {$left_y_axis_width + $dec}] \
                        right 0 \
                        bottom $x_axis_height \
                        top 0 \
                    ]]

                    set max_width  [$c_child width]

                    lappend series_labels_list [graphy::horizontalBarSeries \
                        $c_child \
                        [self] \
                        $series \
                        $indexHBar $indexSeries \
                        $y_axis_values_list \
                        $max_width \
                        $xParamsData \
                    ]
                    $c lappend horizontalbarSeries [list series $series components [$c_child components]]
                    incr indexHBar
                }
            }
            incr indexSeries
        }

        set c_child [$c child [graphy::newBox \
            left $left_y_axis_width \
            right $right_y_axis_width \
            bottom 0 \
            top 0 \
        ]]

        my RenderSeriesLabel $c_child [join $series_labels_list " "]
        $c lappend {*}[$c_child components]
        $c_child destroy

        set c_child [$c child [graphy::newBox \
            left $left_y_axis_width \
            right $right_y_axis_width \
            bottom 0 \
            top 0 \
        ]]

        my RenderMarkLine $c_child [my get seriesList] $y_axis_values_list $max_height
        $c lappend {*}[$c_child components]
        $c_child destroy

        $c draw [self]

    }

    export Add XAxis YAxis Render SetOptions GetYAxisConfig
}
