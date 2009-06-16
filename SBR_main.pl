#!usr/local/bin/perl -w

use strict;
use warnings;
use Data::Dumper;
use Getopt::Long;
use Pod::Usage;
use vars qw/@RaceTrack %STATE $L $map_file/;

$L = 0;
my $c =0; # for testing purpose

pod2usage(-verbose => 0)
    unless GetOptions(
      "racer:s" => sub { %STATE=split(':', $_[1]) },
      "track:s" => sub { $map_file = $_[1] },
      "help|?"  => sub{pod2usage(-verbose => 1)},
      "man"     => sub{pod2usage(-verbose => 2)}
    );


#liest extern generierte Strecke nach dem Muster von racetrack.txt ein
#start felder sind alle felder in der untersten zeile die mit 1 markiert sind
#ziel felder sind alle felder der obersten zeile die mit 1 markiert sind
@RaceTrack = readin_textfile();

while ($L == 0) {

 $STATE{car} = car();
 $L = checkFinish(@{$STATE{car}}[0]);




 $c++;                  # for testing purpose     
 $L=1 if ($c == 10);  # for testing purpose  
}


#-------- Subroutines --------#

sub car {
  my $pos = shift();


  return $pos;
}


sub readin_textfile {
  my @track;
  open MAP, "<${map_file}" or die "WARNING: can not open the input racing track!\a\n";
  while (<MAP>) {
    next if /^\# /;
    push(@track, [split()]);
  }
  close MAP;
  return @track;
}

sub checkFinish {
  my ($x, $y) = @_;
  $L = 1 if ($x == '1');
}


=pod

=head1 NAME

SchoolBenchRacer.pl - old school racing game

=head1 SYNOPSIS

SBR.pl [[-racer I<STRING>] [-track I<STRING>] [-help|?] [-man]]

=over 4

=item B<-racer>

Names of the racers separated by ":" (in this stage also the names of the subroutines which lead the racer)

=item B<-track>

Location and name of the file containing the racing track; it should be a 2D Matrix where the useabel track is marked with a '1' and the surrounding is marked with a '0'

=item B<-help>

Show synopsis.

=item B<-man>

Show man page.

