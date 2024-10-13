# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

namespace eval graphy {}

proc graphy::BoxDefault {} {
    return [graphy::newBox]
}

proc graphy::newBox {{args ""}} {

    if {[llength $args]} {
        if {[llength $args] == 8} {
            foreach {key value} $args {
                dict set box $key $value
            }
        } elseif {[llength $args] == 1} {
            set val $args
            dict set box left $val
            dict set box top $val 
            dict set box right $val
            dict set box bottom $val
        } else {
            error "Invalid box definition"
        }
    } else {
        dict set box left 0
        dict set box top 0 
        dict set box right 0
        dict set box bottom 0
    }

    return $box
}

proc graphy::topBox {box} {
    return [dict get $box top]
}

proc graphy::leftBox {box} {
    return [dict get $box left]
}

proc graphy::rightBox {box} {
    return [dict get $box right]
}

proc graphy::bottomBox {box} {
    return [dict get $box bottom]
}

proc graphy::widthBox {box} {
    return [expr {[dict get $box right] - [dict get $box left]}]
}

proc graphy::heightBox {box} {
    return [expr {[dict get $box bottom] - [dict get $box top]}]
}

proc graphy::outerWidthBox {box} {
    return [dict get $box right]
}

proc graphy::outerHeightBox {box} {
    return [dict get $box bottom]
}

proc graphy::setBox {box key value} {

    upvar $box b

    if {![dict exists $b $key]} {
        error "property '$key' doesn't exists for Box"
    }

    dict set b $key $value

    return {}
}

proc graphy::isDictBox {value} {

    foreach k [dict keys $value] {
        if {$k ni {left top right bottom}} {
            return 0
        }
    } 

    return 1
}