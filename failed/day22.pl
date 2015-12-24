#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: day22.pl
#
#        USAGE: ./day22.pl  
#
#  DESCRIPTION: Day 22 - RPG as a wizard
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: 1242 is too high
#       AUTHOR: Mark T. Johnson (mtj), markj@matzsoft.com
# ORGANIZATION: MATZ Software & Consulting
#      VERSION: 1.0
#      CREATED: 12/21/15 21:12:10
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use 5.010;

use List::Util qw( max );


my @spells = (
    { name => 'Magic Missle', cost => 53,  damage   => 4 },
    { name => 'Drain',        cost => 73,  damage   => 2, heal => 2 },
    { name => 'Shield',       cost => 113, armor    => 7, duration => 6 },
    { name => 'Poison',       cost => 173, damage   => 3, duration => 6 },
    { name => 'Recharge',     cost => 229, duration => 5, mana => 101 },
);
my %spells = map { $_->{name} => $_ } @spells;
my @timers = map { $_->{name} } grep { exists $_->{duration} } @spells;
my %timers = map { $_ => 0 } @timers;

my ( $initial_hit_points, $initial_mana, $initial_armor ) = ( 50, 500, 0 );
my ( $boss_initial_hit_points, $boss_damage ) = ( 51, 9 );

my ( $hit_points, $mana, $armor ) = ( $initial_hit_points, $initial_mana, $initial_armor );
my $boss_hit_points = $boss_initial_hit_points;
my $spent = 0;

while ( 1 ) {
    if ( $hit_points <= 0 ) {
        say "Loser spent $spent";
        last;
    }

    say "-- Player's turn --";
    dump_stats();
    implement_effects();
    players_move();
    say q{};

    say "-- Boss's turn --";
    dump_stats();
    implement_effects();

    if ( $boss_hit_points <= 0 ) {
        say "Winnner spent $spent";
        last;
    }

    # Boss action here
    $hit_points -= max( $boss_damage - $armor, 1 );
    say "Boss attacks for ", $boss_damage - $armor, " damage";
    say q{};
}



sub dump_stats {
    say "- Player has $hit_points hit points, $armor armor, $mana mana";
    say "- Boss has $boss_hit_points hit points";
}



sub implement_effects {
    for my $timer ( grep { $timers{$_} > 0 } @timers ) {
        $timers{$timer}--;
        say "$timer timer is at $timers{$timer}";
        given ( $timer ) {
            when ( 'Shield' ) {
                $armor -= $spells{$timer}{armor} if $timers{$timer} == 0;
            }

            when ( 'Poison' ) {
                $boss_hit_points -= $spells{$timer}{damage};
            }

            when ( 'Recharge' ) {
                $mana += $spells{$timer}{mana};
            }

            default {
                die "Unknown effect $timer\n";
            }
        }
    }
}



sub players_move {
    if ( $timers{Shield} == 0 and $hit_points > 38 ) {
        if ( $spells{Shield}{cost} + $spells{Recharge}{cost} < $mana ) {
            cast( 'Shield' );
        } else {
            cast( 'Recharge' );
        }

    } elsif ( $timers{Recharge} == 0 and $hit_points > 38 ) {
        cast( 'Recharge' );

    } elsif ( $timers{Poison} == 0 and $hit_points > 38 ) {
        cast( 'Poison' );

    } else {
        cast( 'Magic Missle' );
    }
}



sub cast {
    my $spell = shift;

    exists $spells{$spell} or die "Unknown spell $spell cast.\n";
    $spells{$spell}{cost} < $mana or die "Can't afford to cast $spell.\n";

    say "Player casts $spell";
    $mana -= $spells{$spell}{cost};
    $spent += $spells{$spell}{cost};

    given ( $spell ) {
        when ( 'Magic Missle' ) {
            $boss_hit_points -= $spells{$spell}{damage};
        }

        when ( 'Drain' ) {
            $boss_hit_points -= $spells{$spell}{damage};
            $hit_points += $spells{$spell}{heal};
        }

        when ( 'Shield' ) {
            $armor += $spells{$spell}{armor};
            $timers{$spell} = $spells{$spell}{duration};
        }

        when ( 'Poison' ) {
            $timers{$spell} = $spells{$spell}{duration};
        }

        when ( 'Recharge' ) {
            $timers{$spell} = $spells{$spell}{duration};
        }

        default {
            die "Unknown spell $spell cast.\n";
        }
    }
}



__END__
Hit Points: 51
Damage: 9
