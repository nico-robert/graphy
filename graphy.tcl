# Copyright (c) 2024 Nicolas ROBERT.
# Distributed under MIT license. Please see LICENSE for details.

# 05-oct-2024 : v1.0b1 Initial release

package require Tcl 8.6
package require pix 0.3

namespace eval graphy {
    variable version              "1.0b1"
    variable upid
    variable tdir                 [file dirname [file normalize [info script]]]
    variable PI                   [expr {acos(-1)}]
    variable WIDTH                600
    variable HEIGHT               400
    variable DEFAULT_Y_AXIS_WIDTH 40.0
    variable LEGEND_WIDTH         25.0
    variable LEGEND_HEIGHT        20.0
    variable LEGEND_TEXT_MARGIN   3.0
    variable LEGEND_MARGIN        12.0
    variable THOUSANDS_FORMAT_LABEL "@f.t"
    variable VALUE_FORMAT_LABEL     "@f.c"
    variable K_VALUE 1000.0
    variable M_VALUE [expr {$K_VALUE * $K_VALUE}]
    variable G_VALUE [expr {$M_VALUE * $K_VALUE}]
    variable T_VALUE [expr {$G_VALUE * $K_VALUE}]
}

package provide graphy $::graphy::version