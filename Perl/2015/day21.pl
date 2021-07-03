#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: day21.pl
#
#        USAGE: ./day21a.pl  
#
#  DESCRIPTION: Day 21 - Kill the boss with minimum expense
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: Having trouble with my solution, trying one from forum.
#       AUTHOR: Mark T. Johnson (mtj), markj@matzsoft.com
# ORGANIZATION: MATZ Software & Consulting
#      VERSION: 1.0
#      CREATED: 12/20/15 23:30:13
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use 5.010;

use POSIX;
use List::Util qw( min max sum first );


my ( @weapons, %weapons );
my ( @armor, %armor );
my ( @rings, %rings );

read_shop( \@weapons, \%weapons );
read_shop( \@armor, \%armor );
read_shop( \@rings, \%rings );

my $hit_points = 100;
my $boss_hit_points = read_boss();
my $boss_damage = read_boss();
my $boss_armor = read_boss();

my $cheapest_win = sum( map { $_->{cost} } values( %weapons ), values( %armor ), values( %rings ) );
my $dearest_loss = 0;

for my $weapon ( @weapons ) {
    for my $armor ( @armor ) {
        for my $ring1 ( @rings ) {
            for my $ring2 ( @rings ) {
                next if $ring1 eq $ring2;

                my @list = ( $weapons{$weapon}, $armor{$armor}, $rings{$ring1}, $rings{$ring2} );
                my $damage = sum( map { $_->{damage} } @list );
                my $armor = sum( map { $_->{armor} } @list );
                my $cost = sum( map { $_->{cost} } @list );
                my $death = ceil( $hit_points / max( $boss_damage - $armor, 1 ) );
                my $boss_death = ceil( $boss_hit_points / max( $damage - $boss_armor, 1 ) );
                
                if ( $boss_death <= $death ) {
                    $cheapest_win = min( $cheapest_win, $cost );
                } else {
                    $dearest_loss = max( $dearest_loss, $cost );
                }
            }
        }
    }
}

say $cheapest_win;
say $dearest_loss;



sub read_shop {
    my $array_ref = shift;
    my $hash_ref  = shift;

    while ( <DATA> ) {
        last if m/^$/;
        chomp;

        my ( $name, $cost, $damage, $armor ) = split;

        push @$array_ref, $name;
        $hash_ref->{$name}
            = { cost => $cost, damage => $damage, armor => $armor };
    }
}



sub read_boss {
    while ( <DATA> ) {
        chomp;

        my ( undef, $value ) = split /:\s+/;

        return $value;
    }
}



__END__
dagger      8   4   0
shortsword  10  5   0
warhammer   25  6   0
longsword   40  7   0
greataxe    74  8   0

leather     13  0   1
chainmail   31  0   2
splintmail  53  0   3
bandedmail  75  0   4
platemail   102 0   5
noarmor     0   0   0

damage1     25  1   0
damage2     50  2   0
damage3     100 3   0
defense1    20  0   1
defense2    40  0   2
defense3    80  0   3
noring1     0   0   0
noring2     0   0   0

Hit Points: 104
Damage: 8
Armor: 1
