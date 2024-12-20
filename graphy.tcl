# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# 05-oct-2024 : 1.0b1 Initial release
# 11-oct-2024 : 1.0b2
                # Add vertical stacked bar series.
                # Add examples vertical `stacked` bar.
# 13-oct-2024 : 1.0b3
                # Updating the `MIT` license to `MPL 2.0`, to match the derived code.
                # Cosmetic changes.
# 16-oct-2024 : 1.0b4
                # Add horizontal and stacked bar series.
                # Add examples horizontal and stacked bar.
                # Cosmetic changes.
# 27-oct-2024 : 1.0b5
                # Add X type value.
                # Add toolbox utility (save image, zoom).
                # Add example XAxis values + toolbox utility.
                # Add clip path.

package require Tcl 8.6
package require pix 0.3

namespace eval graphy {
    variable version              "1.0b5"
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