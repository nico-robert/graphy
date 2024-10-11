# Copyright (c) 2024 Nicolas ROBERT.
# Distributed under MIT license. Please see LICENSE for details.

namespace eval graphy {}

proc graphy::globalOptions {d} {
    # Global options chart
    #
    # d - Options described below.
    #
    # Returns dict options

    if {[llength $d] % 2} graphy::errorEvenArgs

    setdef options -background     -validvalue {} -type str|paint|null -default "white"
    setdef options -areaBackground -validvalue {} -type str|paint|null -default "nothing"
    setdef options -color          -validvalue {} -type str|null       -default {"#5470c6" "#91cc75" "#fac858" "#ee6666" "#73c0de" "#3ba272" "#fc8452" "#9a60b4" "#ea7ccc"}
    setdef options -margin         -validvalue {} -type dict.b         -default {left 20 top 35 right 40 bottom 5}

    return [merge $options $d]
}

proc graphy::title {d} {
    # Title options chart
    #
    # d - Options described below.
    #
    # Returns dict options

    if {[llength $d] % 2} graphy::errorEvenArgs

    setdef options show             -validvalue {}  -type bool        -default "True"
    setdef options text             -validvalue {}  -type str|null    -default "nothing"
    setdef options subtext          -validvalue {}  -type str|null    -default "nothing"
    setdef options textPadding      -validvalue {}  -type dict.b      -default [graphy::newBox left 0 top 5 right 0 bottom 5]
    setdef options subTextPadding   -validvalue {}  -type dict.b      -default [graphy::newBox left 0 top 5 right 0 bottom 0]
    setdef options itemGap          -validvalue {}  -type num         -default 5
    setdef options backgroundColor  -validvalue {}  -type str|null    -default "nothing"
    setdef options borderColor      -validvalue {}  -type str|null    -default "rgba(70,70,70,1)"
    setdef options borderWidth      -validvalue {}  -type num         -default 1
    setdef options borderRadius     -validvalue {}  -type num|list    -default {{0 0 0 0}}
    setdef options subtextStyle     -validvalue {}  -type dict        -default [graphy::textStyle $d subtextStyle]
    setdef options textStyle        -validvalue {}  -type dict        -default [graphy::textStyle $d textStyle]
    #...

    # remove key(s)...
    set d [dict remove $d textStyle subtextStyle]
    
    return [merge $options $d]
}


proc graphy::tooltip {d} {

    if {[llength $d] % 2} graphy::errorEvenArgs

    setdef options show               -validvalue {}   -type bool                   -default "True"
    setdef options trigger            -validvalue {}   -type str|null               -default "item"
    setdef options position           -validvalue {}   -type str|list.d|jsfunc|null -default "nothing"
    setdef options formatter          -validvalue {}   -type str|jsfunc|null        -default "nothing"
    setdef options backgroundColor    -validvalue {}   -type paint|str|null         -default "nothing"
    setdef options borderColor        -validvalue {}   -type str|null               -default "nothing"
    setdef options borderWidth        -validvalue {}   -type num|null               -default "nothing"
    setdef options padding            -validvalue {}   -type num|list.n|null        -default 5
    setdef options order              -validvalue {}   -type str|null               -default "seriesAsc"
    #...

    # remove key(s)...
    set d [dict remove $d axisPointer textStyle]

    return [merge $options $d]
}

proc graphy::legend {d} {
    # Legend options chart
    #
    # d - Options described below.
    #
    # Returns dict options

    if {[llength $d] % 2} graphy::errorEvenArgs

    setdef options show        -validvalue {}  -type bool      -default "True"
    setdef options fontSize    -validvalue {}  -type num       -default 14
    setdef options fontFamily  -validvalue {}  -type str       -default [file join $::graphy::tdir font OpenSans-SemiBold.ttf]
    setdef options fontColor   -validvalue {}  -type str       -default "rgba(70,70,70,1)"
    setdef options fontWeight  -validvalue {}  -type str       -default "normal"
    setdef options align       -validvalue {}  -type str       -default "center"
    setdef options margin      -validvalue {}  -type dict.b    -default [graphy::newBox left 0 top 5 right 0 bottom 5]
    setdef options category    -validvalue {}  -type str       -default "normal"
    #...

    return [merge $options $d]
}

