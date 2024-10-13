# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

namespace eval graphy {}

oo::class create graphy::XAxis {

    variable _xaxis {}

    constructor {args} {
    
        if {[llength $args] % 2} graphy::errorEvenArgs

        graphy::setdef options -data           -validvalue {}  -type str       -default {}
        graphy::setdef options -height         -validvalue {}  -type num       -default 30
        graphy::setdef options -margin         -validvalue {}  -type dict.b    -default [graphy::newBox]
        graphy::setdef options -show           -validvalue {}  -type bool      -default "True"
        graphy::setdef options -axisLine       -validvalue {}  -type dict      -default [graphy::axisLine $args]
        graphy::setdef options -axisTick       -validvalue {}  -type dict      -default [graphy::axisTick $args]
        graphy::setdef options -minorTick      -validvalue {}  -type dict      -default [graphy::minorTick $args]
        graphy::setdef options -axisLabel      -validvalue {}  -type dict      -default [graphy::axisLabel $args]
        graphy::setdef options -boundaryGap    -validvalue {}  -type bool      -default "True"
        graphy::setdef options -type           -validvalue {}  -type str       -default "category"
        graphy::setdef options -splitNumber    -validvalue {}  -type num       -default 6
        graphy::setdef options -name           -validvalue {}  -type str|null  -default "nothing"
        graphy::setdef options -nameLocation   -validvalue {}  -type str       -default "middle"
        graphy::setdef options -nameTextStyle  -validvalue {}  -type dict      -default [graphy::nameTextStyle $args]
        
        set args [dict remove $args -axisLine -axisTick -axisLabel -minorTick -nameTextStyle]
        set _xaxis [graphy::merge $options $args]
        
    }

    method get {} {
        return $_xaxis
    }

}

oo::class create graphy::YAxis {

    variable _yaxis {}

    constructor {args} {

        if {[llength $args] % 2} graphy::errorEvenArgs

        graphy::setdef options -show           -validvalue {}  -type bool      -default "True"
        graphy::setdef options -axisLabel      -validvalue {}  -type dict      -default [graphy::axisLabel $args]
        graphy::setdef options -axisLine       -validvalue {}  -type dict      -default [graphy::axisLine $args]
        graphy::setdef options -axisTick       -validvalue {}  -type dict      -default [graphy::axisTick $args]
        graphy::setdef options -minorTick      -validvalue {}  -type dict      -default [graphy::minorTick $args]
        graphy::setdef options -splitNumber    -validvalue {}  -type num       -default 6
        graphy::setdef options -margin         -validvalue {}  -type dict.b    -default [graphy::newBox 0]
        graphy::setdef options -min            -validvalue {}  -type num|null  -default "nothing"
        graphy::setdef options -max            -validvalue {}  -type num|null  -default "nothing"
        graphy::setdef options -reverse        -validvalue {}  -type bool      -default "True"
        graphy::setdef options -type           -validvalue {}  -type str       -default "value"
        graphy::setdef options -name           -validvalue {}  -type str|null  -default "nothing"
        graphy::setdef options -nameLocation   -validvalue {}  -type str       -default "middle"
        graphy::setdef options -nameTextStyle  -validvalue {}  -type dict      -default [graphy::nameTextStyle $args]

        set args [dict remove $args -axisLine -axisTick -axisLabel -minorTick -nameTextStyle]
        set _yaxis [graphy::merge $options $args]
        
    }

    method get {} {
        return $_yaxis
    }
}
