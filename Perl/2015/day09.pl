#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: day09.pl
#
#        USAGE: ./day09.pl  
#
#  DESCRIPTION: Day 9 - Santa as travelling salesman
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Mark T. Johnson (mtj), markj@matzsoft.com
# ORGANIZATION: MATZ Software & Consulting
#      VERSION: 1.0
#      CREATED: 12/08/15 23:50:40
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use 5.010;

use List::Util qw( min max );


my %map;

while ( <DATA> ) {
    chomp;

    my ( $source, undef, $destination, undef, $distance ) = split;

    $map{$source}{$destination} = $map{$destination}{$source} = $distance;
}

my @routes = routes( keys %map );

say min( @routes );
say max( @routes );



sub routes {
    my @ports = @_;
    my @routes;

    for my $start ( @ports ) {
        push @routes, routes_from( $start, grep { $_ ne $start } @ports );
    }

    return @routes;
}



sub routes_from {
    my $start = shift;
    my @others = @_;
    my @routes;

    if ( @others == 1 ) {
        return ( $map{$start}{ $others[0] } );
    }

    for my $next ( @others ) {
        push @routes, map { $map{$start}{$next} + $_ } routes_from( $next, grep { $_ ne $next } @others );
    }

    return @routes;
}



__END__
Faerun to Tristram = 65
Faerun to Tambi = 129
Faerun to Norrath = 144
Faerun to Snowdin = 71
Faerun to Straylight = 137
Faerun to AlphaCentauri = 3
Faerun to Arbre = 149
Tristram to Tambi = 63
Tristram to Norrath = 4
Tristram to Snowdin = 105
Tristram to Straylight = 125
Tristram to AlphaCentauri = 55
Tristram to Arbre = 14
Tambi to Norrath = 68
Tambi to Snowdin = 52
Tambi to Straylight = 65
Tambi to AlphaCentauri = 22
Tambi to Arbre = 143
Norrath to Snowdin = 8
Norrath to Straylight = 23
Norrath to AlphaCentauri = 136
Norrath to Arbre = 115
Snowdin to Straylight = 101
Snowdin to AlphaCentauri = 84
Snowdin to Arbre = 96
Straylight to AlphaCentauri = 107
Straylight to Arbre = 14
AlphaCentauri to Arbre = 46
