#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: day14.pl
#
#        USAGE: ./day14.pl
#
#  DESCRIPTION: Day 14 - Reindeer Olympics
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Mark T. Johnson (mtj), markj@matzsoft.com
# ORGANIZATION: MATZ Software & Consulting
#      VERSION: 1.0
#      CREATED: 12/13/15 23:55:19
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use 5.010;

use List::Util qw( max );


my $race_duration = 2503;
my ( @names, %names );

while ( <DATA> ) {
    chomp;

    my ($name, undef, undef, $rate, undef, undef, $duration,
        undef, undef, undef, undef, undef, undef, $rest
    ) = split;

    push @names, $name;
    $names{$name} = {
        rate      => $rate,
        duration  => $duration,
        rest      => $rest,
        flying    => 1,
        remaining => $duration,
        distance  => 0,
        points    => 0,
    };
}

for ( 1 .. $race_duration ) {
    for my $name ( @names ) {
        my $info = $names{$name};

        $info->{distance} += $info->{rate} if $info->{flying};
        if ( --$info->{remaining} == 0 ) {
            $info->{flying} ^= 1;
            if ( $info->{flying} ) {
                $info->{remaining} = $info->{duration};

            } else {
                $info->{remaining} = $info->{rest};
            }
        }
    }

    my $max = max( map { $_->{distance} } values %names );

    $names{$_}{points}++ for grep { $names{$_}{distance} == $max } @names;
}

my $winner;
my $max = max( map { $_->{distance} } values %names );

$winner = $_ for grep { $names{$_}{distance} == $max } @names;
say "$winner = $max";

$max = max( map { $_->{points} } values %names );
$winner = $_ for grep { $names{$_}{points} == $max } @names;
say "$winner = $max";



__END__
Dancer can fly 27 km/s for 5 seconds, but then must rest for 132 seconds.
Cupid can fly 22 km/s for 2 seconds, but then must rest for 41 seconds.
Rudolph can fly 11 km/s for 5 seconds, but then must rest for 48 seconds.
Donner can fly 28 km/s for 5 seconds, but then must rest for 134 seconds.
Dasher can fly 4 km/s for 16 seconds, but then must rest for 55 seconds.
Blitzen can fly 14 km/s for 3 seconds, but then must rest for 38 seconds.
Prancer can fly 3 km/s for 21 seconds, but then must rest for 40 seconds.
Comet can fly 18 km/s for 6 seconds, but then must rest for 103 seconds.
Vixen can fly 18 km/s for 5 seconds, but then must rest for 84 seconds.
