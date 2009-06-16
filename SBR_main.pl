#!usr/local/bin/perl

use strict;
use warnings;
use Data::Dumper;
use vars qw/@RaceTrack %STATE $L/;



@RaceTrack = readin_textfile();
#   print Dumper(@RaceTrack);




## ------------------------------------------
# Car-Subroutines must return their Position.

while ($L == 1) {

 $STATE{car} = car();
 $L = checkFinish(@{$STATE{car}}[0]);

}





sub car {
my $pos = shift();


return $pos;
}






#-------- Subroutines --------#

sub readin_textfile {
    my @track;
    while (<>) {
          next if /^\# /;
          push(@track, [split()]);
    }
 return @track;
}

sub checkFinish {
	my ($x, $y) = @_;
	$L = 1 if ($x == '1');
	}

sub start {
	my @st_pos;
	foreach my $k (0 .. $#{$RaceTrack}[-1]) {
		if (${$RaceTrack}[$k] == 1) {
			push(@st_pos, [ 
	
