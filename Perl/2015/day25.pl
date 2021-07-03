#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: day25.pl
#
#        USAGE: ./day25.pl  
#
#  DESCRIPTION: Day 25 - Santa's weather machine.
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Mark T. Johnson (mtj), markj@matzsoft.com
# ORGANIZATION: MATZ Software & Consulting
#      VERSION: 1.0
#      CREATED: 12/24/15 21:10:05
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use 5.010;


my $start_value = 20151125;
my $multiplier  = 252533;
my $divisor     = 33554393;
my $data        = do { local $/; $_ = <DATA>; s/[,.\n]//g; $_ };
my @words       = split q{ }, $data;
my ( $target_row, $target_col ) = map { $_ - 1 } @words[ 15, 17 ];
my ( $row, $col, $maxrow ) = ( 0, 0, 0 );
my $current = $start_value;

while ( $row != $target_row or $col != $target_col ) {
    $current = ( $current * $multiplier ) % $divisor;

    if ( $row == 0 ) {
        $row = ++$maxrow;
        $col = 0;

    } else {
        $row--;
        $col++;
    }
}

say $current;



__END__
To continue, please consult the code grid in the manual.  Enter the code at row 2947, column 3029.
