#!usr/local/bin/perl -w

#use strict;
use warnings;
use Data::Dumper;
use Getopt::Long;
use Pod::Usage;
use vars qw/@RaceTrack %STATE $L $map_file/;

$L = 0;                            # wenn jemand das ziel erreich wird $L=1
my $c =0;                          # for testing purpose
my @modes = qw/ car1 player/;      # liste aller heuristik subroutinen

pod2usage(-verbose => 0)
    unless GetOptions(
      "racer:s" => sub { my @racers =split(",", $_[1]);
			 foreach my $l (@racers) {
			   my @racer = split (":", $l);
			   $STATE{$racer[0]}->{'mode'}="$racer[1]";
			 }
                       },
      "modes"   => sub{print "@modes\n";
		       exit;
		       },
      "track:s" => sub{ $map_file = $_[1] },
      "help|?"  => sub{pod2usage(-verbose => 1)},
      "man"     => sub{pod2usage(-verbose => 2)}
    );


#liest extern generierte Strecke nach dem Muster von racetrack.txt ein

@RaceTrack = readin_textfile();

&set_start();

while ($L == 0) {
  
  foreach (keys %STATE) {
    if ($STATE{$_}{'mode'} eq 'car1') {
      %STATE=&car1(%STATE);
    }
    if ($STATE{$_}{'mode'} eq 'player') {
      %STATE=&player(%STATE);
    }
        
  }
  
  $L = &check_Finish();
  &check_collision();
  
  $c++;                  # for testing purpose     
  $L=1 if ($c == 10);    # for testing purpose  
}


#--------Steuerungs-Subroutines --------#

sub car1 {
  my %daten = @_;
  print "car1\n";        # for testing purpose   

  return %daten;
}

sub player {
  my %daten = @_;
  print "player\n";     # for testing purpose
  
  return %daten;
}


#------------- Subroutines -------------#

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

sub set_start {
  #weist allen autos eine startposition zu
}

sub check_Finish {
  #checkt ob ein oder mehrere autos das ziel ereich haben
  return 0;
}

sub check_collision{
  #schaut ob es collisionen gab, zw. autos, bwz mit streckenrand
}

__END__
=pod

=head1 NAME

SchoolBenchRacer.pl - old school racing game

=head1 SYNOPSIS

SBR.pl [[-racer I<STRING>] [-track I<STRING>] [-modes] [-help|?] [-man]]

=over 4

=item B<-racer>

Names of the racers separated by ":" from the mode used (q.v. -mode); each racer:mode pair is separated by "," from the next. S<C<Example: SBR.pl -racer foo:car1,bar:car2>>

=item B<-track>

Location and name of the file containing the racing track; it should be a 2D Matrix where the useabel track is marked with a '1' and the surrounding is marked with a '0'

=item B<-modes>

Lists all modes available to navigate your car through the track.

=item B<-help>

Show synopsis.

=item B<-man>

Show man page.

=back

