#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: day15.pl
#
#        USAGE: ./day15.pl
#
#  DESCRIPTION: Day 15 - Making cookies
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Mark T. Johnson (mtj), markj@matzsoft.com
# ORGANIZATION: MATZ Software & Consulting
#      VERSION: 1.0
#      CREATED: 12/14/15 22:45:47
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use 5.010;

use List::Util qw( max );


my ( @names, %names );

while ( <DATA> ) {
    chomp;
    s/,//g;

    my @info = split;
    my ( $name, $capacity, $durability, $flavor, $texture, $calories )
        = @info[ 0, 2, 4, 6, 8, 10 ];

    substr $name, -1, 1, q{};
    push @names, $name;
    $names{$name} = {
        capacity   => $capacity,
        durability => $durability,
        flavor     => $flavor,
        texture    => $texture,
        calories   => $calories,
    };
}

my @scores = cookie_scores( 100, @names );

say max( map { $_->[0] } @scores );
say max( map { $_->[0] } grep { $_->[1] == 500 } @scores );



sub cookie_scores {
    my $remaining = shift;
    my $first     = shift;
    my @rest      = @_;

    if ( @rest > 0 ) {
        my @results;

        for my $quantity ( 0 .. $remaining ) {
            $names{$first}{quantity} = $quantity;
            push @results, cookie_scores( $remaining - $quantity, @rest );
        }

        return @results;
    }

    my $score    = 1;
    my $calories = 0;

    $names{$first}{quantity} = $remaining;
    for my $property ( qw( capacity durability flavor texture ) ) {
        my $prop_score = 0;

        for my $name ( @names ) {
            $prop_score += $names{$name}{quantity} * $names{$name}{$property};
        }

        $prop_score = 0 if $prop_score < 0;
        $score *= $prop_score;
    }

    for my $name ( @names ) {
        $calories += $names{$name}{quantity} * $names{$name}{calories};
    }

    return ( [ $score, $calories ] );
}



__END__
Frosting: capacity 4, durability -2, flavor 0, texture 0, calories 5
Candy: capacity 0, durability 5, flavor -1, texture 0, calories 8
Butterscotch: capacity -1, durability 0, flavor 5, texture 0, calories 6
Sugar: capacity 0, durability 0, flavor -2, texture 2, calories 1
