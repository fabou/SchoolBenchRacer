#!usr/local/bin/perl

use strict;
use warnings;
use Getopt::Long;
use Data::Dumper;
use Pod::Usage;
use SDL;
use SDL::App;
use SDL::Surface;
use SDL::Cursor;
use SDL::Event;
use SDL::Mixer;
use SDL::Sound;
use SDL::TTFont;

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


# Assigns random generated or user-favored RaceTrack
@RaceTrack = &readin_RaceTrack();

my $rt_hight = @RaceTrack;
my $rt_with = @{$RaceTrack[0]};
#calculating grid size
my $grid_x = int(800 / $rt_with);
my $grid_y = int(600 / $rt_hight); 

my %daten_alt;
sub old_data {
  foreach my $name (keys %STATE){
    my ($py_new, $px_new) = @{$STATE{$name}{position}};
    @{$daten_alt{$name}{position}}=($py_new, $px_new);
  }
}

my $app = new SDL::App(
        -title=>'SchoolBenchRacer',
        -width=>800,
        -height=>600,
        -depth=>32,
        -flags=>SDL_DOUBLEBUF | SDL_HWSURFACE | SDL_HWACCEL,
);

my $mixer = new SDL::Mixer(-frequency=>44100, -channels=>2, -size=>1024);
my $car_sound = new SDL::Sound('Sounds/racecar.wav');
my $carcrash_sound = new SDL::Sound('Sounds/carcrash.wav');
my $car_start = new SDL::Sound('Sounds/start.wav');
my $car_crowd = new SDL::Sound('Sounds/crowd.wav');
$mixer->channel_volume(1, 30);
$mixer->play_channel(2, $car_start, 0);

track_map();

%STATE = &set_start(\@RaceTrack, \%STATE);
old_data();
while ($F == 0) {

  &vis(\@RaceTrack, \%STATE);
  
  printf ("\n+----------+\n|RUNDE: %3d|\n+----------+\n", $COUNT_ROUND);
  $COUNT_ROUND++;
  
  foreach my $player (keys %STATE) {
    track_cars();
    if ($STATE{$player}{'mode'} eq 'car1') {
      %STATE=&car1($player, %STATE);
    }
    elsif ($STATE{$player}{'mode'} eq 'player') {
      %STATE=&player($player, %STATE);
    }
  }

  $F = &check_Finish(\@RaceTrack, \%STATE);
  %STATE = &check_collision(%STATE);
  
  
  
  $F=1, print "No winner after $COUNT_ROUND rounds!!\n" if ($COUNT_ROUND == 88);
}


#--------Steuerungs-Subroutines --------#

sub car1 { 			# Cheater Subroutine, finishes within the First round!
  my $name = shift;
  my %daten = @_;
  @{$daten{$name}{position}}=(0, 46);
 return %daten;
}

sub player {
#subroutine zum haendischen steuern des autos, um gegen den Computer anzutreten
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
    $mixer->play_channel(-1, $carcrash_sound, 0);
    return %daten;
  }
  elsif ($status == 2) {                 #schaut ob man diese runde aussetzen muss weil man mit auto collidierte
    $CRASH_COUNT++;
    @{$daten{$name}{speed}} = (0, 0);
    $daten{$name}{aussetzer} = '0';
    ${$daten{$name}{position}}[1]-=1 if ($CRASH_COUNT % 2);
    print "$name ist mit anderem auto collidiert und muss aussetzen!\n";
    $mixer->play_channel(-1, $carcrash_sound, 0);
    return %daten;
  }
  
  #berechnet alle erreichbaren felder und schaut ob sie auf der strecke liegen
  foreach my $n ([$sp_x-1, $sp_y-1],[$sp_x-1, $sp_y],[$sp_x-1, $sp_y+1],[$sp_x, $sp_y-1],[$sp_x, $sp_y],[$sp_x, $sp_y+1],[$sp_x+1, $sp_y-1],[$sp_x+1, $sp_y],[$sp_x+1, $sp_y+1]) {
    ${$n}[0]=0 if (${$n}[0]<0);
    if ($streckenbild[${$n}[0]][${$n}[1]]) {
      push (@moeglichkeiten, [@{$n}]);
    }
  }
  
  unless (@moeglichkeiten) {            #checkt ob man die naechste runde aussetzen muss
    $daten{$name}{aussetzer} = '1';
    return(%daten);
  }
  #draw_next_pos($px_alt,$py_alt,$vx_alt,$vy_alt);
  #draw_next_pos(@moeglichkeiten);

  #gibt info an STDOUT aus
  print "\n$name:\naktuelle position:\t[$px_alt, $py_alt]\naktuelle geschwindig.:\t[$vx_alt, $vy_alt]\n";
  print "moegliche zuege:\n";
   foreach (0 .. $#moeglichkeiten) {
    my ( $relativ_x, $relativ_y) = (($px_alt - ${$moeglichkeiten[$_]}[0]), (${$moeglichkeiten[$_]}[1] -  $py_alt));
    print "($_)\t$relativ_x, $relativ_y \n";
  }
  print "\nBitte waehlen Sie ihre neue Position (0 bis 8): ";

  my $wahl = <STDIN>;
  my ($px_neu, $py_neu) = @{$moeglichkeiten[$wahl]};          #uebergibt neue position
  my ($vx_neu, $vy_neu) = ($px_neu-$px_alt, $py_neu-$py_alt); #berechnet und uebergibt neue geschwindigkeit
  my $vol_speed = abs($vx_neu) + abs($vy_neu);
  my $vol = 10 + $vol_speed * 15;
  if ($vol > 100){
    $vol = 100;
  }
  $mixer->channel_volume(1,$vol);
  $mixer->play_channel(1, $car_sound, 0);

  #update von %STATE mit neuer position und geschwindigkeit
  @{$daten{$name}{position}}=($px_neu, $py_neu);
  @{$daten{$name}{speed}}=($vx_neu, $vy_neu);
  
  return %daten;
}


