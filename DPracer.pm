# -*-Perl-*-
# Last changed Time-stamp: <2009-06-30 16:46:40 ivo>
package DPracer;
use Data::Dumper;
use Exporter;
use strict;
our @RaceTrack;
our @ISA = qw/Exporter/;
our @EXPORT = qw//;
our @EXPORT_OK = qw/DPracer/;
our $CRASH_COUNT=0;

use constant {
  Y    => 0,
  X    => 1,
  DIST => 2,
  VT   => 3,
};

sub DPracer {
  my $name = shift;
  my $daten = shift;
  @RaceTrack = @{shift()};
  my ($y, $x) = @{$daten->{$name}{'position'}};
  my ($vy, $vx) = @{$daten->{$name}{'speed'}};
  my $status = $daten->{$name}{'aussetzer'};

  if ($status == 1) { #schaut ob man diese runde aussetzen muss weil man die wand traf
    $daten->{$name}{speed} = [0, 0];
    $daten->{$name}{aussetzer} = 0;
    print "$name ist in eine Wand gecrasht und muss aussetzen\a\n";
#    $mixer->play_channel(-1, $carcrash_sound, 0);
    return $daten;
  }
  elsif ($status == 2) { #schaut ob man diese runde aussetzen muss weil man mit auto collidierte
    $CRASH_COUNT++;
    $daten->{$name}{speed} = [0, 0];
    $daten->{$name}{aussetzer} = 0;
#    ${$daten->{$name}{position}}[1] -=1 if ($CRASH_COUNT % 2);
    print "$name ist mit anderem auto collidiert und muss aussetzen!\n";
#    $mixer->play_channel(-1, $carcrash_sound, 0);
    return $daten;
  }
  elsif ($status == 3) { #schaut ob man eh schon im ziel ist
    return $daten;
  }

  my $path = dpRacer($y,$x,$vy,$vx);

  $daten->{$name}{position} = [@{$path->[1]}[0,1]];
  $daten->{$name}{speed} = [@{$path->[1]}[2,3]];

  return $daten;
}



# @RaceTrack = readin_RaceTrack();
#dpRacer(52, 14, 0, 0);
#dpRacer(15, 8, 0, 0);

sub dpRacer {
  my ($y, $x, $vy, $vx) = @_; # start position
  my @ret = order_track(\@RaceTrack);
  my @track = @{$ret[0]};
  my %track = %{$ret[1]};

  if (!exists $track{$y,$x}) {
    warn "current position $y,$x is outside track";
    return (0,0);
  }

  my $start = 0;
  while ($track[$start][0] != $y || $track[$start][1] != $x) {$start++}
  my $t = 0;
  $track[$start]->[VT]->{$vy,$vx} = $t;
  for my $p ($start .. $#track) {
    if (!defined($track[$p]->[VT])) {
      # print "unreachable: ", Dumper($track[$p]);
      next;
    }
    my %vtlist = %{$track[$p]->[VT]};
    my ($y, $x) = ($track[$p]->[Y], $track[$p]->[X]);

    foreach my $vt (keys %vtlist) {
      my $t = $vtlist{$vt};
      my ($vy, $vx) = split($;,$vt);
      for my $m ([0,1],[1,0],[0,-1],[-1,0],[0,0],[1,1],[1,-1],[-1,1], [-1,-1]) {
	my ($nvy, $nvx) = ($vy+$m->[Y], $vx+$m->[X]);
	my ($ny, $nx) = ($y-$nvy, $x+$nvx);
	$y=0 if $y<0;
	next unless exists $track{$ny,$nx}; # illegal move
	my $np = $track{$ny,$nx};
	$np->[VT]->{$nvy,$nvx} = $t+1
	  unless exists($np->[VT]->{$nvy,$nvx}) && $t+1>=$np->[VT]->{$nvy,$nvx};
      }
    }
  }
  #vis(@track);

  my $path = backtrack(\@track, \%track, $start);

  #print Dumper($path);
  return $path;
}

