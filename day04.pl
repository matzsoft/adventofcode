#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: day04.pl
#
#        USAGE: ./day04.pl  
#
#  DESCRIPTION: Day 4 - Advent coins
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Mark T. Johnson (mtj), markj@matzsoft.com
# ORGANIZATION: MATZ Software & Consulting
#      VERSION: 1.0
#      CREATED: 12/08/15 12:37:26
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use 5.010;

use Digest::MD5 qw( md5_hex );

my $secret_key = 'iwrupvqb';
my $number = 0;

while ( md5_hex( $secret_key, $number ) !~ m/^00000/ ) {
    $number++;
}

say $number;

while ( md5_hex( $secret_key, $number ) !~ m/^000000/ ) {
    $number++;
}

say $number;
