#!usr/local/bin/perl

use strict;
use warnings;
use Getopt::Long;
use Data::Dumper;
use Pod::Usage;
use vars qw/@RaceTrack %STATE $map_file/;

my $CRASH_COUNT=0;
my $COUNT_ROUND=1;
my $F = 0;	# Counter for time trial and Finish-Variable

my @modes = qw/ car1 player/;      # liste aller heuristik subroutinen

pod2usage(-verbose => 0)
    unless GetOptions(
      "racer:s" => sub { my @racers =split(",", $_[1]);
			 foreach my $l (@racers) {
			   my $m_check = 0;
			   my @racer = split (":", $l);
			   foreach my $o (@modes) {
			     $m_check = '1' if ($o eq $racer[1]);
			   }
			   unless ($m_check == 1) {
			     print "$racer[0]: Please use valid mode! (e.g. player)\n";
			     exit;
			   }
			   $STATE{$racer[0]}->{'mode'}="$racer[1]";
			   $STATE{$racer[0]}->{'position'}=[undef];
			   $STATE{$racer[0]}->{'speed'}=[0, 0];
			   $STATE{$racer[0]}->{'aussetzer'}='0';
			 }
      },
      "modes"   => sub{ print "@modes\n"; exit; },
      "track=s" => sub{ $map_file = $_[1] },
      "help|?"  => sub{pod2usage(-verbose => 1)},
      "man"     => sub{pod2usage(-verbose => 2)}
    );


# Assigns random generated or user-favored racetrack
@RaceTrack = &readin_racetrack();

%STATE = &set_start(\@RaceTrack, \%STATE);

while ($F == 0) {

  printf ("\n+----------+\n|RUNDE: %3d|\n+----------+\n", $COUNT_ROUND);
  $COUNT_ROUND++;
  
  foreach my $player (keys %STATE) {
    
    if ($STATE{$player}{'mode'} eq 'car1') {
      %STATE=&car1($player, %STATE);
    }
    elsif ($STATE{$player}{'mode'} eq 'player') {
      %STATE=&player($player, %STATE);
    }
  }

  $F = &check_Finish(\@RaceTrack, \%STATE);
  %STATE = &check_collision(%STATE);  
  
  
  $F=1, print "No winner after $COUNT_ROUND rounds!!\n" if ($COUNT_ROUND == 50);
}


#--------Steuerungs-Subroutines --------#

sub car1 { 			# Cheater Subroutine, finishes within the First round!
  my $name = shift;
  my %daten = @_;
  @{$daten{$name}{position}}=(0, 46);
 return %daten;
}