sub backtrack {
  my @track = @{shift()};
  my %track = %{shift()};
  my $start = shift;
  my @path = ();
  my $c=$#track;
  my ($bestT, $end, $v);
  while ($track[$c]->[Y]==0) {
    $c--,next unless defined $track[$c]->[VT];
    my ($bt, $bk) = mint($track[$c]->[VT]);
    if (!defined($bestT) || $bestT>$bt) {
      ($bestT, $end, $v) = ($bt, $c, $bk);
    }
    $c--;
  }

  my ($y, $x) = ($track[$end]->[Y],
		 $track[$end]->[X]); # point where we cross the finish
  my ($vy, $vx) = split($;,$v);      # speed at finish
  my $t = $bestT;
  push @path, [$y,$x,$vy,$vx];
  while ($y != $track[$start]->[Y] || $x != $track[$start]->[X]) {
    my ($py, $px) = ($y + $vy, $x - $vx);
    my %vt = %{$track{$py,$px}->[VT]};
    my $fail=1;
    foreach my $vp (keys %vt) {
      next unless $vt{$vp} == $t-1;
      my ($vpy,$vpx) = split($;,$vp);
      next unless abs($vy-$vpy)<=1 && abs($vx-$vpx)<=1;
      print "$py $px  -$vpy $vpx  $t\t", $py-$y, " ", $x-$px, "\n";
      ($y, $x) = ($py, $px);
      ($vy, $vx) = ($vpy, $vpx);
      $t--;
      unshift @path, [$y,$x,$vy,$vx];
      $fail = 0;
      last;
    }
    die "backtrack failed $y,$x, $vy,$vx" if $fail;
  }
  return \@path;
}

sub order_track {
  my @grid = @{shift()};

  my @track = ();  # will contain points sorted by distance from goal
  my %track = ();  # allows to index track points as $track{x,y}

  for my $y (0..$#grid) {
    for my $x (0..$#{$grid[0]}) {
      next unless $grid[$y][$x];
      push @track, [$y,$x, undef];
      $track{$y,$x} = $track[-1];
    }
  }
  # print Dumper(\%track);
  # add distance to goal in breadth first order
  my @stack = ();
  my $d=0;
  for my $p (@track) {
    last if $p->[0] > 0;
    $p->[2]=$d;
    push @stack, $p;
  }
  while (@stack) {
    $d++;
    my @next = ();
    while (my $p = pop @stack) {
      for my $m ([0,1],[1,0],[0,-1],[-1,0]) {
	my ($y, $x) = ($p->[Y]+$m->[Y], $p->[X]+$m->[X]);
	next if !exists $track{$y,$x} || defined($track{$y,$x}->[2]);
	$track{$y,$x}->[2] = $d;
	push @next, $track{$y,$x};
      }
    }
    @stack = @next;
  }
  @track = sort {$b->[2] <=> $a->[2] || $b->[0] <=> $a->[0]} @track;
  # print Dumper(\%track);
  return \@track, \%track;
}


sub readin_RaceTrack {
  my $map_file="MonacoTrack.txt";

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

sub vis {

  #gibt eine text datei namens STRECKE aus die nach jeder runde aktualisiert wird; hat noch einen bug irgendwo
  my @track = @_;
  my @strecke = @RaceTrack;
  my @bild=();

  foreach my $r (@strecke) {
    foreach (@$r) {
      $_ = '##' if $_==0;
    }
  }
  foreach (@track) {
    my ($y,$x,$d) = ($_->[0], $_->[1], $_->[2]);
    if (defined($_->[VT])) {
      my ($mt,$mk) = mint($_->[VT]);
      $mt=-1 if $mt > 10000000;
      $strecke[$y][$x] = sprintf("%02d", $mt);
    } else {
      $strecke[$y][$x] = "XX";
    }
  }
  foreach (@strecke) {
    my $zeile=join "", @{$_};
    push(@bild, $zeile);
  }

  open MAP, " >./STRECKE";
  foreach (@bild) {
    print MAP "$_\n";
  }
  close MAP;
}

sub mint {
  my %vt = %{shift()};
  my $mt = 999999999;
  my $mk;
  foreach my $k (keys %vt) {
    if ($vt{$k}<$mt) {
	$mk = $k; $mt = $vt{$k};
      }
    }
  return ($mt, $mk);
}
1;
