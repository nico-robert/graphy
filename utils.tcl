# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

namespace eval graphy {}

proc graphy::keyDictExists {basekey d key} {
    # Check if key exists in dict.
    #
    # d   - dict
    # key - upvar name
    #
    # Returns true if key name exists,
    # false otherwise.

    upvar 1 $key name

    foreach bkey [list $basekey [format {-%s} $basekey]] {
        if {[dict exists $d $bkey]} {
            set name $bkey
            return 1
        }
    }

    return 0
}

proc graphy::infoNameProc {levelP name} {
    # Gets name of proc follow level.
    #
    # levelP - properties
    # name   - Name to be found in properties
    #
    # Returns true if name match with current 
    # level properties, false otherwise.

    return [string match $name $levelP]
}

proc graphy::typeOfClass {obj} {
    # Name of class.
    #
    # obj  - Instance.
    #
    # Returns name of class or nothing.
    return [info object class $obj]
}

proc graphy::isAObject {obj} {
    # Check if variable 'obj' is an object.
    #
    # obj  - Instance.
    #
    # Returns true or false.
    return [info object isa object $obj]
}

proc graphy::setdef {d key args} {
    # Set dict definition with value type and default value.
    # An error exception is raised if args value is not found.
    # 
    # d    - dict
    # key  - dict key
    # args - type, default, validvalue.
    #
    # Returns dictionary

    upvar 1 $d _dict

    foreach {k value} $args {
        switch -exact -- $k {
            -validvalue   {set validvalue $value}
            -type         {set type       $value}
            -default      {set default    $value}
            default       {error "Unknown key '$k' specified"}
        }
    }

    dict set _dict $key [list $default $type $validvalue]
}

proc graphy::getDictValueOrDefault {self key} {
    # Set or get global options.
    #
    # self - object
    # key  - dict key
    #
    # Returns list with dict key and value.

    set opts [$self globalOptions]

    if {[dict exists $opts $key]} {
        return [list $key [dict get $opts $key]]
    }

    if {[info commands ::graphy::${key}] eq ""} {
        set info [graphy::globalOptions {}]
        foreach {k val} $info {
            set k [string map {- ""} $k]
            if {![dict exists $opts $k]} {
                $self globalOptions $k $val
            }
        }
    } else {
        $self globalOptions $key [graphy::${key} {}]
    }

    return [list $key [dict get [$self globalOptions] $key]] 

}

proc graphy::dictGet {d args} {
    # Get value from dict.
    # Raise an error if item value is not even.
    #
    # d    - dict
    # args - list of dict keys
    #
    # Returns value
    foreach key $args {
        set value {}
        if {[dict exists $d $key]} {
            set d [dict get $d $key]
            set type  [lindex $d 1]
            set value [lindex $d 0]
            if {$type in "dict"} {
                set d $value
            }
        }
    }

    if {$value eq ""} {
        error "not 'value' for keys '$args'"
    }

    return $value
}

proc graphy::dictTypeOf {d args} {
    # Get type from dict.
    #
    # d    - dict
    # args - list of dict keys
    #
    # Returns type

    foreach key $args {
        set type {}
        if {[dict exists $d $key]} {
            set d [dict get $d $key]
            set type [lindex $d 1]
            if {$type eq "dict"} {
                set d [lindex $d 0]
            }
        }
    }

    if {$type eq ""} {
        error "not 'type' for keys '$args'"
    }
    
    return $type
}

proc graphy::getValue {value key} {
    # Get the value of key.
    # Raise an error if item value is not even.
    #
    # value - dict value
    # key   - key item value
    #
    # Returns dict value.

    set d [dict get $value $key]

    if {[llength $d] % 2} {
        uplevel 1 {graphy::errorEvenArgs}
    }

    return $d
}

proc graphy::errorEvenArgs {} {
    # Error number of elements.
    #
    # Raise an error.
    set level  [uplevel 1 {info level}]
    set levelP [graphy::getLevelProperties $level]

    return -level [info level] \
           -code error "wrong # args: item list for\
                       '$levelP' must have an even number of elements."
}

