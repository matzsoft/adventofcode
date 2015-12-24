#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: day11.pl
#
#        USAGE: ./day11.pl  
#
#  DESCRIPTION: Day 11 - Santa's password nightmare
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Mark T. Johnson (mtj), markj@matzsoft.com
# ORGANIZATION: MATZ Software & Consulting
#      VERSION: 1.0
#      CREATED: 12/10/15 21:08:49
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use 5.010;


my $initial = 'hxbxwxba';
my $next = $initial;

while ( not valid( ++$next ) ) {}

say $next;

while ( not valid( ++$next ) ) {}

say $next;



sub valid {
    local $_ = shift;

    return undef if not m/ abc | bcd | cde | def | efg | fgh | ghj | hjk | jkm | kmn | mnp | npq | pqr | qrs | rst | stu | tuv | uvw | vwx | wxy | xyz /x;
    return undef if m/[iol]/;
    return undef if not m/(.)\1.*(.)\2/;

    return 1;
}
