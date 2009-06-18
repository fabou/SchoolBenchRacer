#!usr/local/bin/perl -w

# perl SBR_main.pl -racer Name:player -track racetrack.txt

use strict;
use warnings;
use Data::Dumper;
use Getopt::Long;
use Pod::Usage;
use vars qw/@RaceTrack %STATE $map_file $L/;

$L = 0;                            # wenn jemand das ziel erreich wird $L=1
my $c =0;                          # for testing purpose
my @modes = qw/ car1 player/;      # liste aller heuristik subroutinen

pod2usage(-verbose => 0)
    unless GetOptions(
      "racer:s" => sub { my @racers =split(",", $_[1]);
			 foreach my $l (@racers) {
			   my @racer = split (":", $l);
			   $STATE{$racer[0]}->{'mode'}="$racer[1]";
			   $STATE{$racer[0]}->{'position'}=[undef];
			   $STATE{$racer[0]}->{'speed'}=[0, 0];
			   $STATE{$racer[0]}->{'aussetzer'}='0';
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

%STATE = set_start(\@RaceTrack, \%STATE);
print Dumper(%STATE);

while ($L == 0) {
  
  foreach my $l (keys %STATE) {
    if ($STATE{$l}{'mode'} eq 'car1') {
      %STATE=&car1($l, %STATE);
    }
    if ($STATE{$l}{'mode'} eq 'player') {
      %STATE=&player($l, %STATE);
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
  print "car1\n";        # only for testing purpose   
  
  return %daten;
}

sub player {                    #subroutine zum haendischen steuern des autos, um gegen den Computer anzutreten
  my $name = shift;
  my %daten = @_;
  my @streckenbild = @RaceTrack;
  my ($px_alt, $py_alt) = @{$daten{$name}{position}};
  my ($vx_alt, $vy_alt) = @{$daten{$name}{speed}};
  my $status = $daten{$name}{aussetzer};
  my @moeglichkeiten = ();
  my ($sp_x, $sp_y) = ($px_alt + $vx_alt, $py_alt + $vy_alt);
  
  if ($status == 1) {                    #schaut ob man diese runde aussetzen muss
    @{$daten{$name}{speed}} = (0, 0);
    $daten{$name}{aussetzer} = '0';
    return %daten;
  }
  
  

  foreach my $n ([$sp_x-1, $sp_y-1],[$sp_x-1, $sp_y],[$sp_x-1, $sp_y+1],[$sp_x, $sp_y-1],[$sp_x, $sp_y],[$sp_x, $sp_y+1],[$sp_x+1, $sp_y-1],[$sp_x+1, $sp_y],[$sp_x+1, $sp_y+1]) {
    if ($streckenbild[${$n}[0]][${$n}[1]]) {
      push (@moeglichkeiten, [@{$n}]);
    }
  }
  
  unless (@moeglichkeiten) {            #checkt ob man die naechste runde aussetzen muss
    $daten{$name}{aussetzer} = '1';
    return(%daten);
  }
  
  print "\n$name:\naktuelle position:\t[$px_alt, $py_alt]\naktuelle geschwindig.:\t[$vx_alt, $vy_alt]\n";
  print "moegliche zuege:\n";
  foreach (0 .. $#moeglichkeiten) {
    print "($_)\t@{$moeglichkeiten[$_]}\n";
  }
  print "\nBitte waehlen Sie ihre neue Position (0 bis 8): ";
  my $wahl = <STDIN>;

  my ($px_neu, $py_neu) = @{$moeglichkeiten[$wahl]};
  my ($vx_neu, $vy_neu) = ($px_neu-$px_alt, $py_neu-$py_alt);
  
  @{$daten{$name}{position}}=($px_neu, $py_neu);
  @{$daten{$name}{speed}}=($vx_neu, $vy_neu);
  
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
    my @track = @{shift()};
    my %state = %{shift()};
    my $height = $#track;
    my @starts;

	# Reads Starting Positions in @starts
    my $count=0;
    foreach (@{$track[$height]}) {
       if ($_ eq 1) {
	  push(@starts, $count);
       }
       $count++
    }

	# Shuffles Starting Positions
    foreach (my $pos=$#starts; $pos>0; $pos--) {
       my $ran = int(rand($pos));
       if ($starts[$pos] ne $starts[$ran]) {
          @starts[$pos, $ran]=@starts[$ran, $pos];
       }
    }

	# Assigns Starting Positions
    foreach my $racer (keys %state) { 
       if (defined($state{'position'})) {
          print "Somethig is wrong!\n";
       } else { 
          my $pos = pop(@starts);
	  $state{$racer}->{'position'}=[$height, $pos];
       }
    }
 return %state;
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

=head1 STEUERSUBROUTINEN

=over 4

=item I<player>

Keine KI sondern nur zum selber gegen den Computer zu spielen gedacht.

    =cut
