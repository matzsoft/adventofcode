#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: day21.pl
#
#        USAGE: ./day21.pl  
#
#  DESCRIPTION: Day 21 - Kill the boss with minimum expense
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
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


my %weapons = (
    dagger     => { cost => 8,  damage => 4, armor => 0 },
    shortsword => { cost => 10, damage => 5, armor => 0 },
    warhammer  => { cost => 25, damage => 6, armor => 0 },
    longsword  => { cost => 40, damage => 7, armor => 0 },
    greataxe   => { cost => 74, damage => 8, armor => 0 },
);
my %armor = (
    leather    => { cost => 13,  damage => 0, armor => 1 },
    chainmail  => { cost => 31,  damage => 0, armor => 2 },
    splintmail => { cost => 53,  damage => 0, armor => 3 },
    bandedmail => { cost => 75,  damage => 0, armor => 4 },
    platemail  => { cost => 102, damage => 0, armor => 5 },
);
my %rings = (
    damage1  => { cost => 25,  damage => 1, armor => 0 },
    damage2  => { cost => 50,  damage => 2, armor => 0 },
    damage3  => { cost => 100, damage => 3, armor => 0 },
    defense1 => { cost => 20,  damage => 0, armor => 1 },
    defense2 => { cost => 40,  damage => 0, armor => 2 },
    defense3 => { cost => 80,  damage => 0, armor => 3 },
);

my @weapons = sort { $weapons{$a}{damage} <=> $weapons{$b}{damage} } keys %weapons;
my @armor = sort { $armor{$a}{armor} <=> $armor{$b}{armor} } keys %armor;
my @offensive_rings = sort { $rings{$a}{damage} <=> $rings{$b}{damage} } grep { $rings{$_}{damage} > 0 } keys %rings;
my @defensive_rings = sort { $rings{$a}{armor} <=> $rings{$b}{armor} } grep { $rings{$_}{armor} > 0 } keys %rings;
my %offensive_combos;
my %defensive_combos;

my $hit_points = 100;
my $boss_hit_points = 104;
my $boss_damage = 8;
my $boss_armor = 1;
my $answer = 500;

for my $damage ( 1 .. $boss_damage ) {
    my $armor = $boss_damage - $damage;
    my $cost = cheapest_armor( $armor );
    my $death = ceil( $hit_points / $damage );
    my $needed = ceil( $boss_hit_points / $death );

    $cost += cheapest_damage( $needed + $boss_armor );
    $answer = min( $answer, $cost );
    say "$damage = $cost";
}

say $answer;


$answer = 0;

for my $i ( 0 .. $#offensive_rings ) {
    for my $j ( $i + 1 .. $#offensive_rings ) {
        my $damage = sum( map { $rings{ $offensive_rings[$_] }{damage} } $i, $j );

        push @{ $offensive_combos{$damage} }, [ @offensive_rings[ $i, $j ] ];
    }
}

for my $i ( 0 .. $#defensive_rings ) {
    for my $j ( $i + 1 .. $#defensive_rings ) {
        my $armor = sum( map { $rings{ $defensive_rings[$_] }{armor} } $i, $j );

        push @{ $defensive_combos{$armor} }, [ @defensive_rings[ $i, $j ] ];
    }
}

for my $damage ( 1 .. $boss_damage ) {
    my $armor = $boss_damage - $damage;
    my @armor_cost = dearest_armor( $armor );
    my $death = ceil( $hit_points / $damage );
    my $needed = floor( $boss_hit_points / ( $death + 1 ) );
    my @damage_cost = dearest_damage( $needed + $boss_armor );
    my $cost = 0;

    for my $i ( 0 .. $#armor_cost ) {
        for my $j ( 0 .. $#damage_cost - $i ) {
            if ( $damage_cost[$j] > 0 ) {
                $cost = max( $cost, $armor_cost[$i] + $damage_cost[$j] );
            }
        }
    }

    $answer = max( $answer, $cost );
    say "$damage = ( ", join( q{, }, @armor_cost ), " )( ", join( q{, }, @damage_cost ), " ) = $cost";
}