sub player {                    #subroutine zum haendischen steuern des autos, um gegen den Computer anzutreten
  my $name = shift;
  my %daten = @_;
  my @streckenbild = @RaceTrack;
  my ($px_alt, $py_alt) = @{$daten{$name}{'position'}};
  my ($vx_alt, $vy_alt) = @{$daten{$name}{'speed'}};
  my $status = $daten{$name}{'aussetzer'};
  my @moeglichkeiten = ();
  my ($sp_x, $sp_y) = ($px_alt + $vx_alt, $py_alt + $vy_alt);
  
  if ($status == 1) {                    #schaut ob man diese runde aussetzen muss weil man die wand traf
    @{$daten{$name}{speed}} = (0, 0);
    $daten{$name}{aussetzer} = '0';
    print "$name ist in eine Wand gecrasht und muss aussetzen\a\n";
    return %daten;
  }
  elsif ($status == 2) {                 #schaut ob man diese runde aussetzen muss weil man mit auto collidierte
    $CRASH_COUNT++;
    @{$daten{$name}{speed}} = (0, 0);
    $daten{$name}{aussetzer} = '0';
    ${$daten{$name}{position}}[1]-=1 if ($CRASH_COUNT % 2);
    print "$name ist mit anderem auto collidiert und muss aussetzen!\n";
    return %daten;
  }
  
  #berechnet alle erreichbaren felder und schaut ob sie auf der strecke liegen
  foreach my $n ([$sp_x-1, $sp_y-1],[$sp_x-1, $sp_y],[$sp_x-1, $sp_y+1],[$sp_x, $sp_y-1],[$sp_x, $sp_y],[$sp_x, $sp_y+1],[$sp_x+1, $sp_y-1],[$sp_x+1, $sp_y],[$sp_x+1, $sp_y+1]) {
    if ($streckenbild[${$n}[0]][${$n}[1]]) {
      push (@moeglichkeiten, [@{$n}]);
    }
  }
  
  unless (@moeglichkeiten) {            #checkt ob man die naechste runde aussetzen muss
    $daten{$name}{aussetzer} = '1';
    return(%daten);
  }

  #gibt info an STDOUT aus
  print "\n$name:\naktuelle position:\t[$px_alt, $py_alt]\naktuelle geschwindig.:\t[$vx_alt, $vy_alt]\n";
  print "moegliche zuege:\n";
  foreach (0 .. $#moeglichkeiten) {
    print "($_)\t@{$moeglichkeiten[$_]}\n";
  }
  print "\nBitte waehlen Sie ihre neue Position (0 bis 8): ";

  my $wahl = <STDIN>;
  my ($px_neu, $py_neu) = @{$moeglichkeiten[$wahl]};          #uebergibt neue position
  my ($vx_neu, $vy_neu) = ($px_neu-$px_alt, $py_neu-$py_alt); #berechnet und uebergibt neue geschwindigkeit
  
  #update von %STATE mit neuer position und geschwindigkeit
  @{$daten{$name}{position}}=($px_neu, $py_neu);
  @{$daten{$name}{speed}}=($vx_neu, $vy_neu);
  
  return %daten;
}


#------------- Subroutines -------------#

sub readin_racetrack {
  unless ($map_file) {
    my $status = system("java -jar  ./RennstreckenGenerator.jar");
    if (($status >>=8) !=0) {
      die "WARNING: Failed to run the Track Generator!\a\n";
  }
    $map_file="Racetrack.txt";
  }
  my @track;
  
  open MAP, "< $map_file" or die "WARNING: can not find/open $map_file!\a\n";
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
  my @track = @{shift()};
  my %state = %{shift()};
  my $l=0;
  
  # Checks if a player that reached line 0 moved to a valid position
  foreach my $racer (keys %state) { 
    if ($state{$racer}->{'position'}->[0] == 0 && $track[0]->[$state{$racer}->{'position'}->[1]] == 1) {
      print "The glorious $racer finished the race\n";
      $l = 1;
    }
  }
  
  return 0 unless ($l == 1);
}

sub check_collision{
  #schaut ob es zu collisionen zw. autos kam
  
  my %data = @_;
  
  foreach my $fahrer (keys %data) {                                       #vergleicht die position jeden fahrers mit ..
    my $urteil=0;
    my ($meine_pos_x, $meine_pos_y) = @{$data{$fahrer}{'position'}};
    foreach my $gegner (keys %data) {                                     #allen anderen positionen
      my ($gegner_pos_x, $gegner_pos_y) = @{$data{$gegner}{'position'}};
      $urteil++ if ( ($gegner_pos_x == $meine_pos_x) && ($gegner_pos_y == $meine_pos_y) );
    }
    if ($urteil >= 2) {          #da position(fahrer1) mit position(fahrer1) immer ident => collision erst wenn 2 mal gleiche position auf tritt
      @{$data{$fahrer}{'speed'}}=(0,0);
      $data{$fahrer}{'aussetzer'}=2;
    }
  }
  
  return %data;
}

__END__

    
=pod

=head1 NAME

SchoolBenchRacer.pl - old school racing game

=head1 SYNOPSIS

SBR.pl [[-racer I<STRING>] [-modes] [-help|?] [-man]]

=over 4

=item B<-racer>

Names of the racers separated by ":" from the mode used (q.v. -mode); each racer:mode pair is separated by "," from the next. S<C<Example: SBR.pl -racer foo:car1,bar:car2>>

=item B<-track>

Option to play on a handmade trackfile. S<C<Example: -track FavoriteTrack.txt>>

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
