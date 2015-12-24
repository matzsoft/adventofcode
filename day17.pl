#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: day17.pl
#
#        USAGE: ./day17.pl  
#
#  DESCRIPTION: Day 17 - Packaging eggnog for the frig.
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Mark T. Johnson (mtj), markj@matzsoft.com
# ORGANIZATION: MATZ Software & Consulting
#      VERSION: 1.0
#      CREATED: 12/16/15 23:59:13
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use 5.010;

use List::Util qw( min );


my $eggnog = 150;
my @containers;

while ( <DATA> ) {
    chomp;

    push @containers, $_;
}

my @solutions = find_solutions( 0, $eggnog, @containers );

say scalar( @solutions );

my $minimum = min @solutions;

say scalar( grep { $_ == $minimum } @solutions );



sub find_solutions {
    my $containers = shift;
    my $quantity   = shift;
    my $first      = shift;
    my @rest       = @_;

    if ( @rest == 0 ) {
        return $first == $quantity ? ( $containers + 1 ) : ();
    }

    if ( $first > $quantity ) {
        return find_solutions( $containers, $quantity, @rest );

    } elsif ( $first == $quantity ) {
        return ( $containers + 1,
            find_solutions( $containers, $quantity, @rest ) );

    } else {
        return (
            find_solutions( $containers + 1, $quantity - $first, @rest ),
            find_solutions( $containers,     $quantity,          @rest )
        );
    }
}



__END__
33
14
18
20
45
35
16
35
1
13
18
13
50
44
48
6
24
41
30
42
