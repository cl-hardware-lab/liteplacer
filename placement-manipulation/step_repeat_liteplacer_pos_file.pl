#!/usr/bin/perl
#-
# SPDX-License-Identifier: BSD-2-Clause
#
# Copyright (c) 2018 Brian Jones
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#

# Step and repeat for PCB .pos file for Liteplacer pick and place
# Brian Jones  11/4/2018

# input file consists of component lines only (no headers, comments or similar), comma separated with fields in order:
# Reference,Value,Footprint,Xpos,Ypos,Rotation
# double and single quotes are stripped.
# References must consist of one or more [a-zA-Z_-] followed by one or more [0-9]

use strict;
use warnings;

# Conventions
# Rotation=0 is the CAD system PCB orientation used to generate the positions file
# The origin of the .pos file for the individual board is entered in @x_positions_list,@y_positions_list for each of the boards in an xy matrix
# width/height of the panel is measured with an individual PCB in its 0 rotation also having a 0 entry in @rotations_list
# ie if the PCBs were all same orientation as the input file one, then all rotations are 0, and width=x direction, height=y direction


# **** START parameters to edit ****


open (INFILE,'<','tiny_usb_hub.csv');
open (OUTFILE,'>','tiny_usb_hub.pos');

my $panel_rotation = 90;		# Placer 0 position from panel 0 position, in degrees ccw
my $panel_w = 147	;			# Panel width at 0 rotation
my $panel_h = 84	;			# Panel height at 0 rotation
my $x_num_repeats	= 5 ;		# Number of repeats in X direction
my $y_num_repeats	= 2 ;		# Number of repeats in y direction

# changes here are equivalent to editing each of @x_positions_list, @y_positions_list
my $panel_x_correction = 0;		# value added to all component x to correct for panel position inconsistencies
my $panel_y_correction = 0;		# value added to all component y to correct for panel position inconsistencies


# order of boards in a eg 4x by 2y array
#  -----------------
#  | 1 | 3 | 5 | 7 |
#  | 0 | 2 | 4 | 6 |
#  -----------------

# Rotation of each of the panel boards relative to the rotation of the individual board
my @rotations_list = (0,180,0,180,0,180,0,180,0,180);

# Offset of the position file origin of individual boards relative to panel bottom left
my @x_positions_list = (20,20,47,47,74,74,101,101,128,128);	# origin for PCB .pos file, relative to panel bottom left, mm
my @y_positions_list = (9.5,73.5,9.5,73.5,9.5,73.5,9.5,73.5,9.5,73.5);


# we can't allow duplicate references, so add a numeric offset to each, including the first one.
my $ref_increment = 10 ;
# eg
#  -------------------------
#  | C21 | C41 | C61 | C81 |
#  | C11 | C31 | C51 | C71 |
#  -------------------------



# **** END parameters to edit ****




# output header
print OUTFILE "Ref,Value,Footprint,X,Y,Rot\n";

while (<INFILE>) {
	print "$_";
	chop;
	$_ =~ s/"//g;
	$_ =~ s/'//g;
	
	my ($ref,$val,$footprint,$xpos,$ypos,$comp_rot) = split(',');

	my $boardindex = 0 ;
	
	for (my $x=0;$x<$x_num_repeats;$x++) {
		for (my $y=0;$y<$y_num_repeats;$y++) {
		
# Make new/additional references, which must be of the form letter(s)number(s)
			$ref =~ m/([A-Za-z_-]+)([0-9]+)/ ;
			my $letter = $1 ;
			my $number = $2 ;
			my $newnumber = $number + ($boardindex+1)*$ref_increment ;
			my $newref = "$letter$newnumber";

# correct positions and rotation within the panel
			my $newx ;
			my $newy ;
			my $comp_rot_wp = $comp_rot + $rotations_list[$boardindex] ;
			$comp_rot_wp = $comp_rot_wp >= 360 ? $comp_rot_wp-360 : $comp_rot_wp ;
			if ($rotations_list[$boardindex] == 0) {
				$newx = $xpos + $x_positions_list[$boardindex] ;
				$newy = $ypos + $y_positions_list[$boardindex] ;
			} elsif ($rotations_list[$boardindex] == 90) {
				$newx = $x_positions_list[$boardindex] - $ypos ;
				$newy = $y_positions_list[$boardindex] + $xpos ;
			} elsif ($rotations_list[$boardindex] == 180) {
				$newx = $x_positions_list[$boardindex] - $xpos ;
				$newy = $y_positions_list[$boardindex] - $ypos ;
			} elsif ($rotations_list[$boardindex] == 270) {
				$newx = $x_positions_list[$boardindex] + $ypos ;
				$newy = $y_positions_list[$boardindex] - $xpos ;
			} else {
				print "NR $rotations_list[$boardindex]\n";
			}
			
			$newx += $panel_x_correction;
			$newy += $panel_y_correction;

# Now correct for panel rotation
			my $panel_x ;
			my $panel_y ;
			my $comp_rot_final = $panel_rotation + $comp_rot_wp ;
			$comp_rot_final = $comp_rot_final >= 360 ? $comp_rot_final - 360 : $comp_rot_final ;
			$comp_rot_final = $comp_rot_final < 0 ? $comp_rot_final + 360 : $comp_rot_final ;		
			if ($panel_rotation == 0) {
				$panel_x = $newx ;
				$panel_y = $newy ;
			} elsif ($panel_rotation == 90) {
				$panel_x = $panel_h - $newy ;
				$panel_y = $newx ;
			} elsif ($panel_rotation == 180) {
				$panel_x = $panel_w - $newx ;
				$panel_y = $panel_h - $newy ;
			} elsif ($panel_rotation == 270) {
				$panel_x = $newx ;
				$panel_y = $panel_w - $newx ;
			} else {
				print "PR $panel_rotation\n" ;
			}
			print OUTFILE "$newref,$val,$footprint,$panel_x,$panel_y,$comp_rot_final\n";
			$boardindex++;
		} # end for y
	} # end for x
} # end while input lines

close OUTFILE;
close INFILE;


