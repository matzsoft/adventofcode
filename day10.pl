#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: day10.pl
#
#        USAGE: ./day10.pl  
#
#  DESCRIPTION: Day 10 - Elves play look-and-say
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: Part 1 (loop limit set to 40) runs in reasonable time but for
#               part 2 (loop limit set to 50) it takes well over an hour to
#               run.  I expect that any substantial reduction in runtime would
#               require not using regular expressions.
#       AUTHOR: Mark T. Johnson (mtj), markj@matzsoft.com
# ORGANIZATION: MATZ Software & Consulting
#      VERSION: 1.0
#      CREATED: 12/10/15 08:58:16
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use 5.010;


my $input = 1113122113;
my $current = $input;

for ( 1 .. 50 ) {
    my $next;

    while ( my $match = $current =~ m/(\d)\1*/pg ) {
        $next .= length( ${^MATCH} ) . $1;
    }

    $current = $next;
}

say length( $current );