proc graphy::getLevelProperties {level} {
    # Gets name level procedure
    #
    # level - num level procedure
    #
    # Returns list name of procs.
    set properties {}

    for {set i $level} {$i > 0} {incr i -1} {
        set name [lindex [info level $i] 0]
        if {
            ![string match {*getDictValueOrDefault*} $name] && 
            [string match {graphy::*} $name]
        } {
            set property [string map {graphy:: ""} $name]
            if {$property ni $properties} {
                lappend properties $property
            }
        }
    }

    return [join [lreverse $properties] "."]
}

proc graphy::isDict {value} {
    # Check if the value is a dictionary.
    #
    # value - dict
    #
    # Returns true, otherwise false.
    return [expr {![catch {dict size $value}]}]
}

proc graphy::keyCompare {d other} {
    # Compares the keys of dictionaries.
    # Output warning message if key name doesn't exist, 
    # in key default option.
    #
    # d      - dict
    # other  - list values
    #
    # Returns nothing

    if {$other eq "" || ![graphy::isDict $other]} {
        return {}
    }

    set keys1 [dict keys $d]
    set limit 5 ; set j 1

    foreach k [dict keys $other] {
        # Special case for 'dummy' key for theming.
        if {$k ni $keys1} {
            if {$j > $limit} {
                return -level [info level] -code error \
                    "The warning limit for key comparison has been exceeded."
            }
            set level    [expr {[info level] - 1}]
            set infoproc [graphy::getLevelProperties $level]
            puts stderr "warning($infoproc): '$k' property is not in\
                        '[join [lsort -dict $keys1] ", "]' or not supported."
            incr j
        }
    }

    return {}
}

proc graphy::isListOfList {args} {
    # Checks if the 'value' is of type list of list.
    #
    # args - list
    #
    # Returns true if value is a list of list,
    # false otherwise.

    # Cleans up the list of braces, spaces.
    regsub -all -line {(^\s+)|(\s+$)|\n|\t} $args {} str

    return [expr {
            [string range $str 0 1] eq "\{\{" &&
            [string range $str end-1 end] eq "\}\}"
        }
    ]
}

proc graphy::typeOf {value} {
    # Guess the type of the value.
    # 
    # value - string (everything is string !!!)
    #
    # Returns type of value

    if {$value eq "" || $value in {"null" "nothing"}} {
        return null
    }

    if {[string is double -strict $value] ||
        [string is integer -strict $value]} {
        return num
    }

    if {[string equal -nocase "true" $value] ||
        [string equal -nocase "false" $value]} {
        return bool
    }

    if {[graphy::isListOfList $value]} {
        return list
    }

    if {[graphy::isDict $value] && [graphy::isDictBox $value]} {
        return dict.b
    }
    
    if {[graphy::isPaintType $value]} {
        return paint
    }

    if {[graphy::isAObject $value]} {
        switch -glob -- [graphy::typeOfClass $value] {
            *::Dict  {return dict}
            *::Paint {return paint}
        }
    }

    return str
}

proc graphy::isPaintType {value} {

    return [regexp {^0x[0-9a-z]+\^paint} $value]

}

proc graphy::matchTypeOf {mytype type keyt} {
    # Guess type, follow optional list.
    # 
    # mytype - type
    # type   - list default type
    # keyt   - upvar key type
    #
    # Returns true if mytype is found, 
    # false otherwise.

    upvar 1 $keyt typekey

    foreach valtype [split $type "|"] {
        if {[string match $mytype* $valtype]} {
            set typekey $valtype
            return 1
        }
    }

    return 0
}