proc graphy::textStyle {d key} {
    # TextStyle options chart
    #
    # d   - Options described below.
    # key - dictionnary key.
    #
    # Returns dict options

    if {[llength $d] % 2} graphy::errorEvenArgs

    set levelP [graphy::getLevelProperties [info level]]

    if {![dict exists $d $key]} {
        dict set d $key {}
    }

    set d [dict get $d $key]

    if {$key eq "subtextStyle"} {
        set color "grey"
        set font_size 13
    } else {
        set color "rgba(70,70,70,1)"
        set font_size 12
    }

    setdef options fontSize    -validvalue {}  -type num       -default $font_size
    setdef options fontFamily  -validvalue {}  -type str       -default [file join $::graphy::tdir font OpenSans-SemiBold.ttf]
    setdef options fontColor   -validvalue {}  -type str       -default $color
    setdef options fontWeight  -validvalue {}  -type str       -default "normal"
    setdef options align       -validvalue {}  -type str       -default "center"
    #...

    return [newDict [merge $options $d]]
}

proc graphy::grid {d} {
    # Grid options chart
    #
    # d - Options described below.
    #
    # Returns dict options

    if {[llength $d] % 2} graphy::errorEvenArgs

    setdef options showY       -validvalue {}  -type bool      -default "True"
    setdef options showX       -validvalue {}  -type bool      -default "False"
    setdef options hiddenX     -validvalue {}  -type list|null  -default "nothing"
    setdef options hiddenY     -validvalue {}  -type list|null  -default "nothing"
    setdef options lineStyle   -validvalue {}  -type dict      -default [graphy::lineStyle $d "lineStyle"]
    #...
    
    set d [dict remove $d lineStyle]

    return [merge $options $d]
}

proc graphy::lineStyle {d key} {
    # lineStyle options chart
    #
    # d   - Options described below.
    # key - dictionnary key.
    #
    # Returns dict options

    if {[llength $d] % 2} graphy::errorEvenArgs

    set levelP [graphy::getLevelProperties [info level]]
    
    if {![dict exists $d $key]} {dict set d $key {}}
    
    switch -glob -- $levelP {
        "grid.lineStyle" {
            set width 1
            set color "lightgray"
        }
        "series::Bar.lineStyle" {
            set width 1
            set color "nothing"
        }
        "*axisLine.lineStyle" -
        "*axisTick.lineStyle" {
            set width 1
            set color "rgba(110,112,121,1)"
        }
        default {
            set width 2
            set color "nothing"
        }
    }
    
    set d [dict get $d $key]

    setdef options color          -validvalue {} -type str|null     -default $color
    setdef options width          -validvalue {} -type num          -default $width
    setdef options dashes         -validvalue {} -type str|num|null -default "nothing"
    setdef options shadowBlur     -validvalue {} -type num          -default 0
    setdef options shadowColor    -validvalue {} -type str          -default "rgba(0,0,0,0.5)"
    setdef options shadowOffsetX  -validvalue {} -type num          -default 2
    setdef options shadowOffsetY  -validvalue {} -type num          -default 2
    #...

    return [newDict [merge $options $d]]
}

proc graphy::backgroundStyle {d} {
    # BackgroundStyle options chart
    #
    # d - Options described below.
    #
    # Returns dict options

    if {[llength $d] % 2} graphy::errorEvenArgs

    set levelP [graphy::getLevelProperties [info level]]
    
    if {![dict exists $d -backgroundStyle]} {dict set d -backgroundStyle {}}
        
    set d [dict get $d -backgroundStyle]

    setdef options color          -validvalue {} -type str|null     -default "rgba(180,180,180,0.2)"
    setdef options borderColor    -validvalue {} -type str|null     -default "#000"
    setdef options borderRadius   -validvalue {} -type num|list     -default {{0 0 0 0}}
    setdef options width          -validvalue {} -type num          -default 0
    setdef options dashes         -validvalue {} -type str|num|null -default "nothing"
    setdef options shadowBlur     -validvalue {} -type num          -default 0
    setdef options shadowColor    -validvalue {} -type str          -default "rgba(0,0,0,0.5)"
    setdef options shadowOffsetX  -validvalue {} -type num          -default 2
    setdef options shadowOffsetY  -validvalue {} -type num          -default 2
    #...

    return [newDict [merge $options $d]]
}