say $answer;



sub cheapest_armor {
    my $amount = shift;
    my $answer = 500;

    return 0 if $amount == 0;

    for my $armor ( @armor ) {
        my $needed = $amount - $armor{$armor}{armor};
        my $cost = $armor{$armor}{cost};

        if ( $needed > 0 ) {
            my $ring = first { $rings{$_}{armor} == $needed } @defensive_rings;

            next if not defined $ring;

            $cost += $rings{$ring}{cost};
        }

        $answer = min( $answer, $cost );
    }

    return $answer;
}



sub cheapest_damage {
    my $amount = shift;
    my $answer = 500;

    return 0 if $amount == 0;

    for my $weapon ( @weapons ) {
        my $needed = $amount - $weapons{$weapon}{damage};

        my $cost = $weapons{$weapon}{cost};

        if ( $needed > 0 ) {
            my $ring = first { $rings{$_}{damage} == $needed } @offensive_rings;

            next if not defined $ring;

            $cost += $rings{$ring}{cost};
        }

        $answer = min( $answer, $cost );
    }

    return $answer;
}



sub dearest_armor {
    my $amount = shift;
    my @answer = ( 0, 0, 0 );

    return @answer if $amount == 0;

    my $norings = first { $armor{$_}{armor} == $amount } @armor;

    $answer[0] = $armor{$norings}{cost} if defined $norings;

    for my $armor ( grep { $armor{$_}{armor} < $amount } @armor ) {
        my $needed = $amount - $armor{$armor}{armor};
        my $ring = first { $rings{$_}{armor} == $needed } @defensive_rings;

        if ( defined $ring ) {
            my $cost = $armor{$armor}{cost} + $rings{$ring}{cost};

            $answer[1] = max( $answer[1], $cost );
        }
    }

    for my $armor ( grep { $armor{$_}{armor} < $amount - 1 } @armor ) {
        my $needed = $amount - $armor{$armor}{armor};
        my $combos = $defensive_combos{$needed};
        my @combos = defined $combos ? @$combos : [];
        my $cost   = $armor{$armor}{cost};

        for my $combo ( @combos ) {
            my $total_cost = sum( $cost, map { $rings{$_}{cost} } @$combo );

            $answer[2] = max( $answer[2], $total_cost );
        }
    }

    return @answer;
}



sub dearest_damage {
    my $amount = shift;
    my @answer = ( 0, 0, 0 );

    return @answer if $amount == 0;

    my $norings = first { $weapons{$_}{damage} == $amount } @weapons;

    $answer[0] = $weapons{$norings}{cost} if defined $norings;

    for my $ring ( grep { $rings{$_}{damage} <= $amount } @offensive_rings ) {
        my $needed = $amount - $rings{$ring}{damage};
        my $weapon = first { $weapons{$_}{damage} <= $needed } reverse @weapons;

        if ( defined $weapon ) {
            my $cost = $weapons{$weapon}{cost} + $rings{$ring}{cost};

            $answer[1] = max( $answer[1], $cost );
        }
    }

    for my $combos_amt ( grep { $_ <= $amount } keys %offensive_combos ) {
        my $needed = $amount - $combos_amt;
        my $weapon = first { $weapons{$_}{damage} <= $needed } reverse @weapons;

        if ( defined $weapon ) {
            my $cost = $weapons{$weapon}{cost};

            for my $combo ( @{ $offensive_combos{$combos_amt} } ) {
                my $total_cost = sum( $cost, map { $rings{$_}{cost} } @$combo );

                $answer[2] = max( $answer[2], $total_cost );
            }
        }
    }

    return @answer;
}



__END__
Hit Points: 104
Damage: 8
Armor: 1