#------------- Subroutines -------------#

sub readin_RaceTrack {
  unless ($map_file) {

    my $spielerzahl = (keys %STATE);
    my $status = system("java -jar  ./RennstreckenGenerator.jar $spielerzahl");
    if (($status >>=8) !=0) {
      die "WARNING: Failed to run the Track Generator!\a\n";
  }
    $map_file="Racetrack.txt";
  }
  my @track;
  
  open MAP, "< $map_file" or die "WARNING: can not find/open $map_file!\a\n";
  while (<MAP>) {
    next if /^\# /;
    next if /^\n/;
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
    $state{$racer}->{'position'}->[0] = 0 if ($state{$racer}->{'position'}->[0] < 0);   #setezt zeile auf null wenn man uebers ziel hinausschiesst
    if ($state{$racer}->{'position'}->[0] == 0 && $track[0]->[$state{$racer}->{'position'}->[1]] == 1) {
      $mixer->channel_volume(2,100);
      $mixer->play_channel(2, $car_crowd, 0);
      $app->delay(2000);
      printf ("\n\n+-+---------------------------------------+-+\n+ +---------------------------------------+ +\n| |The glorious %8s finished the race| |\n+ +---------------------------------------+ +\n+-+---------------------------------------+-+\n\n\n", $racer); # gibt den sieger formatiert aus
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
      $mixer->play_channel(-1, $carcrash_sound, 0);
    }
  }
  
  return %data;
}


sub vis {

  #gibt eine text datei namens STRECKE aus die nach jeder runde aktualisiert wird; hat noch einen bug irgendwo
  my @strecke = @{shift()};
  my %daten = %{shift()};
  my @bild=();      

  foreach (@strecke) {
    my $zeile=join "", @{$_};
    $zeile=~tr/01/\# /;
    push(@bild, $zeile);
  }

  my %position;
  
  foreach my $renner (keys %STATE) {
    my $init = substr($renner, 0, 1);
    my $x = ${$daten{$renner}{position}}[0];
    my $y = ${$daten{$renner}{position}}[1];
    substr($bild[$x], $y, 1, $init);
  }

  open MAP, " >./STRECKE";
  foreach (@bild) {
    print MAP "$_\n";
  }
  close MAP;
}
 
#SDL begin -----


sub track_cars {

  foreach my $name (keys %STATE){

    my ($py_new, $px_new) = @{$STATE{$name}{position}};
    my ($py_alt, $px_alt) = @{$daten_alt{$name}{position}};
    #print $py_new.":".$px_new." : ".$py_alt.":".$px_alt."\n";
    if ($py_new != $py_alt || $px_new != $px_alt){
      my $px_new_draw = $px_new * $grid_x;
      my $py_new_draw = $py_new * $grid_y;
      my $px_alt_draw = $px_alt * $grid_x;
      my $py_alt_draw = $py_alt * $grid_y;
      my $map_pos_alt = $RaceTrack[$py_alt][$px_alt];
      @{$daten_alt{$name}{position}}=($py_new, $px_new);

      overdraw_cars($px_alt_draw,$py_alt_draw,$name,$map_pos_alt,$px_alt,$py_alt);
      draw_cars($px_new_draw,$py_new_draw,$name);

    } elsif ($py_new == $py_alt && $px_new == $px_alt) {

        my $px_new_draw = $px_new * $grid_x;
        my $py_new_draw = $py_new * $grid_y;
        draw_cars($px_new_draw,$py_new_draw,$name);
      }

  }

}

#reads map array and calls draw function for each tile
sub track_map {
  my ($pos_y,$pos_x);
  for (my $i=0;$i < $rt_hight;$i++){
      my $pos_y = $i * $grid_y;
    for (my $j=0;$j < $rt_with;$j++){
      my $pos_x = $j * $grid_x;
      my $map_pos = $RaceTrack[$i][$j];
      if ($map_pos == 1){
        draw_map($pos_x,$pos_y,1);
      } elsif ($map_pos == 0){
          draw_map($pos_x,$pos_y,0);
        }

    }
  }
}

#draw RaceTrack

