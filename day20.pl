#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: day20.pl
#
#        USAGE: ./day20.pl  
#
#  DESCRIPTION: Day 20 - Sending infinite elves down an infinite road
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Mark T. Johnson (mtj), markj@matzsoft.com
# ORGANIZATION: MATZ Software & Consulting
#      VERSION: 1.0
#      CREATED: 12/20/15 18:14:50
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use 5.010;

use List::Util qw( sum );
use lib '/Users/markj/Development/ProjectEuler';
use Primes '10000000';


my $target = 29000000;
my $target1 = $target / 10;           # Remove the factor of 10 here.
my $target2 = $target;
my $bound = 3255840;

for ( my $house = 1; ; $house++ ) {
    if ( sum_of_factors( $house ) >= $target1 ) {
        say $house;
        last;
    }
}


my @houses;

for my $elf ( 1 .. $bound ) {
    for ( my $house = $elf; $house <= $bound; $house += $elf ) {
        $houses[$house] += $elf if $house <= 50 * $elf;
    }
}

for my $house ( 1 .. $bound ) {
    if ( defined $houses[$house] and 11 * $houses[$house] >= $target2 ) {
        say $house;
        last;
    }
}



sub sum_of_factors {
    my $n = shift;
    my @factors = Primes::prime_factors( $n );
    my $sum = 1;

    while ( my ( $p, $e ) = splice @factors, 0, 2 ) {
        my $factor = 1;

        $factor = 1 + $factor * $p for 1 .. $e;
        $sum *= $factor;
    }

    return $sum;
}
