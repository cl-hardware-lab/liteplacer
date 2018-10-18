//-
// SPDX-License-Identifier: BSD-2-Clause
//
// Copyright (c) 2018 Brian Jones
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in the
//    documentation and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
// OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
// HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
// LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
// OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
// SUCH DAMAGE.
//


// all units are mm


theight = 3.6;		// total height of plastic
pheight = 1;		// pocket height (ie thickness of bottom of channel)
tapewidth = 8 ;	// with of component tape in mm
striplength = 200 ;	// length of strip
tickinterval = 10 ;	// interval between tapeholding bumps
tickcylinder = 1.0;	// bump is formed of a cylinder
tickcylinder_overlap = 0.15 ;	// offset of tickcylinder to slightly impinge on the channel


//difference() {

	union() {

// basic shape done as a polygon which is rotated and extruded
		rotate([0,270,0]) 
		linear_extrude(height=striplength,center=true,convexity=10) {

			polygon(points=[ [0,0],[theight,0],[theight,2],[pheight,2],[pheight,2+tapewidth],[theight,2+tapewidth],[theight,4+tapewidth],[0,4+tapewidth] ]);

		} // end linear_extrude


	// add tape holding bumps
		for(i= [5-striplength/2:10:striplength/2-5]) {
			translate([i,tickcylinder+tickcylinder_overlap,0])
			cylinder(r=tickcylinder,h=theight, $fn=64);
		} // end for

	} // end union



// 23/8/18  No, don't add markers - it disrupts the printing too much (except maybe in Black)
// add markers

//	for(i= [5-striplength/2:40:striplength/2-5]) {
//		translate([i,3,theight])
//		rotate([90,0,0])
//		cylinder(r=0.5,h=theight, $fn=64);
//	} // end for


//} // end difference