{
  my ($track,$trackgrid,$cargrid,$overcargrid,$overtextgrid,$terrain_text,$terrain);
  my ($trackcolor,$trackgridcolor,$bgcolor,$fgcolor,$car1color,$car2color,$car3color);
  my ($carpos_x,$cartext,$carfont,$overtextgrid_inner);

  sub config_map_screen {

        $trackgridcolor = new SDL::Color(-r=>192, -g=>192, -b=>192);#grey
        $trackcolor = new SDL::Color(-r=>160, -g=>160, -b=>160);#medgrey
        $car1color = new SDL::Color(-r=>128, -g=>0, -b=>0);#red
        $car2color = new SDL::Color(-r=>128, -g=>32, -b=>128);#violett
        $car3color = new SDL::Color(-r=>250, -g=>250, -b=>210);#yellow
        $bgcolor = new SDL::Color(-r=>0, -g=>128, -b=>32); # green
        $fgcolor = new SDL::Color(-r=>0, -g=>0, -b=>0); # black
        $carfont = new SDL::TTFont(-name=>"Fonts/Vera.ttf", -size=>12, -bg=>$trackcolor, -fg=>$fgcolor);
  }

  sub draw_map {
        my ($gridpos_x,$gridpos_y,$dest) = @_;
        config_map_screen();
        #print "vars:".$grid_x.":".$grid_y.":".$gridpos_x.":".$gridpos_y."\n";

        $trackgrid = new SDL::Rect(-width=>$grid_x, -height=>$grid_y,-x=>$gridpos_x, -y=>$gridpos_y);
        $track = new SDL::Rect(-width=>$grid_x - 2, -height=>$grid_y - 2,-x=>$gridpos_x + 1, -y=>$gridpos_y + 1);
        if ($dest == 1){
          $app->fill($trackgrid, $trackcolor);
          $app->fill($track, $trackgridcolor);
        } elsif ($dest == 0){
            $app->fill($trackgrid, $bgcolor);
          }
        $app->update( $trackgrid );
        #$app->sync();
  }

  sub draw_cars {
        my ($gridpos_x,$gridpos_y,$nn) = @_;
        config_map_screen();
        #print "vars:".$grid_x.":".$grid_y.":".$gridpos_x.":".$gridpos_y."\n";
        
        $cargrid = new SDL::Rect(-width=>$grid_x - 2, -height=>$grid_y - 2,-x=>$gridpos_x + 1, -y=>$gridpos_y + 1);
        $app->fill($cargrid, $car1color);

        $cartext = $nn;
        my $gy = $gridpos_y + $grid_y;
        if ($gy > 600){
          $gridpos_y = $gridpos_y - $grid_y;
        }
        $carfont->print($app, $gridpos_x + $grid_x, $gridpos_y + $grid_y, $cartext);

        $app->update( $cargrid );

        $app->sync();
  }

 sub draw_next_pos {
   my ($px_alt,$py_alt,$vx_alt,$vy_alt) = @_;
   my $m_pos_x = ($py_alt + $vy_alt) * $grid_x;
   my $m_pos_y = ($px_alt + $vx_alt) * $grid_y;
   my $posfont = new SDL::TTFont(-name=>"Fonts/Vera.ttf", -size=>14, -bg=>$trackcolor, -fg=>$fgcolor);
   my $postext = "T";
   $posfont->print($app, $m_pos_x + 2, $m_pos_y + 2, $postext);
   $app->sync();

 }

  sub overdraw_cars {
        my ($gridpos_x,$gridpos_y,$nn,$map_pos_alt,$px_alt_text,$py_alt_text) = @_;
        $px_alt_text = $px_alt_text + 1;
        $py_alt_text = $py_alt_text + 1;
        my $map_pos_alt_text = $RaceTrack[$py_alt_text][$px_alt_text];
        my $px_alt_draw = $px_alt_text * $grid_x;
        my $py_alt_draw = $py_alt_text * $grid_y;
        config_map_screen();
        #print "vars:".$grid_x.":".$grid_y.":".$gridpos_x.":".$gridpos_y."\n";
        if ($map_pos_alt == 0){
          $terrain = $bgcolor;
        } elsif ($map_pos_alt == 1){
            $terrain = $trackgridcolor;
          }

        $overcargrid = new SDL::Rect(-width=>$grid_x - 2, -height=>$grid_y - 2,-x=>$gridpos_x + 1, -y=>$gridpos_y + 1);
        $app->fill($overcargrid, $terrain);

        $overtextgrid = new SDL::Rect(-width=>$grid_x, -height=>$grid_y,-x=>$px_alt_draw, -y=>$py_alt_draw);
        $overtextgrid_inner = new SDL::Rect(-width=>$grid_x - 2, -height=>$grid_y - 2,-x=>$px_alt_draw + 1, -y=>$py_alt_draw + 1);

        if ($map_pos_alt_text == 0){
          $app->fill($overtextgrid, $bgcolor);
          $app->update( $overtextgrid );
        } elsif ($map_pos_alt_text == 1){
            $app->fill($overtextgrid, $trackcolor);
            $app->fill($overtextgrid_inner, $trackgridcolor);
            $app->update( $overtextgrid );
            $app->update( $overtextgrid_inner );
          }

        $app->update( $overcargrid );
        #$app->update( $overtextgrid );
        #$app->sync();
  }
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