proc graphy::label {d key} {
    # label options chart
    #
    # d   - Options described below.
    # key - dictionnary key.
    #
    # Returns dict options

    if {[llength $d] % 2} graphy::errorEvenArgs

    set levelP [graphy::getLevelProperties [info level]]

    if {![dict exists $d $key]} {dict set d $key {}}
    
    set d [dict get $d $key]

    set show "False"

    if {[string match {*markPoint.label} $levelP] || [string match {*markLine.label} $levelP]} {
        set show "True"
    }

    setdef options show        -validvalue {}  -type bool      -default $show
    setdef options offsetX     -validvalue {}  -type num       -default 0
    setdef options offsetY     -validvalue {}  -type num       -default 5
    setdef options fontSize    -validvalue {}  -type num       -default 12
    setdef options fontFamily  -validvalue {}  -type str       -default [file join $::graphy::tdir font OpenSans-SemiBold.ttf]
    setdef options fontColor   -validvalue {}  -type str       -default "rgba(70,70,70,1)"
    setdef options fontWeight  -validvalue {}  -type str       -default "normal"
    setdef options formatter   -validvalue {}  -type str|null  -default "nothing"
    setdef options nameRotate  -validvalue {}  -type num       -default 0
    setdef options align       -validvalue {}  -type str       -default "top"
    #...

    return [newDict [merge $options $d]]
}

proc graphy::nameTextStyle {d} {
    # nameTextStyle options chart
    #
    # d - Options described below.
    #
    # Returns dict options

    if {[llength $d] % 2} graphy::errorEvenArgs

    set levelP [graphy::getLevelProperties [info level]]

    if {![dict exists $d -nameTextStyle]} {dict set d -nameTextStyle {}}
    
    set d [dict get $d -nameTextStyle]

    setdef options fontSize    -validvalue {}  -type num       -default 12
    setdef options fontFamily  -validvalue {}  -type str       -default [file join $::graphy::tdir font OpenSans-Regular.ttf]
    setdef options fontColor   -validvalue {}  -type str       -default "rgba(70,70,70,1)"
    setdef options fontWeight  -validvalue {}  -type str       -default "normal"
    #...

    return [newDict [merge $options $d]]
}

proc graphy::itemStyle {d} {
    # itemStyle options chart
    #
    # d - Options described below.
    #
    # Returns dict options

    if {[llength $d] % 2} graphy::errorEvenArgs

    set levelP [graphy::getLevelProperties [info level]]

    if {![dict exists $d -itemStyle]} {dict set d -itemStyle {}}
    
    set d [dict get $d -itemStyle]

    setdef options borderRadius  -validvalue {}  -type num|list -default {{0 0 0 0}}

    #...

    return [newDict [merge $options $d]]
}

proc graphy::markPoint {d} {
    # markPoint options chart
    #
    # d - Options described below.
    #
    # Returns dict options

    set levelP [graphy::getLevelProperties [info level]]

    if {![dict exists $d -markPoint]} {
        return "nothing"
    }

    set items {}

    foreach item [dict get $d -markPoint] {

        if {[llength $item] % 2} graphy::errorEvenArgs

        setdef options category  -validvalue {}  -type str  -default ""
        setdef options label     -validvalue {}  -type dict -default [graphy::label $item "label"]
        setdef options symbol    -validvalue {}  -type str  -default "pin"

        set item      [dict remove $item label]
        lappend items mark [merge $options $item]
        set options {}
    }

    return [newDict $items]
}