proc graphy::merge {d other} {
    # Merge 2 dictionaries and control the type of value.
    # An error exception is raised if type of value doesn't match.
    #
    # d      - dict (default option(s))
    # other  - list values
    #
    # Returns a new dictionary.

    # Output warning message if key name doesn't exist 
    # in key default option.
    graphy::keyCompare $d $other

    set _dict [dict create]

    dict for {key info} $d {
        lassign $info value type validvalue

        if {[dict exists $other $key]} {

            # REMINDER ME: use 'dict remove' for this.
            if {$type in {dict|null dict}} {
                error "wrong # type: default values for type dict \
                       shouldn't not be defined in 'other' dict for '$key' key property."
            }

            set value  [dict get $other $key]
            set mytype [graphy::typeOf $value]

            # Check type in default list
            if {![graphy::matchTypeOf $mytype $type typekey]} {
                errorType "set" $key $mytype $type
            }

        } else {

            set mytype [graphy::typeOf $value]

            # Check type in default list
            if {![graphy::matchTypeOf $mytype $type typekey]} {
                errorType "default" $key $mytype $type
            }
        }
        if {$mytype eq "dict"} {
            dict set _dict $key [list [$value get] $mytype]
        } else {
            dict set _dict $key [list $value $mytype]
        }
    }

    return $_dict
}

proc graphy::errorType {what key mytype type} {
    # Error message for incorrect type.
    #
    # what           - message type
    # key            - dict key
    # mytype         - type found by the typeOf function
    # type           - default list type (*|*)
    #
    # Throws an error.

    # Info level procedure.
    set level  [info level]
    set levelP [graphy::getLevelProperties $level]

    # Reformats the default list 'type' for easier reading.
    set t [split $type "|"]
    if {[llength $t] > 1} {
        set type [format {%s or %s} \
            [join [lrange $t 0 end-1] ", "] [lindex $t end] \
        ]
    }

    return -level $level -code error "wrong # type($what): property '$key'\
        should be '$type' instead of '$mytype' for '$levelP' level procedure."
}

proc graphy::isThousandFormat {axisconfig} {
    # Check if thousands format is used.
    #
    # axisconfig - axis config
    #
    # Returns true if thousands format is used,
    # false otherwise.
    set thousands_format false
    set opts [$axisconfig get]

    if {[graphy::dictTypeOf $opts -axisLabel formatter] ne "null"} {
        set valueformat [graphy::dictGet $opts -axisLabel formatter]
        if {[string match *$::graphy::THOUSANDS_FORMAT_LABEL* $valueformat]} {
            set thousands_format true
        }
    }

    return $thousands_format
}

proc graphy::formatParamsValue {params value} {
    # Format value according to thousands format.
    #
    # params - X or Y axis params
    # value  - value
    #
    # Returns formatted value.
    set unit ""

    if {[dict get $params thousands_format]} {
        return [graphy::thousandsFormatFloat $value]
    }
    
    if {$value >= $::graphy::T_VALUE} {
        set unit "T"
        set value [expr {$value / $::graphy::T_VALUE}]
    } elseif {$value >= $::graphy::G_VALUE} {
        set unit "G"
        set value [expr {$value / $::graphy::G_VALUE}]
    } elseif {$value >= $::graphy::M_VALUE} {
        set unit "M"
        set value [expr {$value / $::graphy::M_VALUE}]
    } elseif {$value >= $::graphy::K_VALUE} {
        set unit "k"
        set value [expr {$value / $::graphy::K_VALUE}]
    } else {
        set value $value
    }

    return [graphy::format_float $value]$unit
}

proc graphy::xAxisValues {params} {
    # Get X axis values.
    #
    # params - X axis params
    #
    # Returns axis values.

    set split_number [dict get $params split_number]
    set min Inf
    set max -Inf

    if {!$split_number} {
        set split_number 6
    }

    foreach value [dict get $params data_list] {

        if {![string is double -strict $value]} {
            error "wrong # value:\
                   property 'data_list' should be a list of numbers."
        }

        if {$value < $min} {set min $value}
        if {$value > $max} {set max $value}
    }

    set unit [expr {($max - $min) / double($split_number)}]

    set split_unit $unit
    set data {}
    for {set i 0} {$i <= $split_number} {incr i} {
        set value    [expr {$min + double($i) * $unit}]
        lappend data [graphy::thousandsFormatFloat $value]
    }

    dict set axisValues data $data
    dict set axisValues min  $min
    dict set axisValues max  [expr {$min + $split_unit * $split_number}]

    return $axisValues

}

