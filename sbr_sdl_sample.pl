#!/usr/bin/perl

use strict;
use warnings;

use SDL;
use SDL::App;
use SDL::Surface;
use SDL::Cursor;
use SDL::Event;
use SDL::Mixer;
use SDL::Sound;
use SDL::TTFont;
use Data::Dumper;

# usage: perl sbr_sdl_map.pl [use esc button to close]

#crating sample array
my @racetrack = ([0,1,1,1,1,0,0,0],[0,0,1,1,1,1,0,0],[0,0,0,0,1,1,1,0],[0,0,0,1,1,1,0,0],[0,0,1,1,1,0,0,0],[0,0,0,1,1,0,0,0]);
my $rt_hight = @racetrack;
my $rt_with = @{$racetrack[0]};
#calculating grid size
my $grid_x = int(800 / $rt_with);
my $grid_y = int(600 / $rt_hight);

my %daten = (
'hansi', {'mode' => 'player','position' => [0,4],'speed' => [0,0],'aussetzer' => '0'},
'kitt', {'mode' => 'car1','position' => [0,3],'speed' => [0,0],'aussetzer' => '0'},
);
my %daten_alt;
old_data();
sub old_data {
  foreach my $name (keys %daten){
    my ($py_new, $px_new) = @{$daten{$name}{position}};
    @{$daten_alt{$name}{position}}=($py_new, $px_new);
  }
}
#print Dumper %daten;
sub change_daten {

  my ($px_neu,$py_neu);
  my $name = 'hansi';
  my ($py_alt, $px_alt) = @{$daten{$name}{position}};
  $px_neu = $px_alt;
  $py_neu = $py_alt + 1;
  if($py_neu < $rt_hight){

    #print $py_neu."\n";
    @{$daten{$name}{position}}=($py_neu, $px_neu);
  }
}

sub track_cars {

  foreach my $name (keys %daten){
    #my $name = 'hansi';

    my ($py_new, $px_new) = @{$daten{$name}{position}};
    my ($py_alt, $px_alt) = @{$daten_alt{$name}{position}};
    #print $py_new.":".$px_new." : ".$py_alt.":".$px_alt."\n";
    if ($py_new != $py_alt || $px_new != $px_alt){
      my $px_new_draw = $px_new * $grid_x;
      my $py_new_draw = $py_new * $grid_y;
      my $px_alt_draw = $px_alt * $grid_x;
      my $py_alt_draw = $py_alt * $grid_y;
      my $map_pos_alt = $racetrack[$py_alt][$px_alt];
      @{$daten_alt{$name}{position}}=($py_new, $px_new);

      draw_cars($px_new_draw,$py_new_draw,$name);
      overdraw_cars($px_alt_draw,$py_alt_draw,$name,$map_pos_alt,$px_alt,$py_alt);

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
      my $map_pos = $racetrack[$i][$j];
      if ($map_pos == 1){
        draw_map($pos_x,$pos_y,1);
      } elsif ($map_pos == 0){
          draw_map($pos_x,$pos_y,0);
        }

    }
  }
}

my $app = new SDL::App(
        -title=>'SchoolBenchRacer',
        -width=>800,
        -height=>600,
        -depth=>32,
        #-flags=>SDL_DOUBLEBUF | SDL_HWSURFACE | SDL_HWACCEL,
);

my $mixer = new SDL::Mixer(-frequency=>44100, -channels=>2, -size=>1024);

track_map();
event_loop();

sub event_loop {
    my $event = new SDL::Event;

  MAIN_LOOP:
    while(1) {
        while ($event->poll) {
            my $type = $event->type();

            last MAIN_LOOP if ($type == SDL_QUIT);
            last MAIN_LOOP if ($type == SDL_KEYDOWN && $event->key_name() eq 'escape');

        }
        track_cars();
        change_daten();
        $app->delay(500);
    }
}

#draw racetrack

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
        $carfont->print($app, $gridpos_x + $grid_x, $gridpos_y + $grid_y, $cartext);

        $app->update( $cargrid );

        $app->sync();
  }

  sub overdraw_cars {
        my ($gridpos_x,$gridpos_y,$nn,$map_pos_alt,$px_alt_text,$py_alt_text) = @_;
        $px_alt_text = $px_alt_text + 1;
        $py_alt_text = $py_alt_text + 1;
        my $map_pos_alt_text = $racetrack[$py_alt_text][$px_alt_text];
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