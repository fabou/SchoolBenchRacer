#!usr/local/bin/perl

use strict;
use warnings;
use Data::Dumper;


my @RaceTrack = readin_textfile();
   print Dumper(@RaceTrack);


#my %StateUpdate = update();



#-------- Subroutines --------#

sub readin_textfile {
    my @track;
    while (<>) {
          next if ($_ =~ /\# /);
          my @line = split(/\D/,$_);
          push(@track, [@line]);
    }
 return @track;
}
