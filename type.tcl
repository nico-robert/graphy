# Copyright (c) 2024 Nicolas ROBERT.
# Distributed under MIT license. Please see LICENSE for details.

namespace eval graphy {}

oo::class create graphy::Dict {
    variable _dict

    constructor {d} {
        # Initializes a new graphy::Dict Class.
        #
        set _dict $d
    }

    method get {} {
        # Returns dict
        return $_dict
    }

}

proc graphy::newDict {value} {
    # This procedure substitutes a pure Tcl dict.
    # 
    # value - dict tcl
    #
    # example :
    # newDict {key value key1 value1 ...}
    #
    # Returns a new Dict object.

    if {![graphy::isDict $value]} {
        error "wrong # args: Should be a dict\
               representation."
    }

    return [graphy::Dict new $value]
}

proc graphy::isDictClass {value} {
    # Check if value is Dict class.
    #
    # value - obj or string
    #
    # Returns true if 'value' is a Dict class, 
    # false otherwise.
    return [expr {
            [string match {::oo::Obj[0-9]*} $value] && 
            [string match "*::Dict" [graphy::typeOfClass $value]]
        }
    ]
}

oo::class create graphy::Paint {
    variable _paint

    constructor {args} {
        # Initializes a new graphy::Paint Class.
        #

        if {[llength $args] % 2} graphy::errorEvenArgs
    
        graphy::setdef options -type           -validvalue {}  -type str  -default "LinearGradientPaint"
        graphy::setdef options -gradientStops  -validvalue {}  -type list -default ""

        set _paint [graphy::merge $options $args]

    }

    method get {} {
        return $_paint
    }

}

proc graphy::isePaintClass {value} {
    # Check if value is Paint class.
    #
    # value - obj or string
    #
    # Returns true if 'value' is a Paint class, 
    # false otherwise.
    return [expr {
            [string match {::oo::Obj[0-9]*} $value] && 
            [string match "*::Paint" [graphy::typeOfClass $value]]
        }
    ]
}