proc graphy::yAxisValues {params} {
    # Get Y axis values.
    #
    # params - Y axis params
    #
    # Returns axis values.
    set min 0.0
    set max 0.0
    set split_number [dict get $params split_number]

    if {!$split_number} {
        set split_number 6
    }

    foreach item [dict get $params data_list] {
        if {$item in {null _}} {continue}
        if {$item < $min} {set min $item}
        if {$item > $max} {set max $item}
    }

    set is_custom_min false
    if {[dict get $params min] ne "nothing"} {
        if {[dict get $params min] < $min} {
            set min [dict get $params min]
            set is_custom_min true
        }
    }

    set is_custom_max false
    if {[dict get $params max] ne "nothing"} {
        if {[dict get $params max] > $max} {
            set max [dict get $params max]
            set is_custom_max true
        }
    }

    set unit [expr {($max - $min) / double($split_number)}]

    if {!$is_custom_max} {
        set ceil_value [expr {ceil($unit * 10.0)}]
        if {$ceil_value < 12.0} {
            set unit [expr {$ceil_value / 10.0}]
        } else {
            set new_unit [expr {int($unit)}]
            set adjustUnit [graphy::adjustUnit [expr {int($unit)}] 10]

            if {$new_unit < 10} {
                set new_unit [graphy::adjustUnit $new_unit 2]
            } elseif {$new_unit < 100} {
                set new_unit [graphy::adjustUnit $new_unit 5]
            } elseif {$new_unit < 500} {
                set new_unit [graphy::adjustUnit $new_unit 10]
            } elseif {$new_unit < 1000} {
                set new_unit [graphy::adjustUnit $new_unit 20]
            } elseif {$new_unit < 5000} {
                set new_unit [graphy::adjustUnit $new_unit 50]
            } elseif {$new_unit < 10000} {
                set new_unit [graphy::adjustUnit $new_unit 100]
            } else {
                set small_unit [expr {int(($max - $min) / 20.0)}]
                set new_unit [graphy::adjustUnit $new_unit [expr {$small_unit / 100 * 100}]]
            }
            set unit [expr {double($new_unit)}]
        }
    }

    set split_unit $unit
    set data {}
    for {set i 0} {$i <= $split_number} {incr i} {
        set value    [expr {$min + double($i) * $split_unit}]
        lappend data [graphy::formatParamsValue $params $value]
    }

    if {[dict get $params reverse]} {
        set data [lreverse $data]
    }

    dict set axisValues data $data
    dict set axisValues min  $min
    dict set axisValues max  [expr {$min + $split_unit * $split_number}]

    return $axisValues

}

proc graphy::thousandsFormatFloat {value} {
    # From wiki (always !!) 
    # https://wiki.tcl-lang.org/page/commas+added+to+numbers

    if {$value < 1000} {return [graphy::format_float $value]}

    set value [format %.0f $value]

    return [regsub -all \\d(?=(\\d{3})+([regexp -inline {\.\d*$} $value]$)) $value {\0,}]
}

proc graphy::format_float {value} {

    set str [format %.1f $value]
    if {[string range $str end-1 end] eq ".0"} {
        return [string range $str 0 end-2]
    }

    return $str
}


proc graphy::adjustUnit {current small_unit} {
    # Adjust unit.
    #
    # current - current unit
    # small_unit - unit to adjust
    #
    # Returns adjusted unit.

    if {!($current % $small_unit)} {
        return [expr {$current + $small_unit}]
    } else {
        return [expr {($current / $small_unit + 1) * $small_unit}]
    }
}

proc graphy::formatString {value format} {
    # Format value according to formatter option.
    #
    # value  - value
    # format - string format
    #
    # Returns formatted value.

    if {$format eq "nothing"} {
        set formatvalue $value
    } else {
        set vfl $::graphy::VALUE_FORMAT_LABEL
        set tfl $::graphy::THOUSANDS_FORMAT_LABEL
        set formatvalue [string map [list $vfl $value] $format]
        set formatvalue [string map [list $tfl $value] $formatvalue]
    }

    return $formatvalue
}

