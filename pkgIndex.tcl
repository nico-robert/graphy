# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

package ifneeded graphy 1.0b2 [list apply {dir {

    source [file join $dir graphy.tcl]
    source [file join $dir charts.tcl]
    source [file join $dir utils.tcl]
    source [file join $dir box.tcl]
    source [file join $dir series.tcl]
    source [file join $dir canvas.tcl]
    source [file join $dir axis.tcl]
    source [file join $dir component.tcl]
    source [file join $dir draw.tcl]
    source [file join $dir options.tcl]
    source [file join $dir bind.tcl]
    source [file join $dir type.tcl]

}} $dir]