proc graphy::markLine {d} {
    # markLine options chart
    #
    # d - Options described below.
    #
    # Returns dict options

    set levelP [graphy::getLevelProperties [info level]]

    if {![dict exists $d -markLine]} {
        return "nothing"
    }

    set items {}

    foreach item [dict get $d -markLine] {
        if {[llength $item] % 2} graphy::errorEvenArgs

        setdef options category  -validvalue {}  -type str  -default ""
        setdef options label     -validvalue {}  -type dict -default [graphy::label $item "label"]

        set item      [dict remove $item label]
        lappend items mark [merge $options $item]
        set options {}
    }

    return [newDict $items]
}

proc graphy::areaStyle {d} {
    # areaStyle options chart
    #
    # d - Options described below.
    #
    # Returns dict options

    if {[llength $d] % 2} graphy::errorEvenArgs

    set levelP [graphy::getLevelProperties [info level]]

    if {![dict exists $d -areaStyle]} {
        return "nothing"
    }
    
    set d [dict get $d -areaStyle]

    setdef options color       -validvalue {}  -type str|paint|null  -default "nothing"
    setdef options opacity     -validvalue {}  -type num             -default 0.2
    #...

    return [newDict [merge $options $d]]
}

proc graphy::minorTick {d} {
    # minorTick options chart
    #
    # d - Options described below.
    #
    # Returns dict options

    if {[llength $d] % 2} graphy::errorEvenArgs

    set levelP [graphy::getLevelProperties [info level]]

    if {![dict exists $d -minorTick]} {dict set d -minorTick {}}
    
    set d [dict get $d -minorTick]

    setdef options show -validvalue {} -type bool -default "False"
    #...

    return [newDict [merge $options $d]]
}

proc graphy::axisLabel {d} {
    # axisLabel options chart
    #
    # d - Options described below.
    #
    # Returns dict options

    if {[llength $d] % 2} graphy::errorEvenArgs

    set levelP [graphy::getLevelProperties [info level]]

    if {![dict exists $d -axisLabel]} {dict set d -axisLabel {}}
    
    set d [dict get $d -axisLabel]

    setdef options show        -validvalue {}  -type bool      -default "True"
    setdef options nameGap     -validvalue {}  -type num       -default 7
    setdef options nameRotate  -validvalue {}  -type num       -default 0
    setdef options fontSize    -validvalue {}  -type num       -default 13
    setdef options fontFamily  -validvalue {}  -type str       -default [file join $::graphy::tdir font OpenSans-Regular.ttf]
    setdef options fontColor   -validvalue {}  -type str       -default "rgba(70,70,70,1)"
    setdef options fontWeight  -validvalue {}  -type str       -default "normal"
    setdef options formatter   -validvalue {}  -type str|null  -default "@f.t"
    setdef options align       -validvalue {}  -type str       -default "left"
    #...

    return [newDict [merge $options $d]]
}

proc graphy::axisLine {d} {
    # axisLine options chart
    #
    # d - Options described below.
    #
    # Returns dict options

    if {[llength $d] % 2} graphy::errorEvenArgs

    set levelP [graphy::getLevelProperties [info level]]

    if {![dict exists $d -axisLine]} {dict set d -axisLine {}}
    
    set d [dict get $d -axisLine]
    
    set show "True"
    
    if {$levelP eq "YAxis.axisLine"} {
        set show false
    }

    setdef options show       -validvalue {}  -type bool -default $show
    setdef options lineStyle  -validvalue {}  -type dict -default [graphy::lineStyle $d "lineStyle"]
    #...
    
    set d [dict remove $d lineStyle]

    return [newDict [merge $options $d]]
}

proc graphy::axisTick {d} {
    # axisTick options chart
    #
    # d - Options described below.
    #
    # Returns dict options

    if {[llength $d] % 2} graphy::errorEvenArgs

    set levelP [graphy::getLevelProperties [info level]]

    if {![dict exists $d -axisTick]} {dict set d -axisTick {}}
    
    set d [dict get $d -axisTick]

    setdef options length    -validvalue {} -type num  -default 5
    setdef options start     -validvalue {} -type num  -default 0
    setdef options interval  -validvalue {} -type num  -default 0
    setdef options lineStyle -validvalue {} -type dict -default [graphy::lineStyle $d "lineStyle"]
    #...
    
    set d [dict remove $d lineStyle]

    return [newDict [merge $options $d]]
}