proc graphy::getOffsetHeight {y_axis_values value max_height} {
    # Get offset height.
    #
    # y_axis_values - y axis values
    # value         - value
    # max_height    - max height
    #
    # Returns offset height.

    set min [dict get $y_axis_values min]
    set max [dict get $y_axis_values max]
    
    set offset  [expr {double($max - $min)}]
    set percent [expr {($value - $min) / $offset}]
    
    return [expr {$max_height - $percent * $max_height}]

}

proc graphy::getOffsetWidth {x_axis_values value max_width} {
    # Get offset width.
    #
    # x_axis_values - x axis values
    # value         - value
    # max_width     - max width
    #
    # Returns offset width.

    set min [dict get $x_axis_values min]
    set max [dict get $x_axis_values max]
    
    set offset  [expr {double($min - $max)}]
    set percent [expr {($value - $max) / $offset}]
    
    return [expr {$max_width - $percent * $max_width}]

}

proc graphy::measuretextwidth {family fontsize text} {
    # Measure text width.
    #
    # family - font family
    # fontsize - font size
    # text - text
    #
    # Returns text width + height.

    set font [pix::font::readFont $family]
    pix::font::configure $font [list size $fontsize]

    set layoutBounds [pix::font::layoutBounds $font $text]
    set x [lindex $layoutBounds 0]
    set y [lindex $layoutBounds 1]

    pix::font::destroy $font

    return [graphy::newBox left 0 top 0 right $x bottom $y]
}

proc graphy::measurelegends {family fontsize legends} {
    # Measure legends width.
    #
    # family - font family
    # fontsize - font size
    # legends - legends
    #
    # Returns legends width.

    set widths {}

    foreach item $legends {
        set text_box [graphy::measuretextwidth $family $fontsize $item]
        lappend widths [expr {[graphy::widthBox $text_box] + $::graphy::LEGEND_WIDTH + $::graphy::LEGEND_TEXT_MARGIN}]
    }

    set width [tcl::mathop::+ {*}$widths]
    set margin [expr {$::graphy::LEGEND_MARGIN * ([llength $legends] - 1)}]

    return [list [expr {$width + $margin}] $widths]
}

proc graphy::formatSeriesValue {value formatter} {
    # Format value according to formatter option.
    #
    # value     - value
    # formatter - string format
    #
    # Returns formatted value.

    if {[string match *$::graphy::THOUSANDS_FORMAT_LABEL* $formatter]} {
        return [graphy::thousandsFormatFloat $value]
    } else {
        return [graphy::format_float $value]
    }
}

proc graphy::getColor {colors index} {
    # Get color.
    #
    # colors - list of colors
    # index  - index
    #
    # Returns color.

    set i [expr {$index % [llength $colors]}]
    return [lindex $colors $i]
}

proc graphy::getBoxOfPoints {points} {
    # Get box of points.
    #
    # points - list of points
    #
    # Returns new box.
    set b [graphy::newBox]

    foreach p $points {
        lassign $p px py

        if {$px < [$b left]} {
            charts::setBox b left $px
        }
        if {$px > [$b right]} {
            charts::setBox b right $px
        }
        if {$py < [$b top]} {
            charts::setBox b top $py
        }
        if {$py > [$b bottom]} {
            charts::setBox b bottom $py
        }
    }

    return $b

}

proc graphy::formatPixel {value strokewidth} {
    # Format pixel.
    #
    # value       - value
    # strokewidth - stroke width
    #
    # Returns formatted pixel.
    if {$strokewidth > 1} {
        return $value
    }

    set pixel [expr {$strokewidth / 2.0}]
    set integer_part [expr {int($value)}]

    return [expr {$integer_part + $pixel}]
}

