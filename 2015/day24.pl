#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: day24.pl
#
#        USAGE: ./day24.pl  
#
#  DESCRIPTION: Day 24 - Loading up the sleigh.
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Mark T. Johnson (mtj), markj@matzsoft.com
# ORGANIZATION: MATZ Software & Consulting
#      VERSION: 1.0
#      CREATED: 12/23/15 21:19:03
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use 5.010;

use POSIX qw( ceil );
use List::Util qw( max min sum reduce );


my @weights;

while ( <DATA> ) {
    chomp;
    push @weights, $_;
}

my $goal = sum( @weights ) / 3;
my $min_number = ceil( @weights / 3 );
my $min_qe = 344266178324;                  # ( first found with the minimum number(6) ) + 1
my @list = grep { @$_ == $min_number } find_it( 0, 1, $goal, sort { $b <=> $a } @weights );

say join( q{, }, @$_ ) for @list;
say min( map { reduce { $a * $b } @$_ } @list );

$goal = sum( @weights ) / 4;
$min_number = ceil( @weights / 4 );
$min_qe = 344266178324;                  # ( first found with the minimum number(6) ) + 1
@list = grep { @$_ == $min_number } find_it( 0, 1, $goal, sort { $b <=> $a } @weights );

say join( q{, }, @$_ ) for @list;
say min( map { reduce { $a * $b } @$_ } @list );



sub find_it {
    my $depth = shift;
    my $qe = shift;
    my $goal = shift;
    my @weights = @_;

    return () if $depth >= $min_number or $qe > $min_qe or @weights == 0;

    my $weight = shift @weights;

    if ( $weight == $goal ) {
        my $new_qe = $weight * $qe;

        if ( $new_qe < $min_qe ) {
            $min_qe = $new_qe;
            $min_number = $depth + 1;
            return ( [ $weight ] );
        }
    }

    my @without = find_it( $depth, $qe, $goal, @weights );

    if ( $weight >= $goal ) {
        return @without;
    }

    # $weight < $goal
    my @with = find_it( $depth + 1, $qe * $weight, $goal - $weight, @weights );

    return () if @with + @without == 0;

    unshift @{ $_ }, $weight for @with;

    my $min = min( map { scalar( @$_ ) } @with, @without );

    return grep { @$_ == $min } @with, @without;
}



__END__
1
3
5
11
13
17
19
23
29
31
37
41
43
47
53
59
67
71
73
79
83
89
97
101
103
107
109
113