proc graphy::getControlPoints {p left right t} {
    # Get control points.
    #
    # p       - point
    # left    - left point
    # right   - right point
    # t       - tension
    #
    # Returns control points.
    lassign $left  x0 y0
    lassign $p     x1 y1
    lassign $right x2 y2

    if {$x0 eq ""} {set x0 $x1}
    if {$y0 eq ""} {set y0 $y1}

    if {$x2 eq ""} {set x2 $x1}
    if {$y2 eq ""} {set y2 $y1}

    set d01 [expr {sqrt(pow($x1 - $x0, 2.0) + pow($y1 - $y0, 2.0))}]
    set d12 [expr {sqrt(pow($x2 - $x1, 2.0) + pow($y2 - $y1, 2.0))}]

    set fa [expr {$t * $d01 / ($d01 + $d12)}]
    set fb [expr {$t * $d12 / ($d01 + $d12)}]

    set p1x [expr {$x1 - $fa * ($x2 - $x0)}]

    set p1y [expr {$y1 - $fa * ($y2 - $y0)}]
    set p2x [expr {$x1 + $fb * ($x2 - $x0)}]
    set p2y [expr {$y1 + $fb * ($y2 - $y0)}]

    set cpl {} ; set cpr {}

    if {$left ne ""} {
        set cpl [list $p1x $p1y]
    }

    if {$right ne ""} {
        set cpr [list $p2x $p2y]
    }

    return [list left $cpl right $cpr]

}

proc graphy::getPiePoint {cx cy r angle} {

    set value [expr {$angle / 180.0 * $::graphy::PI}]

    set x [expr {$cx + $r * sin($value)}]
    set y [expr {$cy - $r * cos($value)}]

    return [list $x $y]

}

proc graphy::seriesDefaultName {series name} {
    # Get default name.
    #  
    # series - series
    # name - name
    # 
    # Returns default name.
    regexp {[0-9]+} $name newName

    return ${series}${newName}

}

proc graphy::updateCharts {chart w h} {
    # Update charts.
    #  
    # chart - chart object
    # w     - width
    # h     - height
    # 
    # Returns nothing.
    variable upid

    unset upid($chart,update)
    
    if {[$chart get ctx] ne ""} {
        pix::img::destroy [dict get [pix::ctx::get [$chart get ctx]] image addr]
        pix::ctx::destroy [$chart get ctx]
        pix::img::destroy [$chart get ctxImg]
        
        foreach {key item} [$chart get ctxPath] {
            pix::path::destroy [dict get $item path]
        }
    }

    # bind [$chart get widget] <Motion>  {break}
    bind [$chart get widget] <Destroy> {break}
    
    if {[info exists upid($chart,redraw)]} {after cancel $upid($chart,redraw)}

    $chart Render -width $w -height $h

}

proc graphy::cleanDataCharts {chart} {
    # Clean data when widget is destroyed.
    #  
    # chart - chart object
    # 
    # Returns nothing.
    variable upid

    unset upid($chart,update)
    
    if {[$chart get ctx] ne ""} {
        pix::img::destroy [dict get [pix::ctx::get [$chart get ctx]] image addr]
        pix::ctx::destroy [$chart get ctx]
        pix::img::destroy [$chart get ctxImg]
        
        foreach {key item} [$chart get ctxPath] {
            pix::path::destroy [dict get $item path]
        }
    }

    bind [$chart get widget] <Motion> {break}
    
    if {[info exists upid($chart,redraw)]} {after cancel $upid($chart,redraw)}

}

proc graphy::reDraw {W chart self} {
    # Redraw chart.
    #
    # W     - widget
    # chart - chart object
    # self  - self
    #
    # Returns nothing.
    variable upid

    if {
        [winfo ismapped $W] &&
        (([winfo width $W] != [$chart get width]) || ([winfo height $W] != [$chart get height]))
    } {

        if {[info exists upid($chart,update)]} {after cancel $upid($chart,update)}

        $chart set width  [winfo width $W]
        $chart set height [winfo height $W]

        set upid($chart,update) [after 100 graphy::updateCharts $chart [winfo width $W] [winfo height $W]]
        
    }

    set upid($chart,redraw) [after 60 graphy::reDraw $W $chart $self]

}